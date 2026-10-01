import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts so screenshots show Thai and Latin text instead of
/// the test font's boxes.
Future<void> loadAppFonts() async {
  final mitr = FontLoader('Mitr')
    ..addFont(rootBundle.load('assets/fonts/Mitr-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Mitr-SemiBold.ttf'));
  final anuphan = FontLoader('Anuphan')
    ..addFont(rootBundle.load('assets/fonts/Anuphan-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Anuphan-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Anuphan-SemiBold.ttf'));
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final iconsFile = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final icons = FontLoader('MaterialIcons')..addFont(iconsFile.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
  await Future.wait([mitr.load(), anuphan.load(), if (iconsFile.existsSync()) icons.load()]);
}

/// Writes the [RepaintBoundary] found by [finder] to `<dir>/<name>.png`.
Future<void> saveScreenshot(WidgetTester tester, Finder finder, String name, {String dir = 'build/preview', double pixelRatio = 2}) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$dir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}
