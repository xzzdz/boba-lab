import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/theme/tokens.dart';
import '../../data/models.dart';

/// Where one cup part (an ice cube, a pearl…) is, relative to its resting spot.
@immutable
class PartPose {
  const PartPose({this.dy = 0, this.scaleX = 1, this.scaleY = 1, this.rotation = 0, this.opacity = 1});

  static const rest = PartPose();
  static const hidden = PartPose(opacity: 0);

  final double dy;
  final double scaleX;
  final double scaleY;

  /// Radians, added to the part's own resting angle.
  final double rotation;
  final double opacity;

  bool get visible => opacity > 0.001;
}

/// Everything the painter needs for one frame of the cup.
@immutable
class CupVisual {
  const CupVisual({
    required this.liquid,
    required this.syrup,
    required this.streaks,
    required this.ice,
    required this.pearls,
    required this.jelly,
    required this.pudding,
    required this.foam,
    this.slosh = 0,
    this.wave = 0,
    this.scale = 1,
  });

  /// The cup at rest for [config], with nothing moving.
  factory CupVisual.resting(CupConfig config) {
    PartPose show(bool on) => on ? PartPose.rest : PartPose.hidden;
    final toppings = config.toppings;
    return CupVisual(
      liquid: config.tea.color,
      syrup: config.sweetness / 100,
      streaks: config.base == BaseId.brownSugar ? 1 : 0,
      ice: List.generate(CupGeometry.ice.length, (i) => show(i < config.ice.cubes)),
      pearls: List.filled(CupGeometry.pearls.length, show(toppings.contains(ToppingId.pearls))),
      jelly: List.filled(CupGeometry.jelly.length, show(toppings.contains(ToppingId.grassJelly))),
      pudding: show(toppings.contains(ToppingId.pudding)),
      foam: toppings.contains(ToppingId.cheeseFoam) ? 1 : 0,
      scale: config.size.scale,
    );
  }

  final Color liquid;

  /// Sweetness, 0–1, drawn as syrup settling at the bottom. May overshoot.
  final double syrup;

  /// Brown sugar streaks down the inside wall, 0–1.
  final double streaks;
  final List<PartPose> ice;
  final List<PartPose> pearls;
  final List<PartPose> jelly;

  /// Uses [PartPose.scaleY] to rise from the bottom.
  final PartPose pudding;

  /// Cheese foam height, 0–1. May overshoot.
  final double foam;

  /// Liquid tilt in radians.
  final double slosh;

  /// Liquid surface sway, -1–1.
  final double wave;

  /// Cup size, relative to large.
  final double scale;
}

/// Cup drawing in a 180 × 200 design box, shared by the painter and tests.
abstract final class CupGeometry {
  static const width = 180.0;
  static const height = 200.0;
  static const aspect = width / height;

  static final Path body = Path()
    ..moveTo(32, 34)
    ..lineTo(148, 34)
    ..lineTo(136.5, 184)
    ..quadraticBezierTo(136, 192, 128, 192)
    ..lineTo(52, 192)
    ..quadraticBezierTo(44, 192, 43.5, 184)
    ..close();

  static final Path inside = Path()
    ..moveTo(35, 36.5)
    ..lineTo(145, 36.5)
    ..lineTo(133.8, 183)
    ..quadraticBezierTo(133.3, 189.5, 127, 189.5)
    ..lineTo(53, 189.5)
    ..quadraticBezierTo(46.7, 189.5, 46.2, 183)
    ..close();

  /// Liquid with a wavy surface, wider than the cup so it can sway.
  static final Path liquid = () {
    final path = Path()..moveTo(-40, 54);
    var x = -40.0;
    var up = true;
    while (x < 220) {
      path.quadraticBezierTo(x + 7.5, up ? 49.5 : 58.5, x + 15, 54);
      up = !up;
      x += 15;
    }
    return path
      ..lineTo(x, 205)
      ..lineTo(-40, 205)
      ..close();
  }();

  /// Cheese foam cap with a scalloped bottom edge.
  static final Path foam = () {
    final path = Path()
      ..moveTo(-10, 30)
      ..lineTo(190, 30)
      ..lineTo(190, 60);
    var x = 190.0;
    var down = true;
    while (x > -10) {
      path.quadraticBezierTo(x - 7.5, down ? 66 : 54, x - 15, 60);
      down = !down;
      x -= 15;
    }
    return path..close();
  }();

