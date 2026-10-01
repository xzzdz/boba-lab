import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/stagger.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../cup/cup_view.dart';
import '../shell/home_shell.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: orders,
        builder: (context, _) {
          final active = orders.active;
          final past = orders.past;
          return StaggerGroup(
            itemCount: 4,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, shellBottomSpace),
              children: [
                StaggerItem(index: 0, child: Text(l10n.ordersTitle, style: Theme.of(context).textTheme.headlineSmall)),
                const SizedBox(height: 16),
                if (active != null) ...[
                  StaggerItem(index: 1, child: ControlLabel(l10n.activeOrder)),
                  StaggerItem(index: 1, child: _ActiveOrderCard(order: active)),
                  const SizedBox(height: 22),
                ],
                StaggerItem(index: 2, child: ControlLabel(l10n.pastOrders)),
                if (past.isEmpty) StaggerItem(index: 3, child: Text(l10n.noOrders, style: Theme.of(context).textTheme.bodyMedium)),
                for (final order in past)
                  StaggerItem(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PastOrderTile(order: order),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final steps = OrderStatus.values.length - 1;
    return Pressable(
      onTap: () => context.push('/track/${order.number}'),
      scale: 0.97,
      semanticLabel: '${l10n.statusTitle(order.status)}, ${l10n.orderNumber(order.number)}',
      borderRadius: BorderRadius.circular(BobaRadii.card),
      child: ExcludeSemantics(
        child: ClayBox(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              BobaLottie(statusLottie(order.status), size: 76, stillProgress: 0.5),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.statusTitle(order.status), style: text.titleMedium),
                    Text('${l10n.orderNumber(order.number)} · ${l10n.readyAround(clock(order.readyAt))}', style: text.bodySmall),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: order.status.index / steps),
                        duration: context.motion(BobaMotion.slow),
                        curve: BobaMotion.fluid,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          color: BobaColors.primary,
                          backgroundColor: BobaColors.track,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: BobaColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastOrderTile extends StatelessWidget {
  const _PastOrderTile({required this.order});

  final Order order;

  String _when(BuildContext context) {
    final l10n = context.l10n;
    final now = AppScope.of(context).clock();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(order.placedAt.year, order.placedAt.month, order.placedAt.day);
    final days = today.difference(day).inDays;
    final label = switch (days) {
      0 => l10n.today,
      1 => l10n.yesterday,
      _ => l10n.daysAgo(days),
    };
    return '$label · ${clock(order.placedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final names = order.lines.map((line) => line.config.name(context.locale)).join(', ');
    return ClayBox(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 64,
            child: Stack(
              children: [
                for (var i = 0; i < order.lines.length && i < 2; i++)
                  Positioned(
                    left: i * 26.0,
                    top: 0,
                    child: CupView(config: order.lines[i].config, height: 62),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_when(context), style: text.bodySmall),
                Text(names, style: text.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${l10n.cupCount(order.cups)} · ${baht(order.total)}', style: text.bodySmall),
              ],
            ),
          ),
          Pressable(
            onTap: () => reorder(context, order),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: BobaColors.selectedTint, borderRadius: BorderRadius.circular(16)),
              child: Text(l10n.orderAgain, style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
            ),
          ),
        ],
      ),
    );
  }
}
