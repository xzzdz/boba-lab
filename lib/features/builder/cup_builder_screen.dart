import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../cup/cup_painter.dart';
import '../cup/cup_view.dart';

/// The hero screen: every choice changes the cup above it, live.
class CupBuilderScreen extends StatefulWidget {
  const CupBuilderScreen({super.key, required this.item});

  final MenuItem item;

  @override
  State<CupBuilderScreen> createState() => _CupBuilderScreenState();
}

class _CupBuilderScreenState extends State<CupBuilderScreen> {
  late CupConfig _config = widget.item.preset;
  final _cupKey = GlobalKey(debugLabel: 'builder cup');
  final _cartKey = GlobalKey(debugLabel: 'builder cart');
  bool _adding = false;

  void _update(CupConfig config) => setState(() => _config = config);

  Future<void> _addToCart() async {
    if (_adding) return;
    final controllers = AppScope.of(context);
    final l10n = context.l10n;
    final config = _config;
    final name = config.name(context.locale);
    setState(() => _adding = true);
    if (!context.reduceMotion) {
      await FlyToCart.fly(
        context,
        from: _cupKey,
        to: _cartKey,
        child: CupView(config: config, height: 200),
      );
    }
    if (!mounted) return;
    controllers.cart.add(config);
    setState(() => _adding = false);
    BobaToast.show(context, l10n.addedNamed(name), actionLabel: l10n.viewCart, onAction: () => context.push('/cart'), bottom: 100);
  }

  void _back() => context.canPop() ? context.pop() : context.go('/menu');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DriftingBlobs()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      ClayIconButton(icon: Icons.arrow_back_rounded, semanticLabel: l10n.back, onPressed: _back),
                      Expanded(
                        child: Text(l10n.builderTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      KeyedSubtree(
                        key: _cartKey,
                        child: CartButton(semanticLabel: l10n.cartTitle, onPressed: () => context.push('/cart')),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final height = (box.maxHeight - 24).clamp(110.0, 300.0);
                      return Center(
                        child: SizedBox(
                          key: _cupKey,
                          height: height,
                          width: height * CupGeometry.aspect,
                          child: Hero(
                            tag: 'cup-${widget.item.id}',
                            child: AnimatedCupView(config: _config),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _ControlSheet(item: widget.item, config: _config, onChanged: _update, onAdd: _adding ? null : _addToCart),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlSheet extends StatelessWidget {
  const _ControlSheet({required this.item, required this.config, required this.onChanged, required this.onAdd});

  final MenuItem item;
  final CupConfig config;
  final ValueChanged<CupConfig> onChanged;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final locale = context.locale;
    final media = MediaQuery.of(context);
    const sheetRadius = BorderRadius.vertical(top: Radius.circular(BobaRadii.sheet));

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.7),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: sheetRadius,
          boxShadow: [BoxShadow(color: BobaColors.primary.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, -8))],
        ),
        child: ClayBox(
          borderRadius: sheetRadius,
          depth: ClayDepth.flat,
          color: const Color(0xF7FFFFFF),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 22, BobaSpace.gutter, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _AnimatedName(config.name(locale))),
                          const SizedBox(width: 12),
                          AnimatedBaht(config.unitPrice, style: text.titleLarge!.copyWith(color: BobaColors.primaryInk)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(l10n.cupSummary(config, locale), style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
                      const SizedBox(height: 4),
                      Text(context.tr(item.blurb), style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      ControlLabel(
                        l10n.base,
                        trailing: Text(config.tea.name.of(locale), style: text.labelSmall!.copyWith(color: BobaColors.ink)),
                      ),
                      _FlavorRow(
                        selected: config.base,
                        onChanged: (base) => onChanged(config.copyWith(base: base)),
                      ),
                      const SizedBox(height: 12),
                      ControlLabel(l10n.size),
                      ClaySegmented<CupSize>(
                        values: CupSize.values,
                        selected: config.size,
                        label: l10n.sizeOption,
                        semanticLabel: l10n.size,
                        onChanged: (size) => onChanged(config.copyWith(size: size)),
                      ),
                      const SizedBox(height: 14),
                      ControlLabel(l10n.sweetness),
                      ClaySegmented<int>(
                        values: sweetnessLevels,
                        selected: config.sweetness,
                        label: (value) => '$value%',
                        semanticLabel: l10n.sweetness,
                        onChanged: (value) => onChanged(config.copyWith(sweetness: value)),
                      ),
                      const SizedBox(height: 14),
                      ControlLabel(l10n.ice),
                      ClaySegmented<IceLevel>(
                        values: IceLevel.values,
                        selected: config.ice,
                        label: l10n.iceOption,
                        semanticLabel: l10n.ice,
                        onChanged: (ice) => onChanged(config.copyWith(ice: ice)),
                      ),
                      const SizedBox(height: 14),
                      ControlLabel(l10n.toppings),
                      Row(
                        children: [
                          for (final topping in Catalog.toppings) ...[
                            if (topping != Catalog.toppings.first) const SizedBox(width: 8),
                            Expanded(
                              child: ToppingChip(
                                label: topping.name.of(locale),
                                price: topping.price,
                                selected: config.toppings.contains(topping.id),
                                onTap: () => onChanged(config.toggle(topping.id)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(BobaSpace.gutter, 10, BobaSpace.gutter, 14 + media.padding.bottom),
                child: ClayButton(
                  label: l10n.addToCart,
                  icon: Icons.shopping_bag_rounded,
                  trailing: AnimatedBaht(config.unitPrice),
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drink name that slides up into place when the cup becomes a new drink.
class _AnimatedName extends StatelessWidget {
  const _AnimatedName(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motion(BobaMotion.slow),
      reverseDuration: context.motion(BobaMotion.quick),
      switchInCurve: BobaMotion.signature,
      switchOutCurve: BobaMotion.exit,
      layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: Text(name, key: ValueKey(name), style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _FlavorRow extends StatelessWidget {
  const _FlavorRow({required this.selected, required this.onChanged});

  final BaseId selected;
  final ValueChanged<BaseId> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (final base in Catalog.bases) _FlavorDot(base: base, selected: base.id == selected, onTap: () => onChanged(base.id))],
    );
  }
}

class _FlavorDot extends StatelessWidget {
  const _FlavorDot({required this.base, required this.selected, required this.onTap});

  final TeaBase base;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(BobaMotion.standard);
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: base.name.of(context.locale),
      borderRadius: BorderRadius.circular(22),
      child: SizedBox.square(
        dimension: 46,
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.12 : 1,
            duration: duration,
            curve: BobaMotion.signature,
            child: AnimatedContainer(
              duration: duration,
              curve: BobaMotion.fluid,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  colors: [Color.lerp(base.color, Colors.white, 0.45)!, base.color],
                ),
                border: Border.all(color: selected ? BobaColors.primary : Colors.white, width: selected ? 3 : 2),
                boxShadow: [
                  BoxShadow(color: base.color.withValues(alpha: 0.45), blurRadius: selected ? 12 : 6, offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
