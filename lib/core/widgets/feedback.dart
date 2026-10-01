import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../state/cart_controller.dart';
import '../motion/motion.dart';
import '../motion/pressable.dart';
import '../theme/clay.dart';
import '../theme/tokens.dart';
import 'clay_controls.dart';

/// Short confirmation that bounces up from the bottom, waits, then drops away.
abstract final class BobaToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData icon = Icons.check_circle_rounded,
    double bottom = 24,
  }) {
    dismiss();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        icon: icon,
        bottom: bottom,
        reduced: context.reduceMotion,
        onDone: () {
          if (_entry == entry) _entry = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final entry = _entry;
    _entry = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.icon,
    required this.bottom,
    required this.reduced,
    required this.onDone,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final double bottom;
  final bool reduced;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 2600);
  static const _enterEnd = 400 / 2600;
  static const _exitStart = 1 - 150 / 2600;

  late final AnimationController _controller = AnimationController(vsync: this, duration: _total)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Positioned(
      left: 16,
      right: 16,
      bottom: widget.bottom + MediaQuery.paddingOf(context).bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          var dy = 0.0;
          var opacity = 1.0;
          var scale = 1.0;
          if (!widget.reduced && t < _enterEnd) {
            final v = BobaMotion.signature.transform(t / _enterEnd);
            dy = (1 - v) * 24;
            scale = 0.95 + 0.05 * v;
            opacity = (t / _enterEnd * 2).clamp(0.0, 1.0);
          } else if (t > _exitStart) {
            final e = BobaMotion.exit.transform((t - _exitStart) / (1 - _exitStart));
            dy = widget.reduced ? 0 : e * 12;
            opacity = 1 - e;
          }
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Semantics(
          liveRegion: true,
          child: ClayBox(
            color: BobaColors.ink,
            radius: 18,
            shadowColor: BobaColors.ink,
            elevation: 0.7,
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Icon(widget.icon, color: const Color(0xFF6EE7B7), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.message, style: text.labelLarge!.copyWith(color: Colors.white, fontSize: 14)),
                ),
                if (widget.actionLabel != null)
                  Pressable(
                    onTap: () {
                      widget.onAction?.call();
                      BobaToast.dismiss();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(widget.actionLabel!, style: text.labelLarge!.copyWith(color: BobaColors.lid, fontSize: 14)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Throws a copy of a widget along an arc into the cart button.
abstract final class FlyToCart {
  static Future<void> fly(BuildContext context, {required GlobalKey from, required GlobalKey to, required Widget child}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
    final toBox = to.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || overlayBox == null || fromBox == null || toBox == null) return Future.value();

    final start = fromBox.localToGlobal(fromBox.size.center(Offset.zero), ancestor: overlayBox);
    final end = toBox.localToGlobal(toBox.size.center(Offset.zero), ancestor: overlayBox);
    final done = Completer<void>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Flight(
        start: start,
        end: end,
        size: fromBox.size,
        endHeight: 28,
        onDone: () {
          if (entry.mounted) entry.remove();
          if (!done.isCompleted) done.complete();
        },
        child: child,
      ),
    );
    overlay.insert(entry);
    return done.future;
  }
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.start,
    required this.end,
    required this.size,
    required this.endHeight,
    required this.onDone,
    required this.child,
  });

  final Offset start;
  final Offset end;
  final Size size;
  final double endHeight;
  final VoidCallback onDone;
  final Widget child;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 620))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.start;
    final end = widget.end;
    // Arc peaks above both points, like a toss.
    final control = Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy) - 120);
    final endScale = widget.endHeight / widget.size.height;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        child: SizedBox.fromSize(size: widget.size, child: widget.child),
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          final u = 1 - t;
          final p = start * (u * u) + control * (2 * u * t) + end * (t * t);
          final scale = 1 + (endScale - 1) * BobaMotion.fluid.transform(_controller.value);
          return Stack(
            children: [
              Positioned(
                left: p.dx - widget.size.width / 2,
                top: p.dy - widget.size.height / 2,
                child: Transform.rotate(
                  angle: 0.7 * t,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cart icon with a count badge. Bounces whenever cups arrive.
class CartButton extends StatefulWidget {
  const CartButton({super.key, required this.onPressed, required this.semanticLabel});

  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  CartController? _cart;
  int _count = 0;

  static final _bounce = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.24).chain(CurveTween(curve: Curves.easeOut)), weight: 28),
    TweenSequenceItem(tween: Tween<double>(begin: 1.24, end: 0.92).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1).chain(CurveTween(curve: BobaMotion.signature)), weight: 42),
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cart != null) return;
    _cart = AppScope.of(context).cart..addListener(_onCart);
    _count = _cart!.cupCount;
  }

  void _onCart() {
    final count = _cart!.cupCount;
    if (count > _count && !context.reduceMotion) _bump.forward(from: 0);
    setState(() => _count = count);
  }

  @override
  void dispose() {
    _cart?.removeListener(_onCart);
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bump,
      builder: (context, child) => Transform.scale(scale: _bounce.transform(_bump.value), child: child),
      child: ClayIconButton(
        icon: Icons.shopping_bag_rounded,
        semanticLabel: widget.semanticLabel,
        onPressed: widget.onPressed,
        badge: _count > 0 ? CountBadge(_count) : null,
      ),
    );
  }
}

/// Soft lavender and pink blobs that drift slowly behind content.
class DriftingBlobs extends StatefulWidget {
  const DriftingBlobs({super.key, this.blobs = defaultBlobs});

  final List<({Alignment at, double size, Color color})> blobs;

  static const defaultBlobs = <({Alignment at, double size, Color color})>[
    (at: Alignment(-0.9, -0.75), size: 240, color: BobaColors.primarySoft),
    (at: Alignment(1, -0.2), size: 200, color: BobaColors.pinkSoft),
    (at: Alignment(-0.6, 0.85), size: 180, color: Color(0xFFE9DFFD)),
  ];

  @override
  State<DriftingBlobs> createState() => _DriftingBlobsState();
}

class _DriftingBlobsState extends State<DriftingBlobs> with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _BlobPainter(widget.blobs, _drift), size: Size.infinite),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.blobs, this.drift) : super(repaint: drift);

  final List<({Alignment at, double size, Color color})> blobs;
  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = Curves.easeInOutSine.transform(drift.value) * math.pi;
    for (var i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      final center = blob.at.alongSize(size) + Offset(math.cos(phase + i * 2) * 14, math.sin(phase + i * 2) * 10);
      canvas.drawCircle(
        center,
        blob.size / 2,
        Paint()
          ..color = blob.color.withValues(alpha: 0.75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.blobs != blobs;
}
