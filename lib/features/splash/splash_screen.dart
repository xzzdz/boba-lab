import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/feedback.dart';
import '../../state/app_scope.dart';

/// Logo builds itself (cup, tea, lid, straw, pearls), then the wordmark
/// rises in. Tap anywhere to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _wordmark = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  Timer? _timer;
  bool _started = false;
  bool _left = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = context.reduceMotion;
    if (reduced) {
      _wordmark.value = 1;
    } else {
      _wordmark.forward();
    }
    _timer = Timer(Duration(milliseconds: reduced ? 700 : 2300), _leave);
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    final done = AppScope.of(context).settings.onboardingDone;
    context.go(done ? '/menu' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wordmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DriftingBlobs(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BobaLottie(BobaLotties.splashLogo, size: 190, repeat: false),
                  AnimatedBuilder(
                    animation: _wordmark,
                    builder: (context, child) {
                      // Waits for the logo, then rises with the signature overshoot.
                      final t = const Interval(0.45, 1).transform(_wordmark.value);
                      final v = BobaMotion.signature.transform(t);
                      return Opacity(
                        opacity: (t * 2).clamp(0.0, 1.0),
                        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: child),
                      );
                    },
                    child: Column(
                      children: [
                        Text(context.l10n.appTitle, style: text.displaySmall!.copyWith(color: BobaColors.primaryInk)),
                        const SizedBox(height: 4),
                        Text(context.l10n.tagline, style: text.bodyLarge!.copyWith(color: BobaColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
