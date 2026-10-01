@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:boba_lab/core/theme/tokens.dart';
import 'package:boba_lab/core/widgets/boba_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../support/screenshots.dart';

/// A contact sheet: one row per animation, five moments across.
void main() {
  testWidgets('lottie contact sheet', (tester) async {
    const progress = [0.12, 0.3, 0.5, 0.72, 1.0];
    const cell = 132.0;
    tester.view.physicalSize = Size(cell * progress.length + 150, cell * BobaLotties.all.length);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: BobaColors.background,
            child: Column(
              children: [
                for (final name in BobaLotties.all)
                  SizedBox(
                    height: cell,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF332F3A))),
                        ),
                        for (final p in progress)
                          Container(
                            width: cell,
                            height: cell,
                            decoration: BoxDecoration(border: Border.all(color: const Color(0x22000000))),
                            child: Lottie(
                              composition: LottieComposition.parseJsonBytes(File(BobaLotties.asset(name)).readAsBytesSync()),
                              controller: AlwaysStoppedAnimation(p),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await saveScreenshot(tester, find.byKey(key), 'lottie_sheet', pixelRatio: 1);
  });
}
