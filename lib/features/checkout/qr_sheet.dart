import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';

/// Shows a sample PromptPay QR. Resolves true when the visitor simulates a
/// successful payment, false or null when they close it.
Future<bool?> showQrPayment(BuildContext context, {required int amount}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.close,
    barrierColor: BobaColors.ink.withValues(alpha: 0.4),
    transitionDuration: context.motion(BobaMotion.page),
    pageBuilder: (context, animation, secondaryAnimation) => _QrSheet(amount: amount),
    transitionBuilder: (context, animation, secondaryAnimation, child) => AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final leaving = animation.status == AnimationStatus.reverse;
        final eased = leaving ? BobaMotion.exit.transform(animation.value) : BobaMotion.signature.transform(animation.value);
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionalTranslation(translation: Offset(0, 1 - eased), child: child),
        );
      },
    ),
  );
}

class _QrSheet extends StatefulWidget {
  const _QrSheet({required this.amount});

  final int amount;

  @override
  State<_QrSheet> createState() => _QrSheetState();
}

class _QrSheetState extends State<_QrSheet> {
  static const _validFor = Duration(minutes: 5);
  late final Timer _ticker;
  Duration _left = _validFor;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= Duration.zero) return;
      setState(() => _left -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final minutes = _left.inMinutes.toString().padLeft(2, '0');
    final seconds = (_left.inSeconds % 60).toString().padLeft(2, '0');
    return Material(
      type: MaterialType.transparency,
      child: ClayBox(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(BobaRadii.sheet)),
        depth: ClayDepth.flat,
        padding: EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 20 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: BobaColors.line, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 16),
            Text(l10n.qrTitle, style: text.titleLarge),
            const SizedBox(height: 4),
            Text(baht(widget.amount), style: text.headlineMedium!.copyWith(color: BobaColors.primaryInk)),
            const SizedBox(height: 16),
            ClayBox(
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 200,
                child: CustomPaint(painter: _SampleQrPainter(seed: widget.amount)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: BobaColors.muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(l10n.qrSample, style: text.bodySmall, textAlign: TextAlign.center),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.qrExpires('$minutes:$seconds'), style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
            const SizedBox(height: 18),
            ClayButton(label: l10n.qrSimulate, icon: Icons.check_circle_rounded, onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: 10),
            ClayButton(label: l10n.close, tone: ClayButtonTone.light, height: 48, onPressed: () => Navigator.of(context).pop(false)),
          ],
        ),
      ),
    );
  }
}

/// Looks like a QR code but encodes nothing: finder squares, timing rows and
/// seeded noise, with the cup in the middle.
class _SampleQrPainter extends CustomPainter {
  const _SampleQrPainter({required this.seed});

  final int seed;
  static const _modules = 29;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _modules;
    final ink = Paint()..color = BobaColors.ink;
    final random = math.Random(seed);

    bool inFinder(int x, int y) {
      bool near(int ox, int oy) => x >= ox - 1 && x <= ox + 7 && y >= oy - 1 && y <= oy + 7;
      return near(0, 0) || near(_modules - 7, 0) || near(0, _modules - 7);
    }

    bool inLogo(int x, int y) => (x - _modules ~/ 2).abs() <= 4 && (y - _modules ~/ 2).abs() <= 4;

    for (var y = 0; y < _modules; y++) {
      for (var x = 0; x < _modules; x++) {
        if (inFinder(x, y) || inLogo(x, y)) continue;
        final timing = (x == 6 || y == 6) && (x + y).isEven;
        if (timing || random.nextDouble() < 0.47) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x * cell + 0.5, y * cell + 0.5, cell - 1, cell - 1), Radius.circular(cell * 0.3)),
            ink,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final outer = Rect.fromLTWH(ox * cell, oy * cell, cell * 7, cell * 7);
      canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(cell * 1.6)), ink);
      canvas.drawRRect(RRect.fromRectAndRadius(outer.deflate(cell), Radius.circular(cell * 1.1)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(outer.deflate(cell * 2), Radius.circular(cell * 0.8)), Paint()..color = BobaColors.primary);
    }

    finder(0, 0);
    finder(_modules - 7, 0);
    finder(0, _modules - 7);

    final center = size.center(Offset.zero);
    canvas.drawCircle(center, cell * 4, Paint()..color = BobaColors.primary);
    final glyph = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final c = cell;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 1.7 * c, center.dy - 1.5 * c)
        ..lineTo(center.dx + 1.7 * c, center.dy - 1.5 * c)
        ..lineTo(center.dx + 1.25 * c, center.dy + 1.9 * c)
        ..lineTo(center.dx - 1.25 * c, center.dy + 1.9 * c)
        ..close(),
      glyph,
    );
    canvas.drawLine(Offset(center.dx + 0.5 * c, center.dy - 1.5 * c), Offset(center.dx + 1.1 * c, center.dy - 2.7 * c), glyph);
  }

  @override
  bool shouldRepaint(_SampleQrPainter oldDelegate) => oldDelegate.seed != seed;
}
