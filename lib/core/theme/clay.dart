import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// How a clay surface sits on the page.
enum ClayDepth {
  /// Puffy and lifted: soft tinted drop shadow, light top edge.
  raised,

  /// Pushed into the surface: inner shadow top-left, light bottom-right.
  pressed,

  /// No outer shadow, keeps the inner highlight.
  flat,
}

double _sigma(double blurRadius) => blurRadius * 0.57735 + 0.5;

/// Paints a claymorphism surface: tinted outer shadows plus inner highlights,
/// which `BoxShadow` cannot do because it has no inset mode.
class ClayPainter extends CustomPainter {
  const ClayPainter({
    this.color = BobaColors.surface,
    this.gradient,
    required this.borderRadius,
    this.depth = ClayDepth.raised,
    this.shadowColor = BobaColors.primary,
    this.elevation = 1,
  });

  final Color color;
  final Gradient? gradient;
  final BorderRadius borderRadius;
  final ClayDepth depth;
  final Color shadowColor;
  final double elevation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    if (depth == ClayDepth.raised && elevation > 0) {
      canvas.drawRRect(
        rrect.shift(Offset(0, 10 * elevation)),
        Paint()
          ..color = shadowColor.withValues(alpha: 0.16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(22 * elevation)),
      );
      canvas.drawRRect(
        rrect.shift(Offset(0, 2 * elevation)),
        Paint()
          ..color = BobaColors.ink.withValues(alpha: 0.06)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(5)),
      );
    }

    final body = Paint();
    if (gradient != null) {
      body.shader = gradient!.createShader(rect);
    } else {
      body.color = color;
    }
    canvas.drawRRect(rrect, body);

    canvas.save();
    canvas.clipRRect(rrect);
    if (depth == ClayDepth.pressed) {
      _innerShadow(canvas, rect, rrect, const Offset(2.5, 3), BobaColors.ink.withValues(alpha: 0.13), 6);
      _innerShadow(canvas, rect, rrect, const Offset(-2.5, -3), const Color(0xE6FFFFFF), 6);
    } else {
      _innerShadow(canvas, rect, rrect, const Offset(0, 2.5), const Color(0xCCFFFFFF), 3);
      _innerShadow(canvas, rect, rrect, const Offset(0, -3), BobaColors.ink.withValues(alpha: 0.06), 5);
    }
    canvas.restore();
  }

  /// Fills everything outside the shifted shape, so only a band along the
  /// opposite edge shows through the clip.
  void _innerShadow(Canvas canvas, Rect rect, RRect rrect, Offset offset, Color color, double blur) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(blur * 3 + offset.distance))
      ..addRRect(rrect.shift(offset));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(blur)),
    );
  }

  @override
  bool shouldRepaint(ClayPainter old) =>
      old.color != color ||
      old.gradient != gradient ||
      old.borderRadius != borderRadius ||
      old.depth != depth ||
      old.shadowColor != shadowColor ||
      old.elevation != elevation;
}

/// A container with a clay surface behind its child.
class ClayBox extends StatelessWidget {
  const ClayBox({
    super.key,
    this.child,
    this.color = BobaColors.surface,
    this.gradient,
    this.radius = BobaRadii.card,
    this.borderRadius,
    this.depth = ClayDepth.raised,
    this.shadowColor = BobaColors.primary,
    this.elevation = 1,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
  });

  final Widget? child;
  final Color color;
  final Gradient? gradient;
  final double radius;
  final BorderRadius? borderRadius;
  final ClayDepth depth;
  final Color shadowColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: ClayPainter(
          color: color,
          gradient: gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          depth: depth,
          shadowColor: shadowColor,
          elevation: elevation,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
