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
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../cart/cart_screen.dart';
import '../common/screen_parts.dart';
import 'qr_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _method = PaymentMethod.promptPay;
  bool _processing = false;

  Future<void> _pay(int total) async {
    final controllers = AppScope.of(context);
    final reduced = context.reduceMotion;
    if (_method == PaymentMethod.promptPay) {
      final paid = await showQrPayment(context, amount: total);
      if (paid != true || !mounted) return;
    }
    setState(() => _processing = true);
    await Future<void>.delayed(Duration(milliseconds: reduced ? 300 : 1800));
    if (!mounted) return;

    final cart = controllers.cart;
    final rewards = controllers.rewards;
    final discount = cart.freeCupDiscount(available: rewards.freeCups > 0);
    if (discount > 0) rewards.useFreeCup();
    final order = controllers.orders.place(
      lines: cart.lines,
      subtotal: cart.subtotal,
      discount: discount,
      payment: _method,
      pickupMinutes: cart.pickup.minutes,
    );
    rewards.addStamps(order.cups);
    cart.clear();
    if (mounted) context.go('/success/${order.number}');
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final cart = controllers.cart;
    final rewards = controllers.rewards;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([cart, rewards]),
          builder: (context, _) {
            if (cart.isEmpty && !_processing) {
              return Column(
                children: [
                  BobaTopBar(title: l10n.checkoutTitle),
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
            final discount = cart.freeCupDiscount(available: rewards.freeCups > 0);
            final total = cart.subtotal - discount;
            final readyAt = controllers.clock().add(Duration(minutes: cart.pickup.minutes));
            return Stack(
              children: [
                Column(
                  children: [
                    BobaTopBar(title: l10n.checkoutTitle),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 24),
                        children: [
                          ControlLabel(l10n.orderSummary),
                          ClayBox(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                for (final line in cart.lines)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 34,
                                          child: Text('${line.quantity}×', style: text.labelLarge!.copyWith(color: BobaColors.primaryInk)),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(line.config.name(context.locale), style: text.labelLarge),
                                              Text(l10n.cupDetails(line.config, context.locale), style: text.bodySmall),
                                            ],
                                          ),
                                        ),
                                        Text(baht(line.total), style: text.labelLarge),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          TotalsCard(subtotal: cart.subtotal, discount: discount),
                          const SizedBox(height: 22),
                          ControlLabel(l10n.pickupAt(l10n.storeName)),
                          ClayBox(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded, color: BobaColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.storeName, style: text.labelLarge),
                                      Text(l10n.storeAddress, style: text.bodySmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.readyAround(clock(readyAt)),
                                        style: text.labelMedium!.copyWith(color: BobaColors.primaryInk),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          ControlLabel(l10n.paymentMethod),
                          for (final method in PaymentMethod.values)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PaymentOption(
                                method: method,
                                selected: method == _method,
                                onTap: () => setState(() => _method = method),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 8, BobaSpace.gutter, 16),
                      child: ClayButton(
                        label: _method == PaymentMethod.cash ? l10n.placeOrder : l10n.payAmount(baht(total)),
                        icon: _method == PaymentMethod.cash ? Icons.storefront_rounded : Icons.lock_rounded,
                        onPressed: _processing ? null : () => _pay(total),
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_processing,
                    child: AnimatedOpacity(
                      opacity: _processing ? 1 : 0,
                      duration: context.motion(BobaMotion.standard),
                      child: ColoredBox(
                        color: BobaColors.background.withValues(alpha: 0.94),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_processing) const BobaLottie(BobaLotties.loadingPearls, width: 180, height: 72, stillProgress: 0.3),
                              const SizedBox(height: 12),
                              Text(_method == PaymentMethod.cash ? l10n.processingOrder : l10n.processingPayment, style: text.titleMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({required this.method, required this.selected, required this.onTap});

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final (icon, title, hint) = switch (method) {
      PaymentMethod.promptPay => (Icons.qr_code_2_rounded, l10n.payPromptPay, l10n.payPromptPayHint),
      PaymentMethod.card => (Icons.credit_card_rounded, l10n.payCard, l10n.payCardHint),
      PaymentMethod.cash => (Icons.payments_rounded, l10n.payCash, l10n.payCashHint),
    };
    final duration = context.motion(BobaMotion.standard);
    return Pressable(
      onTap: onTap,
      selected: selected,
      scale: 0.97,
      semanticLabel: '$title, $hint',
      borderRadius: BorderRadius.circular(BobaRadii.card),
      child: ExcludeSemantics(
        child: ClayBox(
          color: selected ? BobaColors.selectedTint : BobaColors.surface,
          depth: selected ? ClayDepth.pressed : ClayDepth.raised,
          elevation: 0.6,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: selected ? BobaColors.primary : BobaColors.track, shape: BoxShape.circle),
                child: Icon(icon, color: selected ? Colors.white : BobaColors.primaryInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.labelLarge),
                    Text(hint, style: text.bodySmall),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: duration,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? BobaColors.primary : BobaColors.line, width: 2),
                ),
                alignment: Alignment.center,
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: duration,
                  curve: BobaMotion.signature,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: BobaColors.primary, shape: BoxShape.circle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
