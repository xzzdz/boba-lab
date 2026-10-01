import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/motion.dart';
import '../core/theme/theme.dart';
import '../l10n/app_localizations.dart';
import '../state/app_scope.dart';
import 'portfolio_frame.dart';
import 'router.dart';

class BobaLabApp extends StatefulWidget {
  const BobaLabApp({super.key, this.controllers, this.initialLocation});

  /// Injected by tests; the app makes its own demo state otherwise.
  final AppControllers? controllers;
  final String? initialLocation;

  @override
  State<BobaLabApp> createState() => _BobaLabAppState();
}

class _BobaLabAppState extends State<BobaLabApp> {
  static final _theme = buildBobaTheme();

  late final AppControllers _controllers = widget.controllers ?? AppControllers.demo();
  late final GoRouter _router = buildRouter(initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    if (widget.controllers == null) _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _controllers.settings;
    return AppScope(
      controllers: _controllers,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp.router(
          title: 'Boba Lab',
          debugShowCheckedModeBanner: false,
          theme: _theme,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router,
          builder: (context, child) => MotionScope(
            reduced: settings.reduceMotion,
            child: PortfolioFrame(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
