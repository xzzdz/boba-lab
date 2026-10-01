import 'package:flutter/widgets.dart';

/// Motion tokens for design direction A, "Soft Clay".
///
/// Personality from the motion-design skill: Playful. One signature curve
/// (ease-out-back, 10–20% overshoot) carries most motion; three durations;
/// entrances bounce up from below; exits are faster than entrances.
abstract final class BobaMotion {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  static const press = Duration(milliseconds: 120);
  static const page = Duration(milliseconds: 420);
  static const pageExit = Duration(milliseconds: 280);
  static const entrance = Duration(milliseconds: 440);
  static const entranceStagger = Duration(milliseconds: 45);

  /// Micro cascade for many small parts (pearls, ice). Total stays < 500 ms.
  static const stagger = Duration(milliseconds: 32);

  /// cubic-bezier(.34, 1.56, .64, 1)
  static const Curve signature = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
  static const Curve fluid = Cubic(0.45, 0, 0.2, 1);
  static const Curve pressIn = Cubic(0.2, 0, 0, 1);
  static const Curve gravity = Cubic(0.55, 0, 1, 0.45);

  static const double pressScale = 0.92;

  /// Release after a press: underdamped (ζ ≈ 0.44), about 20% overshoot.
  static const releaseSpring = SpringDescription(mass: 1, stiffness: 420, damping: 18);
}

/// Carries the in-app "reduce motion" setting down the tree.
class MotionScope extends InheritedWidget {
  const MotionScope({super.key, required this.reduced, required super.child});

  final bool reduced;

  static bool reducedOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MotionScope>()?.reduced ?? false;

  @override
  bool updateShouldNotify(MotionScope oldWidget) => reduced != oldWidget.reduced;
}

extension MotionContext on BuildContext {
  /// True when the OS asks for less motion or the user switched it off in the app.
  bool get reduceMotion => MotionScope.reducedOf(this) || (MediaQuery.maybeDisableAnimationsOf(this) ?? false);

  /// [duration], or zero when motion is reduced.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
