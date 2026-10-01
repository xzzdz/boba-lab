@Tags(['icons'])
library;

import 'package:boba_lab/core/theme/tokens.dart';
import 'package:boba_lab/data/models.dart';
import 'package:boba_lab/features/cup/cup_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshots.dart';

/// Draws the web app icons from the same cup painter the app uses.
void main() {
  const size = 512.0;

  Widget icon({required bool maskable}) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), BobaColors.primary, BobaColors.pink],
          ),
          // Maskable icons fill the square; the platform crops them.
          borderRadius: maskable ? null : BorderRadius.circular(size * 0.22),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupView(
              config: const CupConfig(base: BaseId.milkTea, toppings: {ToppingId.pearls}),
              height: maskable ? size * 0.58 : size * 0.74,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> render(WidgetTester tester, {required bool maskable, required Map<String, double> outputs}) async {
    tester.view.physicalSize = const Size(size, size);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          key: key,
          child: icon(maskable: maskable),
        ),
      ),
    );
    for (final MapEntry(key: path, value: pixels) in outputs.entries) {
      final slash = path.lastIndexOf('/');
      await saveScreenshot(
        tester,
        find.byKey(key),
        path.substring(slash + 1),
        dir: slash < 0 ? 'web' : 'web/${path.substring(0, slash)}',
        pixelRatio: pixels / size,
      );
    }
  }

  testWidgets('regular icons and favicon', (tester) async {
    await render(tester, maskable: false, outputs: {'icons/Icon-512': 512, 'icons/Icon-192': 192, 'favicon': 32});
  });

  testWidgets('maskable icons', (tester) async {
    await render(tester, maskable: true, outputs: {'icons/Icon-maskable-512': 512, 'icons/Icon-maskable-192': 192});
  });
}
