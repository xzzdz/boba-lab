import 'package:boba_lab/data/models.dart';
import 'package:boba_lab/state/cart_controller.dart';
import 'package:boba_lab/state/order_controller.dart';
import 'package:boba_lab/state/rewards_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const pearlTea = CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls});
const matcha = CupConfig(base: BaseId.matcha, sweetness: 25);

void main() {
  group('CartController', () {
    test('identical cups merge into one line', () {
      final cart = CartController()
        ..add(pearlTea)
        ..add(pearlTea)
        ..add(matcha);
      expect(cart.lines, hasLength(2));
      expect(cart.cupCount, 3);
      expect(cart.subtotal, 65 * 2 + 65);
    });

    test('quantity zero removes the line', () {
      final cart = CartController();
      final line = cart.add(pearlTea);
      cart.setQuantity(line.id, 0);
      expect(cart.isEmpty, isTrue);
    });

    test('remove then restore puts the line back where it was', () {
      final cart = CartController()
        ..add(pearlTea)
        ..add(matcha);
      final removed = cart.remove(cart.lines.first.id)!;
      expect(cart.lines.single.config, matcha);
      cart.restore(removed.line, removed.index);
      expect(cart.lines.map((line) => line.config), [pearlTea, matcha]);
    });

    test('free cup covers the priciest cup, only when available and switched on', () {
      final cart = CartController()
        ..add(const CupConfig(base: BaseId.milkTea))
        ..add(const CupConfig(base: BaseId.matcha, size: CupSize.large, toppings: {ToppingId.cheeseFoam}));
      expect(cart.freeCupDiscount(available: true), 0);
      cart.setUseFreeCup(true);
      expect(cart.freeCupDiscount(available: false), 0);
      expect(cart.freeCupDiscount(available: true), 65 + 10 + 15);
      expect(cart.total(freeCupAvailable: true), 55);
    });

    test('clear resets pickup and free cup', () {
      final cart = CartController()
        ..add(pearlTea)
        ..setPickup(PickupSlot.in45)
        ..setUseFreeCup(true)
        ..clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.pickup, PickupSlot.asap);
      expect(cart.useFreeCup, isFalse);
    });
  });

  group('RewardsController', () {
    test('stamps add up and roll over into free cups', () {
      final rewards = RewardsController(stamps: 8);
      expect(rewards.addStamps(1), 0);
      expect(rewards.stamps, 9);
      expect(rewards.freshStamps, 1);
      expect(rewards.addStamps(3), 1);
      expect(rewards.stamps, 2);
      expect(rewards.freeCups, 1);
      expect(rewards.completedCard, isTrue);
      expect(rewards.freshStamps, 2, reason: 'the new card animates only its own stamps');
    });

    test('acknowledge clears the pending animation silently', () {
      final rewards = RewardsController()..addStamps(2);
      var notified = false;
      rewards.addListener(() => notified = true);
      rewards.acknowledge();
      expect(rewards.freshStamps, 0);
      expect(notified, isFalse);
    });

    test('using a free cup', () {
      final rewards = RewardsController(freeCups: 1);
      expect(rewards.useFreeCup(), isTrue);
      expect(rewards.useFreeCup(), isFalse);
    });
  });

  group('OrderController', () {
    final placedAt = DateTime(2026, 10, 2, 14, 30);

    Order placeOne(OrderController orders) => orders.place(
      lines: const [CartLine(id: 'a', config: pearlTea, quantity: 2)],
      subtotal: 130,
      discount: 0,
      payment: PaymentMethod.cash,
      pickupMinutes: 15,
    );

    test('numbers, codes and pickup time', () {
      final orders = OrderController(clock: () => placedAt);
      addTearDown(orders.dispose);
      final order = placeOne(orders);
      expect(order.number, 'BL-0427');
      expect(order.pickupCode, matches(RegExp(r'^[A-F]\d{2}$')));
      expect(order.readyAt, placedAt.add(const Duration(minutes: 15)));
      expect(order.cups, 2);
      expect(orders.active?.number, order.number);
      expect(placeOne(orders).number, 'BL-0428');
    });

    test('advance stops at ready; pick up completes', () {
      final orders = OrderController(clock: () => placedAt);
      addTearDown(orders.dispose);
      final number = placeOne(orders).number;
      orders.advance(number);
      expect(orders.byNumber(number)!.status, OrderStatus.brewing);
      orders.advance(number);
      orders.advance(number);
      expect(orders.byNumber(number)!.status, OrderStatus.ready);
      orders.pickUp(number);
      expect(orders.byNumber(number)!.status, OrderStatus.completed);
      expect(orders.active, isNull);
      expect(orders.past.first.number, number);
    });

    testWidgets('the store moves the order along on its own', (tester) async {
      final orders = OrderController(clock: () => placedAt);
      final number = placeOne(orders).number;
      await tester.pump(const Duration(seconds: 4));
      expect(orders.byNumber(number)!.status, OrderStatus.brewing);
      await tester.pump(const Duration(seconds: 7));
      expect(orders.byNumber(number)!.status, OrderStatus.ready);
      await tester.pump(const Duration(seconds: 30));
      expect(orders.byNumber(number)!.status, OrderStatus.ready, reason: 'pickup is the customer’s step');
      orders.dispose();
    });
  });
}