  static final List<Path> streaks = [
    Path()
      ..moveTo(50, 62)
      ..cubicTo(60, 92, 44, 120, 56, 176),
    Path()
      ..moveTo(130, 64)
      ..cubicTo(120, 96, 136, 126, 124, 178),
    Path()
      ..moveTo(92, 70)
      ..cubicTo(100, 100, 84, 128, 94, 160),
  ];

  static const pearls = <Offset>[
    Offset(57, 183), Offset(70, 184), Offset(83, 184.5), Offset(96, 184.5), Offset(109, 184), Offset(122, 183), //
    Offset(63.5, 172), Offset(76.5, 172.5), Offset(89.5, 173), Offset(102.5, 172.5), Offset(115.5, 172), //
    Offset(82, 161.5), Offset(97, 161.5),
  ];

  static const ice = <({double x, double y, double degrees})>[
    (x: 54, y: 57, degrees: -12),
    (x: 84, y: 52, degrees: 9),
    (x: 110, y: 59, degrees: -6),
    (x: 66, y: 78, degrees: 14),
    (x: 96, y: 82, degrees: -9),
    (x: 116, y: 77, degrees: 7),
  ];

  static const jelly = <Offset>[Offset(62, 141), Offset(88, 147), Offset(111, 138), Offset(75, 124)];

  static const pearlRadius = 6.3;
}

const _white = Color(0xFFFFFFFF);

/// Draws one frame of the cup into [size], bottom-aligned and centred.
void paintCup(Canvas canvas, Size size, CupVisual v) {
  final fit = math.min(size.width / CupGeometry.width, size.height / CupGeometry.height);
  canvas.save();
  canvas.translate((size.width - CupGeometry.width * fit) / 2, size.height - CupGeometry.height * fit);
  canvas.scale(fit);

  // Size change grows the cup from its base.
  canvas.translate(90, 196);
  canvas.scale(v.scale);
  canvas.translate(-90, -196);

  canvas.drawPath(
    CupGeometry.body.shift(const Offset(0, 9)),
    Paint()
      ..color = BobaColors.primary.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
  );

  canvas.save();
  canvas.clipPath(CupGeometry.inside);
  canvas.translate(90, 120);
  canvas.rotate(v.slosh);
  canvas.translate(-90, -120);

  canvas.save();
  canvas.translate(v.wave * 7.5, 0);
  canvas.drawPath(CupGeometry.liquid, Paint()..color = v.liquid);
  canvas.restore();

  if (v.streaks > 0.001) {
    final streak = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = BobaColors.syrup.withValues(alpha: 0.42 * v.streaks.clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final path in CupGeometry.streaks) {
      canvas.drawPath(path, streak);
    }
  }

  if (v.syrup > 0.001) {
    const area = Rect.fromLTWH(0, 128, 180, 64);
    canvas.save();
    canvas.translate(0, 192);
    canvas.scale(1, v.syrup);
    canvas.translate(0, -192);
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BobaColors.syrup.withValues(alpha: 0),
            BobaColors.syrup.withValues(alpha: 0.55),
            BobaColors.syrupDeep.withValues(alpha: 0.9),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(area),
    );
    canvas.restore();
  }

  _pudding(canvas, v.pudding);
  for (var i = 0; i < CupGeometry.jelly.length; i++) {
    _jelly(canvas, CupGeometry.jelly[i], v.jelly[i]);
  }
  for (var i = 0; i < CupGeometry.pearls.length; i++) {
    _pearl(canvas, CupGeometry.pearls[i], v.pearls[i]);
  }
  for (var i = 0; i < CupGeometry.ice.length; i++) {
    _ice(canvas, CupGeometry.ice[i], v.ice[i]);
  }
  _foam(canvas, v.foam);
  canvas.restore();

  // Frosted plastic over the drink, then rim, lid and straw.
  canvas.drawPath(CupGeometry.body, Paint()..color = _white.withValues(alpha: 0.3));
  canvas.drawPath(
    CupGeometry.body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = BobaColors.primary.withValues(alpha: 0.25),
  );
  canvas.drawLine(
    const Offset(44, 48),
    const Offset(52.5, 172),
    Paint()
      ..color = _white.withValues(alpha: 0.6)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawRRect(RRect.fromLTRBR(28.5, 28.5, 151.5, 35.5, const Radius.circular(3.5)), Paint()..color = BobaColors.lid);
  canvas.drawLine(
    const Offset(112, 4),
    const Offset(96, 150),
    Paint()
      ..color = BobaColors.straw
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawLine(
    const Offset(109.5, 10),
    const Offset(99, 108),
    Paint()
      ..color = _white.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round,
  );
  canvas.restore();
}

void _pearl(Canvas canvas, Offset center, PartPose pose) {
  if (!pose.visible) return;
  const r = CupGeometry.pearlRadius;
  canvas.save();
  // Scale around the pearl's bottom so it squashes onto the cup floor.
  canvas.translate(center.dx, center.dy + r + pose.dy);
  canvas.scale(pose.scaleX, pose.scaleY);
  canvas.drawCircle(const Offset(0, -r), r, Paint()..color = BobaColors.pearl.withValues(alpha: pose.opacity));
  canvas.drawCircle(const Offset(-2, -r - 2.2), 1.7, Paint()..color = _white.withValues(alpha: 0.45 * pose.opacity));
  canvas.restore();
}

void _ice(Canvas canvas, ({double x, double y, double degrees}) cube, PartPose pose) {
  if (!pose.visible) return;
  canvas.save();
  canvas.translate(cube.x + 9.5, cube.y + 9.5 + pose.dy);
  canvas.rotate(cube.degrees * math.pi / 180 + pose.rotation);
  canvas.scale(pose.scaleX, pose.scaleY);
  final shape = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 19, height: 19), const Radius.circular(4.5));
  canvas.drawRRect(shape, Paint()..color = _white.withValues(alpha: 0.55 * pose.opacity));
  canvas.drawRRect(
    shape,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _white.withValues(alpha: 0.9 * pose.opacity),
  );
  canvas.drawLine(
    const Offset(-5, -5),
    const Offset(-1, -6),
    Paint()
      ..color = _white.withValues(alpha: 0.9 * pose.opacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round,
  );
  canvas.restore();
}

