import 'package:flutter/widgets.dart';

import '../data/models.dart';
import 'cart_controller.dart';
import 'order_controller.dart';
import 'rewards_controller.dart';
import 'settings_controller.dart';

/// All app state. Plain ChangeNotifiers: the app is small enough that a
/// state-management package would add more than it saves.
class AppControllers {
  AppControllers({required this.settings, required this.cart, required this.orders, required this.rewards, required this.clock});

  /// Sample state a visitor starts with: 6 stamps and two past orders.
  factory AppControllers.demo({
    DateTime Function()? clock,
    Locale locale = const Locale('th'),
    bool reduceMotion = false,
    bool onboardingDone = false,
    Duration brewAfter = const Duration(seconds: 4),
    Duration readyAfter = const Duration(seconds: 7),
  }) {
    final now = clock ?? DateTime.now;
    return AppControllers(
      settings: SettingsController(locale: locale, reduceMotion: reduceMotion, onboardingDone: onboardingDone),
      cart: CartController(),
      orders: OrderController(clock: now, brewAfter: brewAfter, readyAfter: readyAfter, history: demoHistory(now())),
      rewards: RewardsController(),
      clock: now,
    );
  }

  final SettingsController settings;
  final CartController cart;
  final OrderController orders;
  final RewardsController rewards;
  final DateTime Function() clock;

  void resetDemo() {
    cart.clear();
    orders.reset(history: demoHistory(clock()));
    rewards.reset();
  }

  void dispose() {
    settings.dispose();
    cart.dispose();
    orders.dispose();
    rewards.dispose();
  }

  static List<Order> demoHistory(DateTime now) {
    Order past(String number, String code, int daysAgo, List<CartLine> lines) {
      final at = DateTime(now.year, now.month, now.day - daysAgo, 15, 20);
      final subtotal = lines.fold(0, (sum, line) => sum + line.total);
      return Order(
        number: number,
        pickupCode: code,
        lines: lines,
        subtotal: subtotal,
        discount: 0,
        payment: PaymentMethod.promptPay,
        placedAt: at,
        readyAt: at.add(const Duration(minutes: 15)),
        status: OrderStatus.completed,
        statusTimes: {OrderStatus.completed: at.add(const Duration(minutes: 18))},
      );
    }

    return [
      past('BL-0426', 'C42', 1, const [
        CartLine(
          id: 'h1',
          config: CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls}),
          quantity: 1,
        ),
        CartLine(
          id: 'h2',
          config: CupConfig(base: BaseId.brownSugar, size: CupSize.large, sweetness: 75, ice: IceLevel.less, toppings: {ToppingId.pearls}),
          quantity: 1,
        ),
      ]),
      past('BL-0419', 'F23', 3, const [
        CartLine(
          id: 'h3',
          config: CupConfig(base: BaseId.matcha, sweetness: 25),
          quantity: 1,
        ),
      ]),
    ];
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.controllers, required super.child});

  final AppControllers controllers;

  /// Doesn't subscribe to changes; wrap reads in a ListenableBuilder.
  static AppControllers of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this context.');
    return scope!.controllers;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => controllers != oldWidget.controllers;
}
