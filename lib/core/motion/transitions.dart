import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'motion.dart';

/// Page transitions, all built on the Soft Clay tokens. Exits use the
/// accelerating curve and are faster than entrances.
enum BobaTransition {
  /// Cross-fade. Splash → onboarding → home.
  fade,

  /// Fade in while rising 24 px with a little overshoot. Cup builder.
  rise,

  /// Slide in from the right by a third of the width. Cart, checkout.
  slide,

  /// Grow from 90% with overshoot. Success, tracking.
  pop,
}

CustomTransitionPage<void> bobaPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  BobaTransition transition = BobaTransition.rise,
}) {
  final reduced = context.reduceMotion;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name ?? state.matchedLocation,
    child: child,
    transitionDuration: reduced ? Duration.zero : BobaMotion.page,
    reverseTransitionDuration: reduced ? Duration.zero : BobaMotion.pageExit,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        _BobaTransitionView(animation: animation, transition: transition, child: child),
  );
}

class _BobaTransitionView extends StatelessWidget {
  const _BobaTransitionView({required this.animation, required this.transition, required this.child});

  final Animation<double> animation;
  final BobaTransition transition;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final leaving = animation.status == AnimationStatus.reverse;
        final eased = leaving ? BobaMotion.exit.transform(t) : BobaMotion.signature.transform(t);
        final opacity = (leaving ? t : t * 1.6).clamp(0.0, 1.0);
        switch (transition) {
          case BobaTransition.fade:
            return Opacity(opacity: BobaMotion.fluid.transform(t), child: child);
          case BobaTransition.rise:
            return Opacity(
              opacity: opacity,
              child: Transform.translate(offset: Offset(0, (1 - eased) * 24), child: child),
            );
          case BobaTransition.slide:
            final width = MediaQuery.sizeOf(context).width;
            final slide = leaving ? BobaMotion.exit.transform(t) : BobaMotion.fluid.transform(t);
            return Opacity(
              opacity: opacity,
              child: Transform.translate(offset: Offset((1 - slide) * width / 3, 0), child: child),
            );
          case BobaTransition.pop:
            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: 0.9 + 0.1 * eased, child: child),
            );
        }
      },
    );
  }
}
