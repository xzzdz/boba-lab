import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/motion/motion.dart';
import '../../data/models.dart';
import 'cup_painter.dart';

/// A cup at rest. Cheap enough for every menu card.
class CupView extends StatelessWidget {
  const CupView({super.key, required this.config, required this.height});

  final CupConfig config;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: height * CupGeometry.aspect,
        child: RepaintBoundary(child: CustomPaint(painter: StaticCupPainter(config))),
      ),
    );
  }
}

/// The cup on the builder screen. Each change animates only the part that
/// changed, with the Soft Clay tokens.
class AnimatedCupView extends StatefulWidget {
  const AnimatedCupView({super.key, required this.config});

  final CupConfig config;

  @override
  State<AnimatedCupView> createState() => _AnimatedCupViewState();
}

/// Shows or hides one part with its own controller. Entrances can wait for a
/// stagger delay; exits are quick and start from wherever the part is.
class _Track {
  _Track(TickerProvider vsync, {required bool visible})
    : controller = AnimationController(vsync: vsync, value: visible ? 1 : 0),
      _visible = visible;

  final AnimationController controller;
  bool _visible;
  bool _entering = true;
  double _delay = 0;

  bool get visible => _visible;
  bool get entering => _entering;
  double get value => controller.value;

  /// Linear entrance progress after the delay, 0–1.
  double get enterT => _delay >= 1 ? controller.value : Interval(_delay, 1).transform(controller.value);

  void show({required Duration duration, Duration delay = Duration.zero, required bool animate}) {
    if (_visible) return;
    _visible = true;
    _entering = true;
    if (!animate) {
      controller.value = 1;
      return;
    }
    final total = duration + delay;
    _delay = delay.inMicroseconds / total.inMicroseconds;
    controller.duration = total;
    controller.forward(from: 0);
  }

  void hide({required Duration duration, required bool animate}) {
    if (!_visible) return;
    _visible = false;
    _entering = false;
    if (!animate) {
      controller.value = 0;
      return;
    }
    controller.reverseDuration = duration;
    controller.reverse();
  }

  void dispose() => controller.dispose();
}

class _AnimatedCupViewState extends State<AnimatedCupView> with TickerProviderStateMixin {
  static const _pearlEach = Duration(milliseconds: 560);
  static const _jellyEach = BobaMotion.slow;

