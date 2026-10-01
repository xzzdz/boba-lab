@Tags(['screenshots'])
library;

import 'package:boba_lab/core/widgets/boba_lottie.dart';
import 'package:boba_lab/core/widgets/clay_controls.dart';
import 'package:boba_lab/data/models.dart';
import 'package:boba_lab/state/app_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../support/app_harness.dart';
import '../support/screenshots.dart';

/// Renders every screen to docs/screenshots for review and the README.
///   flutter test --tags screenshots --run-skipped test/screenshots/screens_test.dart
void main() {
  setUpAll(loadAppFonts);

  const th = Locale('th');
  const en = Locale('en');
  final shotKey = GlobalKey();

  void twoCups(AppControllers c) {
    c.cart.add(const CupConfig(base: BaseId.brownSugar, size: CupSize.large, sweetness: 75, toppings: {ToppingId.pearls}));
    c.cart.add(const CupConfig(base: BaseId.matcha, sweetness: 25, toppings: {ToppingId.cheeseFoam}), quantity: 2);
  }

  void placedOrder(AppControllers c) {
    twoCups(c);
    final order = c.orders.place(
      lines: c.cart.lines,
      subtotal: c.cart.subtotal,
      discount: 0,
      payment: PaymentMethod.promptPay,
      pickupMinutes: 15,
    );
    c.rewards.addStamps(order.cups);
    c.cart.clear();
  }

  Future<void> warmLotties(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final name in BobaLotties.all) {
        await AssetLottie(BobaLotties.asset(name)).load();
      }
    });
  }

  Future<void> capture(
    WidgetTester tester,
    String name, {
    required String location,
    Locale locale = th,
    bool onboardingDone = true,
    Size size = const Size(390, 844),
    void Function(AppControllers c)? arrange,
    Future<void> Function(AppControllers c)? act,
  }) async {
    await warmLotties(tester);
    final app = await pumpBobaLab(
      tester,
      location: location,
      locale: locale,
      onboardingDone: onboardingDone,
      size: size,
      arrange: arrange,
      boundaryKey: shotKey,
      settle: location != '/splash',
    );
    await act?.call(app);
    await tester.pump(const Duration(milliseconds: 50));
    await saveScreenshot(tester, find.byKey(shotKey), name, dir: 'docs/screenshots');
    await closeBobaLab(tester, app);
  }

  testWidgets('01 splash', (t) => capture(t, '01_splash', location: '/splash'));
  testWidgets('02 onboarding', (t) => capture(t, '02_onboarding', location: '/onboarding', onboardingDone: false));
  testWidgets(
    '03 menu',
    (t) => capture(
      t,
      '03_menu',
      location: '/menu',
      arrange: (c) => c.cart.add(const CupConfig(base: BaseId.thaiTea, toppings: {ToppingId.pearls})),
    ),
  );
  testWidgets('04 builder', (t) async {
    await capture(
      t,
      '04_builder',
      location: '/build/brown-sugar-pearl',
      act: (c) async {
        await t.tap(find.text('L · 22 ออนซ์'));
        await t.pumpAndSettle();
        await t.tap(find.text('ชีสโฟม'));
        await t.pumpAndSettle();
      },
    );
  });
  testWidgets('05 cart', (t) => capture(t, '05_cart', location: '/cart', arrange: twoCups));
  testWidgets('06 checkout', (t) => capture(t, '06_checkout', location: '/checkout', arrange: twoCups));
  testWidgets('07 qr', (t) async {
    await capture(
      t,
      '07_qr',
      location: '/checkout',
      arrange: twoCups,
      act: (c) async {
        await t.tap(find.byType(ClayButton).last);
        await t.pumpAndSettle();
      },
    );
  });
  testWidgets('08 success', (t) => capture(t, '08_success', location: '/success/BL-0427', arrange: placedOrder));
  testWidgets(
    '09 tracking',
    (t) => capture(
      t,
      '09_tracking',
      location: '/track/BL-0427',
      arrange: (c) {
        placedOrder(c);
        c.orders.advance('BL-0427');
      },
    ),
  );
  testWidgets('10 orders', (t) => capture(t, '10_orders', location: '/orders', arrange: placedOrder));
  testWidgets('11 rewards', (t) => capture(t, '11_rewards', location: '/rewards', arrange: (c) => c.rewards.addStamps(2)));
  testWidgets('12 profile', (t) => capture(t, '12_profile', location: '/profile'));
  testWidgets('13 menu en', (t) => capture(t, '13_menu_en', location: '/menu', locale: en));
  testWidgets('14 builder en', (t) => capture(t, '14_builder_en', location: '/build/strawberry-cheese-foam', locale: en));
  testWidgets('15 desktop frame', (t) => capture(t, '15_desktop', location: '/menu', size: const Size(1440, 900)));
}
