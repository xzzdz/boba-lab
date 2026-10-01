import 'package:flutter/widgets.dart';

import 'motion.dart';

/// Plays the Soft Clay entrance once for every [StaggerItem] below it:
/// each item bounces up from 28 px below, 45 ms after the previous one.
///
/// Works around slivers too, because it adds no render object.
class StaggerGroup extends StatefulWidget {
  const StaggerGroup({super.key, required this.child, required this.itemCount});

  final Widget child;

  /// How many staggered slots to plan for; later items share the last slot.
  final int itemCount;

  @override
  State<StaggerGroup> createState() => _StaggerGroupState();
}

class _StaggerGroupState extends State<StaggerGroup> with SingleTickerProviderStateMixin {
  late final int _slots = widget.itemCount.clamp(1, 12);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BobaMotion.entrance + BobaMotion.entranceStagger * (_slots - 1),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _StaggerScope(controller: _controller, slots: _slots, child: widget.child);
}

class _StaggerScope extends InheritedWidget {
  const _StaggerScope({required this.controller, required this.slots, required super.child});

  final AnimationController controller;
  final int slots;

  static _StaggerScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_StaggerScope>();

  @override
  bool updateShouldNotify(_StaggerScope oldWidget) => controller != oldWidget.controller || slots != oldWidget.slots;
}

class StaggerItem extends StatelessWidget {
  const StaggerItem({super.key, required this.index, required this.child, this.distance = 28});

  final int index;
  final Widget child;
  final double distance;

  @override
  Widget build(BuildContext context) {
    final scope = _StaggerScope.maybeOf(context);
    if (scope == null) return child;

    final slot = index.clamp(0, scope.slots - 1);
    final total = (BobaMotion.entrance + BobaMotion.entranceStagger * (scope.slots - 1)).inMicroseconds;
    final start = (BobaMotion.entranceStagger * slot).inMicroseconds / total;
    final end = start + BobaMotion.entrance.inMicroseconds / total;
    final interval = Interval(start, end.clamp(0.0, 1.0));

    return AnimatedBuilder(
      animation: scope.controller,
      child: child,
      builder: (context, child) {
        final raw = interval.transform(scope.controller.value);
        final v = BobaMotion.signature.transform(raw);
        return Opacity(
          opacity: (raw * 2.5).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * distance),
            child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
          ),
        );
      },
    );
  }
}