void _jelly(Canvas canvas, Offset topLeft, PartPose pose) {
  if (!pose.visible) return;
  canvas.save();
  canvas.translate(topLeft.dx + 7.5, topLeft.dy + 7.5 + pose.dy);
  canvas.rotate(pose.rotation);
  canvas.scale(pose.scaleX, pose.scaleY);
  final shape = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 15, height: 15), const Radius.circular(3.5));
  canvas.drawRRect(shape, Paint()..color = BobaColors.jelly.withValues(alpha: 0.92 * pose.opacity));
  canvas.drawLine(
    const Offset(-4, -4),
    const Offset(0, -4.5),
    Paint()
      ..color = _white.withValues(alpha: 0.3 * pose.opacity)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round,
  );
  canvas.restore();
}

void _pudding(Canvas canvas, PartPose pose) {
  if (!pose.visible) return;
  canvas.save();
  canvas.translate(0, 189.5);
  canvas.scale(1, pose.scaleY);
  canvas.translate(0, -189.5);
  final body = RRect.fromLTRBR(48, 164, 132, 189.5, const Radius.circular(9));
  canvas.drawRRect(body, Paint()..color = BobaColors.pudding.withValues(alpha: pose.opacity));
  canvas.save();
  canvas.clipRRect(body);
  canvas.drawRect(const Rect.fromLTRB(48, 164, 132, 170), Paint()..color = BobaColors.puddingTop.withValues(alpha: 0.85 * pose.opacity));
  canvas.restore();
  canvas.restore();
}

void _foam(Canvas canvas, double height) {
  if (height <= 0.001) return;
  canvas.save();
  canvas.translate(0, 30);
  canvas.scale(1, height);
  canvas.translate(0, -30);
  canvas.drawPath(CupGeometry.foam, Paint()..color = BobaColors.foam);
  final bubble = Paint()..color = const Color(0xFFF2DDB4);
  for (final spot in const [Offset(46, 44), Offset(72, 49), Offset(101, 42), Offset(128, 48), Offset(146, 41)]) {
    canvas.drawCircle(spot, 2, bubble);
  }
  canvas.restore();
}

/// Paints a resting cup for [config]. Used for menu cards and cart rows.
class StaticCupPainter extends CustomPainter {
  StaticCupPainter(this.config) : _visual = CupVisual.resting(config);

  final CupConfig config;
  final CupVisual _visual;

  @override
  void paint(Canvas canvas, Size size) => paintCup(canvas, size, _visual);

  @override
  bool shouldRepaint(StaticCupPainter oldDelegate) => oldDelegate.config != config;
}
