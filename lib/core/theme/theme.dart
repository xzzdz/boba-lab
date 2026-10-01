import 'package:flutter/material.dart';

import 'tokens.dart';

const _display = 'Mitr';
const _body = 'Anuphan';

/// Mitr for headings, Anuphan for text. Both cover Thai and Latin, which the
/// fonts ui-ux-pro-max suggested (Nunito + DM Sans) do not.
const bobaTextTheme = TextTheme(
  displaySmall: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 34, height: 1.25, color: BobaColors.ink),
  headlineMedium: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 28, height: 1.28, color: BobaColors.ink),
  headlineSmall: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 24, height: 1.3, color: BobaColors.ink),
  titleLarge: TextStyle(fontFamily: _display, fontWeight: FontWeight.w600, fontSize: 20, height: 1.3, color: BobaColors.ink),
  titleMedium: TextStyle(fontFamily: _display, fontWeight: FontWeight.w500, fontSize: 17, height: 1.35, color: BobaColors.ink),
  titleSmall: TextStyle(fontFamily: _display, fontWeight: FontWeight.w500, fontSize: 15, height: 1.35, color: BobaColors.ink),
  bodyLarge: TextStyle(fontFamily: _body, fontWeight: FontWeight.w400, fontSize: 16, height: 1.55, color: BobaColors.ink),
  bodyMedium: TextStyle(fontFamily: _body, fontWeight: FontWeight.w400, fontSize: 14.5, height: 1.5, color: BobaColors.ink),
  bodySmall: TextStyle(fontFamily: _body, fontWeight: FontWeight.w500, fontSize: 12.5, height: 1.45, color: BobaColors.muted),
  labelLarge: TextStyle(fontFamily: _body, fontWeight: FontWeight.w600, fontSize: 15, height: 1.3, color: BobaColors.ink),
  labelMedium: TextStyle(fontFamily: _body, fontWeight: FontWeight.w600, fontSize: 13, height: 1.3, color: BobaColors.ink),
  labelSmall: TextStyle(fontFamily: _body, fontWeight: FontWeight.w600, fontSize: 11.5, height: 1.3, color: BobaColors.muted),
);

ThemeData buildBobaTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: BobaColors.primary,
    onPrimary: Colors.white,
    primaryContainer: BobaColors.selectedTint,
    onPrimaryContainer: BobaColors.primaryInk,
    secondary: BobaColors.pink,
    onSecondary: Colors.white,
    error: BobaColors.danger,
    onError: Colors.white,
    surface: BobaColors.surface,
    onSurface: BobaColors.ink,
    onSurfaceVariant: BobaColors.muted,
    outline: BobaColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: BobaColors.background,
    fontFamily: _body,
    textTheme: bobaTextTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    iconTheme: const IconThemeData(color: BobaColors.ink, size: 22),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: BobaColors.primary),
  );
}
