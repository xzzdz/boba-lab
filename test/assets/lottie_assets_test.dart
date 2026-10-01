import 'dart:io';

import 'package:boba_lab/core/widgets/boba_lottie.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

LottieComposition _load(String name) => LottieComposition.parseJsonBytes(File(BobaLotties.asset(name)).readAsBytesSync());

void main() {
  test('assets/lottie holds exactly the animations the app uses', () {
    final onDisk = Directory('assets/lottie')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last.replaceAll('.json', ''))
        .toSet();
    expect(onDisk, BobaLotties.all.toSet());
  });

  for (final name in BobaLotties.all) {
    test('$name parses cleanly', () {
      final composition = _load(name);
      expect(composition.duration, greaterThan(Duration.zero));
      expect(composition.bounds.width, greaterThan(0));
      expect(composition.bounds.height, greaterThan(0));
      expect(composition.warnings, isEmpty, reason: 'unsupported Lottie features in $name');
    });
  }

  testWidgets('every animation paints its frames', (tester) async {
    for (final name in BobaLotties.all) {
      final composition = _load(name);
      for (final progress in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(
          Center(
            child: Lottie(composition: composition, controller: AlwaysStoppedAnimation(progress), width: 120, height: 120),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$name at $progress');
      }
    }
  });
}
