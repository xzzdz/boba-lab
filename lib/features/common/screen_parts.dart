import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';

/// Back button + centred title, for screens pushed over the tabs.
class BobaTopBar extends StatelessWidget {
  const BobaTopBar({super.key, required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          ClayIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: context.l10n.back,
            onPressed: onBack ?? () => context.canPop() ? context.pop() : context.go('/menu'),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.lottie = BobaLotties.emptyCup,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String lottie;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BobaLottie(lottie, size: 200, stillProgress: 0.25),
            const SizedBox(height: 8),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              body,
              style: text.bodyMedium!.copyWith(color: BobaColors.muted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[const SizedBox(height: 24), ClayButton(label: actionLabel!, onPressed: onAction, expand: false)],
          ],
        ),
      ),
    );
  }
}

/// The big code shown at the counter.
class PickupCodeCard extends StatelessWidget {
  const PickupCodeCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ClayBox(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_rounded, color: BobaColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.pickupCode, style: text.labelLarge)),
          Text(code, style: text.headlineMedium!.copyWith(color: BobaColors.primaryInk, letterSpacing: 2)),
        ],
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          title: message ?? l10n.pageNotFound,
          body: l10n.tagline,
          actionLabel: l10n.backToMenu,
          onAction: () => context.go('/menu'),
        ),
      ),
    );
  }
}
