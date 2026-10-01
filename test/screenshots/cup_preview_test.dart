@Tags(['screenshots'])
library;

import 'package:boba_lab/core/theme/tokens.dart';
import 'package:boba_lab/data/models.dart';
import 'package:boba_lab/features/cup/cup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshots.dart';

const _configs = [
  CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls}),
  CupConfig(base: BaseId.thaiTea, ice: IceLevel.extra, toppings: {ToppingId.cheeseFoam}),
  CupConfig(base: BaseId.taro, ice: IceLevel.none, toppings: {ToppingId.pudding}),
  CupConfig(base: BaseId.matcha, sweetness: 25, ice: IceLevel.less),
  CupConfig(base: BaseId.strawberry, toppings: {ToppingId.cheeseFoam, ToppingId.grassJelly}),
  CupConfig(base: BaseId.brownSugar, size: CupSize.large, sweetness: 100, toppings: {ToppingId.pearls}),
];

void main() {
  testWidgets('static cups', (tester) async {
    tester.view.physicalSize = const Size(1440, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: BobaColors.background,
          child: Center(
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final config in _configs)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CupView(config: config, height: 240),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await saveScreenshot(tester, find.byKey(key), 'cups_static');
  });

  testWidgets('animated cup frames', (tester) async {
    tester.view.physicalSize = const Size(1320, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final config = ValueNotifier(const CupConfig(base: BaseId.milkTea, ice: IceLevel.none));
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: BobaColors.background,
          child: Center(
            child: SizedBox(
              height: 240,
              width: 216,
              child: ValueListenableBuilder(
                valueListenable: config,
                builder: (context, value, _) => AnimatedCupView(config: value),
              ),
            ),
          ),
        ),
      ),
    );

    // Pearls + ice + foam + new base + more sugar all at once, sampled over time.
    config.value = const CupConfig(base: BaseId.brownSugar, sweetness: 100, toppings: {ToppingId.pearls, ToppingId.cheeseFoam});
    var elapsed = 0;
    for (final ms in [0, 120, 260, 420, 640, 1100]) {
      await tester.pump(Duration(milliseconds: ms - elapsed));
      elapsed = ms;
      await saveScreenshot(tester, find.byKey(key), 'cup_anim_${ms.toString().padLeft(4, '0')}', pixelRatio: 1);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
