import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../common/screen_parts.dart';
import '../cup/cup_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final cart = controllers.cart;
    final rewards = controllers.rewards;
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([cart, rewards]),
          builder: (context, _) {
            if (cart.isEmpty) {
              return Column(
                children: [
                  BobaTopBar(title: l10n.cartTitle),
                  Expanded(
                    child: EmptyState(
                      title: l10n.cartEmptyTitle,
                      body: l10n.cartEmptyBody,
                      actionLabel: l10n.browseMenu,
                      onAction: () => context.go('/menu'),
                    ),
                  ),
                ],
              );
            }
            final freeAvailable = rewards.freeCups > 0;
            final discount = cart.freeCupDiscount(available: freeAvailable);
            final total = cart.subtotal - discount;
            return Column(
              children: [
                BobaTopBar(title: '${l10n.cartTitle} · ${l10n.cupCount(cart.cupCount)}'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 24),
                    children: [
                      for (final line in cart.lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(line.id),
                            direction: DismissDirection.endToStart,
                            background: const _DeleteBackground(),
                            onDismissed: (_) {
                              final name = line.config.name(context.locale);
                              final removed = cart.remove(line.id);
                              if (removed == null) return;
                              BobaToast.show(
                                context,
                                l10n.removedItem(name),
                                icon: Icons.delete_outline_rounded,
                                actionLabel: l10n.undo,
                                onAction: () => cart.restore(removed.line, removed.index),
                              );
                            },
                            child: _CartLineTile(line: line),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ControlLabel(l10n.pickupTime),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final slot in PickupSlot.values)
                            FilterPill(
                              label: slot == PickupSlot.asap ? l10n.pickupAsap : l10n.pickupIn(slot.minutes),
                              selected: slot == cart.pickup,
                              onTap: () => cart.setPickup(slot),
                            ),
                        ],
                      ),
                      if (freeAvailable) ...[
                        const SizedBox(height: 18),
                        ClayBox(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard_rounded, color: BobaColors.pink),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.useFreeCup, style: Theme.of(context).textTheme.labelLarge),
                                    Text(l10n.freeCupsLeft(rewards.freeCups), style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              ClaySwitch(value: cart.useFreeCup, onChanged: cart.setUseFreeCup, semanticLabel: l10n.useFreeCup),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      TotalsCard(subtotal: cart.subtotal, discount: discount),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 8, BobaSpace.gutter, 16),
                  child: ClayButton(
                    label: l10n.goToCheckout,
                    icon: Icons.lock_rounded,
                    trailing: AnimatedBaht(total),
                    onPressed: () => context.push('/checkout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: BobaColors.dangerSoft, borderRadius: BorderRadius.circular(BobaRadii.card)),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 24),
          child: Icon(Icons.delete_outline_rounded, color: BobaColors.danger),
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final cart = AppScope.of(context).cart;
    final config = line.config;
    return ClayBox(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 84,
            decoration: BoxDecoration(color: config.tea.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(18)),
            alignment: Alignment.center,
            child: CupView(config: config, height: 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.name(context.locale), style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(l10n.cupDetails(config, context.locale), style: text.bodySmall, maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClayIconButton(
                      icon: Icons.remove_rounded,
                      size: 34,
                      semanticLabel: l10n.decreaseQuantity,
                      onPressed: () => cart.setQuantity(line.id, line.quantity - 1),
                    ),
                    SizedBox(
                      width: 34,
                      child: Semantics(
                        label: l10n.quantity(line.quantity),
                        child: ExcludeSemantics(
                          child: AnimatedSwitcher(
                            duration: context.motion(BobaMotion.standard),
                            switchInCurve: BobaMotion.signature,
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: Text(
                              '${line.quantity}',
                              key: ValueKey(line.quantity),
                              textAlign: TextAlign.center,
                              style: text.labelLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ClayIconButton(
                      icon: Icons.add_rounded,
                      size: 34,
                      semanticLabel: l10n.increaseQuantity,
                      onPressed: () => cart.setQuantity(line.id, line.quantity + 1),
                    ),
                    const Spacer(),
                    AnimatedBaht(line.total, style: text.labelLarge!.copyWith(color: BobaColors.primaryInk)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Drinks, free-cup discount and total.
class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.subtotal, required this.discount});

  final int subtotal;
  final int discount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget row(String label, Widget value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style ?? text.bodyMedium)),
          value,
        ],
      ),
    );
    return ClayBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          row(l10n.subtotal, AnimatedBaht(subtotal, style: text.bodyMedium)),
          if (discount > 0)
            row(
              l10n.discount,
              Text(
                '-${baht(discount)}',
                style: text.bodyMedium!.copyWith(color: BobaColors.successInk, fontWeight: FontWeight.w600),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: BobaColors.line),
          ),
          row(
            l10n.total,
            AnimatedBaht(subtotal - discount, style: text.titleLarge!.copyWith(color: BobaColors.primaryInk)),
            style: text.titleMedium,
          ),
        ],
      ),
    );
  }
}
