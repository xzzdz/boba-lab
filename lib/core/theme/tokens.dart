import 'package:flutter/widgets.dart';

/// Design direction A, "Soft Clay".
///
/// Palette starts from the ui-ux-pro-max "Claymorphism (Mobile)" result
/// (taro violet + strawberry pink on lavender white) and adds the drink
/// colours the cup needs.
abstract final class BobaColors {
  static const background = Color(0xFFF4F1FA);
  static const surface = Color(0xFFFFFFFF);
  static const track = Color(0xFFECE6FA);
  static const selectedTint = Color(0xFFF3E8FF);
  static const primary = Color(0xFF7C3AED);
  static const primaryDeep = Color(0xFF6D28D9);
  static const primaryInk = Color(0xFF5B21B6);
  static const primarySoft = Color(0xFFDCD0FB);
  static const pink = Color(0xFFDB2777);
  static const pinkSoft = Color(0xFFFBCFE1);
  static const ink = Color(0xFF332F3A);
  static const muted = Color(0xFF635F69);
  static const line = Color(0xFFE4DDF3);
  static const success = Color(0xFF10B981);
  static const successInk = Color(0xFF047857);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFDE2E7);

  // Cup parts.
  static const straw = Color(0xFFF9A8D4);
  static const lid = Color(0xFFC4B5FD);
  static const syrup = Color(0xFF5A2E14);
  static const syrupDeep = Color(0xFF3D1D0C);
  static const pearl = Color(0xFF2A1A12);
  static const jelly = Color(0xFF2B2420);
  static const pudding = Color(0xFFF6C453);
  static const puddingTop = Color(0xFFC7862E);
  static const foam = Color(0xFFFFF3DA);
}

abstract final class BobaRadii {
  static const double card = 28;
  static const double sheet = 32;
  static const double button = 20;
  static const double chip = 16;
  static const double field = 18;
}

abstract final class BobaSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Side gutter for every screen.
  static const double gutter = 20;
}
