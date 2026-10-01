import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/stagger.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../common/screen_parts.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final order = AppScope.of(context).orders.byNumber(number);
    if (order == null) return NotFoundScreen(message: l10n.orderNotFound);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DriftingBlobs()),
          SafeArea(
            child: StaggerGroup(
              itemCount: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 16),
                child: Column(
                  children: [
                    const Spacer(),
                    const StaggerItem(index: 0, child: BobaLottie(BobaLotties.successCheck, size: 150, repeat: false)),
                    const SizedBox(height: 8),
                    StaggerItem(
                      index: 1,
                      child: Text(
                        order.payment == PaymentMethod.cash ? l10n.successTitleCash : l10n.successTitle,
                        style: text.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StaggerItem(
                      index: 2,
                      child: Text(
                        '${l10n.orderNumber(order.number)} · ${l10n.readyAround(clock(order.readyAt))}',
                        style: text.bodyMedium!.copyWith(color: BobaColors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    StaggerItem(index: 3, child: PickupCodeCard(code: order.pickupCode)),
                    const SizedBox(height: 14),
                    StaggerItem(index: 4, child: _StampsEarned(count: order.cups)),
                    const Spacer(),
                    StaggerItem(
                      index: 5,
                      child: Column(
                        children: [
                          ClayButton(
                            label: l10n.trackOrder,
                            icon: Icons.local_cafe_rounded,
                            onPressed: () => context.go('/track/${order.number}'),
                          ),
                          const SizedBox(height: 10),
                          ClayButton(label: l10n.backToMenu, tone: ClayButtonTone.light, height: 50, onPressed: () => context.go('/menu')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: BobaLottie(BobaLotties.confetti, repeat: false, stillProgress: 0, fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }
}

class _StampsEarned extends StatelessWidget {
  const _StampsEarned({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.go('/rewards'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: BobaColors.pinkSoft, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: BobaColors.pink, size: 20),
            const SizedBox(width: 8),
            Text(context.l10n.stampsEarned(count), style: Theme.of(context).textTheme.labelLarge!.copyWith(color: const Color(0xFF9D174D))),
          ],
        ),
      ),
    );
  }
}