  late final AnimationController _liquid = AnimationController(vsync: this, duration: BobaMotion.slow, value: 1);
  late final AnimationController _syrup = AnimationController(vsync: this, duration: BobaMotion.slow, value: 1);
  late final AnimationController _size = AnimationController(vsync: this, duration: BobaMotion.slow, value: 1);
  late final AnimationController _slosh = AnimationController(vsync: this, duration: const Duration(milliseconds: 720));
  late final AnimationController _wave = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200), value: 0.5);

  late final List<_Track> _ice;
  late final _Track _pearls;
  late final _Track _jelly;
  late final _Track _pudding;
  late final _Track _foam;
  late final Listenable _repaint;

  late Color _liquidFrom;
  late Color _liquidTo;
  late double _streakFrom;
  late double _streakTo;
  late double _syrupFrom;
  late double _syrupTo;
  late double _sizeFrom;
  late double _sizeTo;
  bool _reduced = false;

  CupConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    final c = _config;
    _liquidFrom = _liquidTo = c.tea.color;
    _streakFrom = _streakTo = c.base == BaseId.brownSugar ? 1 : 0;
    _syrupFrom = _syrupTo = c.sweetness / 100;
    _sizeFrom = _sizeTo = c.size.scale;
    _ice = List.generate(CupGeometry.ice.length, (i) => _Track(this, visible: i < c.ice.cubes));
    _pearls = _Track(this, visible: c.toppings.contains(ToppingId.pearls));
    _jelly = _Track(this, visible: c.toppings.contains(ToppingId.grassJelly));
    _pudding = _Track(this, visible: c.toppings.contains(ToppingId.pudding));
    _foam = _Track(this, visible: c.toppings.contains(ToppingId.cheeseFoam));
    _repaint = Listenable.merge([
      _liquid,
      _syrup,
      _size,
      _slosh,
      _wave,
      for (final track in [..._ice, _pearls, _jelly, _pudding, _foam]) track.controller,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = context.reduceMotion;
    if (_reduced) {
      _wave
        ..stop()
        ..value = 0.5;
    } else if (!_wave.isAnimating) {
      _wave.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedCupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.config;
    final now = _config;
    final animate = !_reduced;

    if (before.base != now.base) {
      _liquidFrom = _currentLiquid;
      _streakFrom = _currentStreaks;
      _liquidTo = now.tea.color;
      _streakTo = now.base == BaseId.brownSugar ? 1 : 0;
      _restart(_liquid, BobaMotion.slow, animate);
      if (animate) _slosh.forward(from: 0);
    }
    if (before.sweetness != now.sweetness) {
      _syrupFrom = _currentSyrup;
      _syrupTo = now.sweetness / 100;
      _restart(_syrup, BobaMotion.slow, animate);
    }
    if (before.size != now.size) {
      _sizeFrom = _currentSize;
      _sizeTo = now.size.scale;
      _restart(_size, BobaMotion.slow, animate);
    }
    if (before.ice != now.ice) _updateIce(animate);

    _toggle(_pearls, now.toppings.contains(ToppingId.pearls), _groupDuration(_pearlEach, CupGeometry.pearls.length), animate);
    _toggle(_jelly, now.toppings.contains(ToppingId.grassJelly), _groupDuration(_jellyEach, CupGeometry.jelly.length), animate);
    _toggle(_pudding, now.toppings.contains(ToppingId.pudding), BobaMotion.slow, animate);
    _toggle(_foam, now.toppings.contains(ToppingId.cheeseFoam), BobaMotion.slow, animate);
  }

  Duration _groupDuration(Duration each, int count) => each + BobaMotion.stagger * (count - 1);

  void _restart(AnimationController controller, Duration duration, bool animate) {
    if (!animate) {
      controller.value = 1;
      return;
    }
    controller.duration = duration;
    controller.forward(from: 0);
  }

  void _toggle(_Track track, bool visible, Duration enter, bool animate) {
    if (visible) {
      track.show(duration: enter, animate: animate);
    } else {
      track.hide(duration: BobaMotion.quick, animate: animate);
    }
  }

  void _updateIce(bool animate) {
    final cubes = _config.ice.cubes;
    var queued = 0;
    for (var i = 0; i < _ice.length; i++) {
      if (i < cubes) {
        if (!_ice[i].visible) {
          _ice[i].show(duration: BobaMotion.slow, delay: BobaMotion.stagger * queued, animate: animate);
          queued++;
        }
      } else {
        _ice[i].hide(duration: BobaMotion.quick, animate: animate);
      }
    }
  }

  Color get _currentLiquid => Color.lerp(_liquidFrom, _liquidTo, BobaMotion.fluid.transform(_liquid.value))!;
  double get _currentStreaks => _lerp(_streakFrom, _streakTo, BobaMotion.fluid.transform(_liquid.value));
  double get _currentSyrup => _lerp(_syrupFrom, _syrupTo, BobaMotion.signature.transform(_syrup.value));
  double get _currentSize => _lerp(_sizeFrom, _sizeTo, BobaMotion.signature.transform(_size.value));

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  // ---- poses -------------------------------------------------------------

  /// Leaving parts rise a little and fade, accelerating away.
  static PartPose _leave(double value, double distance) {
    final e = BobaMotion.exit.transform(1 - value);
    return PartPose(dy: -distance * e, opacity: 1 - e);
  }

  PartPose _icePose(_Track track) {
    if (!track.entering) return _leave(track.value, 18);
    final t = track.enterT;
    if (t <= 0) return PartPose.hidden;
    final v = BobaMotion.signature.transform(t);
    return PartPose(dy: -34 * (1 - v), opacity: (t * 3).clamp(0.0, 1.0));
  }

  /// Local progress of item [i] inside a staggered group.
  double _groupT(_Track track, int i, Duration each, int count) {
    final total = _groupDuration(each, count).inMicroseconds;
    final start = (BobaMotion.stagger * i).inMicroseconds / total;
    final end = start + each.inMicroseconds / total;
    return Interval(start, end.clamp(0.0, 1.0)).transform(track.value);
  }

  /// Pearls fall with gravity, stretched, then squash on the floor and settle.
  PartPose _pearlPose(int i) {
    if (!_pearls.entering) return _leave(_pearls.value, 26);
    final t = _groupT(_pearls, i, _pearlEach, CupGeometry.pearls.length);
    if (t <= 0) return PartPose.hidden;
    const impact = 0.58;
    if (t < impact) {
      final p = BobaMotion.gravity.transform(t / impact);
      return PartPose(dy: -110 * (1 - p), scaleX: 0.9, scaleY: 1.12, opacity: (t * 8).clamp(0.0, 1.0));
    }
    final s = BobaMotion.signature.transform((t - impact) / (1 - impact));
    return PartPose(scaleX: 1 + 0.2 * (1 - s), scaleY: 1 - 0.2 * (1 - s));
  }

  PartPose _jellyPose(int i) {
    if (!_jelly.entering) return _leave(_jelly.value, 20);
    final t = _groupT(_jelly, i, _jellyEach, CupGeometry.jelly.length);
    if (t <= 0) return PartPose.hidden;
    final v = BobaMotion.signature.transform(t);
    return PartPose(dy: -50 * (1 - v), rotation: -0.35 * (1 - v), opacity: (t * 3).clamp(0.0, 1.0));
  }

  PartPose _puddingPose() {
    if (!_pudding.entering) {
      final e = BobaMotion.exit.transform(1 - _pudding.value);
      return PartPose(scaleY: 1 - e, opacity: 1 - e);
    }
    final t = _pudding.enterT;
    if (t <= 0) return PartPose.hidden;
    return PartPose(scaleY: BobaMotion.signature.transform(t), opacity: (t * 3).clamp(0.0, 1.0));
  }

  double _foamHeight() {
    if (!_foam.entering) return 1 - BobaMotion.exit.transform(1 - _foam.value);
    final t = _foam.enterT;
    return t <= 0 ? 0 : BobaMotion.signature.transform(t);
  }

  /// Tilt keyframes in degrees: 0 → -7 → 4 → -1.5 → 0, sine-eased between.
  double _sloshAngle() {
    if (!_slosh.isAnimating) return 0;
    const keys = <(double, double)>[(0, 0), (0.25, -7), (0.55, 4), (0.8, -1.5), (1, 0)];
    final t = _slosh.value;
    for (var k = 1; k < keys.length; k++) {
      final (t1, a1) = keys[k];
      if (t <= t1) {
        final (t0, a0) = keys[k - 1];
        final local = Curves.easeInOutSine.transform((t - t0) / (t1 - t0));
        return (a0 + (a1 - a0) * local) * math.pi / 180;
      }
    }
    return 0;
  }

  CupVisual _snapshot() {
    return CupVisual(
      liquid: _currentLiquid,
      syrup: _currentSyrup,
      streaks: _currentStreaks,
      ice: [for (final track in _ice) _icePose(track)],
      pearls: [for (var i = 0; i < CupGeometry.pearls.length; i++) _pearlPose(i)],
      jelly: [for (var i = 0; i < CupGeometry.jelly.length; i++) _jellyPose(i)],
      pudding: _puddingPose(),
      foam: _foamHeight(),
      slosh: _sloshAngle(),
      wave: Curves.easeInOutSine.transform(_wave.value) * 2 - 1,
      scale: _currentSize,
    );
  }

  @override
  void dispose() {
    for (final controller in [_liquid, _syrup, _size, _slosh, _wave]) {
      controller.dispose();
    }
    for (final track in [..._ice, _pearls, _jelly, _pudding, _foam]) {
      track.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(painter: _LiveCupPainter(_snapshot, _repaint), size: Size.infinite),
      ),
    );
  }
}

class _LiveCupPainter extends CustomPainter {
  _LiveCupPainter(this.snapshot, Listenable repaint) : super(repaint: repaint);

  final CupVisual Function() snapshot;

  @override
  void paint(Canvas canvas, Size size) => paintCup(canvas, size, snapshot());

  @override
  bool shouldRepaint(_LiveCupPainter oldDelegate) => true;
}
