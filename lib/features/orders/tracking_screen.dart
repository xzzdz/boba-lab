import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../common/screen_parts.dart';
import '../cup/cup_view.dart';

String statusLottie(OrderStatus status) => switch (status) {
  OrderStatus.received => BobaLotties.statusReceived,
  OrderStatus.brewing => BobaLotties.statusBrewing,
  OrderStatus.ready => BobaLotties.statusReady,
  OrderStatus.completed => BobaLotties.statusDone,
};

/// Puts every cup of an order back into the cart.
void reorder(BuildContext context, Order order) {
  final cart = AppScope.of(context).cart;
  for (final line in order.lines) {
    cart.add(line.config, quantity: line.quantity);
  }
  final l10n = context.l10n;
  BobaToast.show(context, l10n.addedToCart, actionLabel: l10n.viewCart, onAction: () => context.push('/cart'));
}

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: orders,
      builder: (context, _) {
        final order = orders.byNumber(number);
        if (order == null) return NotFoundScreen(message: l10n.orderNotFound);
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                BobaTopBar(title: l10n.orderNumber(order.number), onBack: () => context.canPop() ? context.pop() : context.go('/orders')),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 24),
                    children: [
                      _StatusHero(order: order),
                      const SizedBox(height: 18),
                      _Timeline(order: order),
                      const SizedBox(height: 18),
                      PickupCodeCard(code: order.pickupCode),
                      const SizedBox(height: 18),
                      ControlLabel(l10n.items),
                      _ItemsCard(order: order),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 8, BobaSpace.gutter, 16),
                  child: _Actions(order: order),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final status = order.status;
    return ClayBox(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: AnimatedSwitcher(
              duration: context.motion(BobaMotion.slow),
              switchInCurve: BobaMotion.signature,
              switchOutCurve: BobaMotion.exit,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(animation), child: child),
              ),
              child: BobaLottie(
                statusLottie(status),
                key: ValueKey(status),
                size: 150,
                repeat: status != OrderStatus.completed,
                stillProgress: status == OrderStatus.completed ? 1 : 0.5,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: context.motion(BobaMotion.standard),
            child: Column(
              key: ValueKey(status),
              children: [
                Text(l10n.statusTitle(status), style: text.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  l10n.statusBody(status),
                  style: text.bodyMedium!.copyWith(color: BobaColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (order.isActive) ...[
            const SizedBox(height: 10),
            Text(l10n.readyAround(clock(order.readyAt)), style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
          ],
        ],
      ),
    );
  }
}

/// Four steps; the line between dots fills as the order moves along.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final current = order.status.index;
    return ClayBox(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          for (final status in OrderStatus.values)
            SizedBox(
              // Fixed step height keeps the connector math simple and avoids intrinsic layout.
              height: status == OrderStatus.values.last ? 30 : 58,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        _StepDot(
                          done: status.index < current || order.status == OrderStatus.completed,
                          current: status.index == current && order.isActive,
                        ),
                        if (status != OrderStatus.values.last)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _Connector(filled: status.index < current),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.statusTitle(status),
                              style: text.labelLarge!.copyWith(color: status.index <= current ? BobaColors.ink : BobaColors.muted),
                            ),
                          ),
                          Text(order.statusTimes[status] == null ? '' : clock(order.statusTimes[status]!), style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.done, required this.current});

  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(BobaMotion.slow);
    return AnimatedScale(
      scale: current ? 1.15 : 1,
      duration: duration,
      curve: BobaMotion.signature,
      child: AnimatedContainer(
        duration: duration,
        curve: BobaMotion.fluid,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? BobaColors.success : (current ? BobaColors.primary : BobaColors.track),
          boxShadow: current ? [BoxShadow(color: BobaColors.primary.withValues(alpha: 0.35), blurRadius: 10)] : null,
        ),
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : current
            ? const Icon(Icons.more_horiz_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    // No LayoutBuilder here: the timeline row sizes itself with IntrinsicHeight.
    return Stack(
      children: [
        const Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 3,
              height: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(color: BobaColors.track, borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
            ),
          ),
        ),
        AnimatedFractionallySizedBox(
          duration: context.motion(BobaMotion.slow),
          curve: BobaMotion.fluid,
          alignment: Alignment.topCenter,
          heightFactor: filled ? 1 : 0,
          child: const SizedBox(
            width: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(color: BobaColors.success, borderRadius: BorderRadius.all(Radius.circular(2))),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return ClayBox(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CupView(config: line.config, height: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${line.quantity}× ${line.config.name(context.locale)}', style: text.labelLarge),
                        Text(l10n.cupDetails(line.config, context.locale), style: text.bodySmall),
                      ],
                    ),
                  ),
                  Text(baht(line.total), style: text.labelLarge),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: BobaColors.line),
          ),
          Row(
            children: [
              Expanded(child: Text(l10n.total, style: text.titleMedium)),
              Text(baht(order.total), style: text.titleLarge!.copyWith(color: BobaColors.primaryInk)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = AppScope.of(context).orders;
    return AnimatedSwitcher(
      duration: context.motion(BobaMotion.standard),
      child: switch (order.status) {
        OrderStatus.ready => ClayButton(
          key: const ValueKey('pickup'),
          label: l10n.pickedUp,
          icon: Icons.shopping_bag_rounded,
          onPressed: () => orders.pickUp(order.number),
        ),
        OrderStatus.completed => ClayButton(
          key: const ValueKey('again'),
          label: l10n.orderAgain,
          icon: Icons.replay_rounded,
          onPressed: () => reorder(context, order),
        ),
        _ => Row(
          key: const ValueKey('waiting'),
          children: [
            Expanded(
              child: Text(
                l10n.readyAround(clock(order.readyAt)),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: BobaColors.primaryInk),
              ),
            ),
            Pressable(
              onTap: () => orders.advance(order.number),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: BobaColors.track, borderRadius: BorderRadius.circular(18)),
                child: Text(l10n.demoNextStep, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: BobaColors.primaryInk)),
              ),
            ),
          ],
        ),
      },
    );
  }
}
