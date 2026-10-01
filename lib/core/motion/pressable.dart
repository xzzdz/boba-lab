import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'motion.dart';

/// Tap target with the Soft Clay press: squish to 92% in 120 ms, then spring
/// back past 100% and settle. Works with mouse, touch and keyboard.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = BobaMotion.pressScale,
    this.semanticLabel,
    this.selected,
    this.borderRadius = const BorderRadius.all(Radius.circular(BobaRadii.button)),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  final bool? selected;

  /// Shape of the keyboard focus ring.
  final BorderRadius borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController.unbounded(vsync: this);
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  void _down() {
    if (!_enabled || context.reduceMotion) return;
    _press.animateTo(1, duration: BobaMotion.press, curve: BobaMotion.pressIn);
  }

  void _up() {
    if (context.reduceMotion) {
      _press.value = 0;
      return;
    }
    _press.animateWith(SpringSimulation(BobaMotion.releaseSpring, _press.value, 0, _press.velocity));
  }

  void _activate() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final squish = 1 - widget.scale;
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _down(),
          onTapUp: (_) => _up(),
          onTapCancel: _up,
          onTap: _enabled ? _activate : null,
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, child) => Transform.scale(scale: 1 - squish * _press.value, child: child),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: _focused ? Border.all(color: BobaColors.primary, width: 2.5) : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
