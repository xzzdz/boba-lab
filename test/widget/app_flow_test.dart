import 'package:boba_lab/core/widgets/clay_controls.dart';
import 'package:boba_lab/data/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('order a customised cup from menu to pickup (Thai)', (tester) async {
    final app = await pumpBobaLab(tester);
    expect(find.text('วันนี้ดื่มอะไรดี?'), findsOneWidget);
    expect(find.text('สวัสดีตอนบ่าย'), findsOneWidget);

    // Menu → builder.
    await tester.tap(find.text('ชานมไข่มุก').first);
    await tester.pumpAndSettle();
    expect(find.text('ปรับแก้วของคุณ'), findsOneWidget);

    // Customise: 100% sweet, add cheese foam.
    await tester.tap(find.text('100%'));
    await tester.pumpAndSettle();
    expect(find.textContaining('หวาน 100%'), findsOneWidget);
    await tester.tap(find.text('ชีสโฟม'));
    await tester.pumpAndSettle();
    expect(find.text('฿80'), findsWidgets);

    // Add to cart, then open the cart from the header.
    await tester.tap(find.widgetWithText(ClayButton, 'ใส่ตะกร้า'));
    await tester.pumpAndSettle();
    expect(app.cart.cupCount, 1);
    expect(app.cart.lines.single.config.toppings, {ToppingId.pearls, ToppingId.cheeseFoam});
    await tester.tap(find.bySemanticsLabel('ตะกร้า'));
    await tester.pumpAndSettle();
    expect(find.text('ตะกร้า · 1 แก้ว'), findsOneWidget);

    // Cart → checkout, pay at the store.
    await tester.tap(find.widgetWithText(ClayButton, 'ไปชำระเงิน'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('จ่ายที่ร้าน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('จ่ายที่ร้าน'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ClayButton, 'ยืนยันออเดอร์'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('ส่งออเดอร์แล้ว!'), findsOneWidget);
    expect(app.cart.isEmpty, isTrue);
    expect(app.rewards.stamps, 7, reason: '6 sample stamps + 1 cup');

    // Track: the store moves the order along by itself.
    await tester.tap(find.widgetWithText(ClayButton, 'ติดตามออเดอร์'));
    await tester.pumpAndSettle();
    expect(find.text('ร้านรับออเดอร์แล้ว'), findsWidgets);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('กำลังชงเครื่องดื่ม'), findsWidgets);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('พร้อมรับแล้ว'), findsWidgets);

    await tester.tap(find.widgetWithText(ClayButton, 'รับเครื่องดื่มแล้ว'));
    await tester.pumpAndSettle();
    expect(app.orders.active, isNull);
    expect(find.widgetWithText(ClayButton, 'สั่งอีกครั้ง'), findsOneWidget);

    await closeBobaLab(tester, app);
  });

  testWidgets('builder names and prices the cup as it changes (English)', (tester) async {
    final app = await pumpBobaLab(tester, location: '/build/pearl-milk-tea', locale: const Locale('en'));
    expect(find.text('Pearl milk tea'), findsOneWidget);
    expect(find.text('฿65'), findsWidgets);

    await tester.tap(find.text('L · 22 oz'));
    await tester.pumpAndSettle();
    expect(find.text('฿75'), findsWidgets);

    await tester.tap(find.text('Cheese foam'));
    await tester.pumpAndSettle();
    expect(find.text('฿90'), findsWidgets);

    await tester.tap(find.text('Pearls'));
    await tester.pumpAndSettle();
    expect(find.text('Cheese foam milk tea'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Thai tea'));
    await tester.pumpAndSettle();
    expect(find.text('Cheese foam Thai tea'), findsOneWidget);
    expect(find.textContaining('Regular ice'), findsOneWidget);

    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No ice'), findsOneWidget);

    await closeBobaLab(tester, app);
  });

  testWidgets('quick add from the menu shows the cart bar; undo restores a removed cup', (tester) async {
    final app = await pumpBobaLab(tester, locale: const Locale('en'));
    await tester.tap(find.bySemanticsLabel('Add Pearl milk tea to cart'));
    await tester.pumpAndSettle();
    expect(find.text('1 cup'), findsOneWidget);

    await tester.tap(find.text('View cart').last);
    await tester.pumpAndSettle();
    await tester.drag(find.text('Pearl milk tea'), const Offset(-500, 0));
    // Short pumps only: settling would also wait out the undo toast.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(app.cart.isEmpty, isTrue);
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(app.cart.cupCount, 1);

    await closeBobaLab(tester, app);
  });

  testWidgets('language switch in profile changes the whole app', (tester) async {
    final app = await pumpBobaLab(tester, location: '/profile', locale: const Locale('en'));
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('ไทย'));
    await tester.pumpAndSettle();
    expect(find.text('ตั้งค่า'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('เมนู'));
    await tester.pumpAndSettle();
    expect(find.text('วันนี้ดื่มอะไรดี?'), findsOneWidget);
    await closeBobaLab(tester, app);
  });

  testWidgets('a full stamp card turns into a free cup the cart can use', (tester) async {
    final app = await pumpBobaLab(tester, location: '/rewards', locale: const Locale('en'));
    expect(find.text('6 / 10'), findsOneWidget);
    app.rewards.addStamps(4);
    await tester.pumpAndSettle();
    expect(find.text('Card complete! A free cup is yours.'), findsOneWidget);
    expect(find.text('1 free cup · any drink'), findsOneWidget);

    app.cart.add(const CupConfig(base: BaseId.matcha));
    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View cart').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ClaySwitch));
    await tester.pumpAndSettle();
    expect(find.text('-฿65'), findsOneWidget);
    expect(find.text('฿0'), findsWidgets);
    await closeBobaLab(tester, app);
  });

  testWidgets('unknown links land on a friendly page', (tester) async {
    final app = await pumpBobaLab(tester, location: '/build/does-not-exist', locale: const Locale('en'));
    expect(find.text("We couldn't find that page."), findsOneWidget);
    await tester.tap(find.text('Back to menu'));
    await tester.pumpAndSettle();
    expect(find.text('What are we sipping today?'), findsOneWidget);
    await closeBobaLab(tester, app);
  });

  testWidgets('splash goes to onboarding the first time, and onboarding to the menu', (tester) async {
    final app = await pumpBobaLab(tester, location: '/splash', onboardingDone: false, settle: false);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('ปรับแก้วได้ทุกอย่าง'), findsOneWidget);
    await tester.tap(find.text('ข้าม'));
    await tester.pumpAndSettle();
    expect(find.text('วันนี้ดื่มอะไรดี?'), findsOneWidget);
    expect(app.settings.onboardingDone, isTrue);
    await closeBobaLab(tester, app);
  });

  testWidgets('with full motion, the builder animates without errors', (tester) async {
    final app = await pumpBobaLab(tester, reduceMotion: false, settle: false, locale: const Locale('en'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Pearl milk tea').first);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.text('Cheese foam'));
    await tester.tap(find.text('Extra'));
    await tester.tap(find.bySemanticsLabel('Brown sugar milk'));
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.widgetWithText(ClayButton, 'Add to cart'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 3));
    expect(app.cart.cupCount, 1);
    expect(tester.takeException(), isNull);
    await closeBobaLab(tester, app);
  });
}
