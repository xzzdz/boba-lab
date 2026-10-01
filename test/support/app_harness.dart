import 'package:boba_lab/app/app.dart';
import 'package:boba_lab/state/app_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Thursday 2 Oct 2026, 14:30: a fixed afternoon for every test.
DateTime fixedClock() => DateTime(2026, 10, 2, 14, 30);

/// Pumps the real app on a 390 × 844 phone. Motion is reduced by default so
/// ambient loops stop and `pumpAndSettle` can settle.
Future<AppControllers> pumpBobaLab(
  WidgetTester tester, {
  String location = '/menu',
  Locale locale = const Locale('th'),
  bool reduceMotion = true,
  bool onboardingDone = true,
  Size size = const Size(390, 844),
  bool settle = true,
  void Function(AppControllers controllers)? arrange,
  Key? boundaryKey,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controllers = AppControllers.demo(clock: fixedClock, locale: locale, reduceMotion: reduceMotion, onboardingDone: onboardingDone);
  arrange?.call(controllers);
  final app = BobaLabApp(controllers: controllers, initialLocation: location);
  await tester.pumpWidget(boundaryKey == null ? app : RepaintBoundary(key: boundaryKey, child: app));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return controllers;
}

/// Unmounts the app first, then stops its timers.
Future<void> closeBobaLab(WidgetTester tester, AppControllers controllers) async {
  await tester.pumpWidget(const SizedBox());
  controllers.dispose();
}
