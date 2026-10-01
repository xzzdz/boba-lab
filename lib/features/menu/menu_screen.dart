import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/stagger.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../state/app_scope.dart';
import '../../state/rewards_controller.dart';
import '../cup/cup_view.dart';
import '../shell/home_shell.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MenuFilter _filter = MenuFilter.all;

  @override
  Widget build(BuildContext context) {
    final items = Catalog.menu.where((item) => item.matches(_filter)).toList();
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, 0),
            sliver: SliverToBoxAdapter(
              child: StaggerGroup(
                itemCount: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StaggerItem(index: 0, child: _Header()),
                    const SizedBox(height: 18),
                    const StaggerItem(index: 1, child: _PromoCard()),
                    const SizedBox(height: 22),
                    StaggerItem(
                      index: 2,
                      child: _FilterBar(selected: _filter, onChanged: (filter) => setState(() => _filter = filter)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 18, BobaSpace.gutter, shellBottomSpace + 72),
            // Re-keyed per filter so the new set of cards plays its entrance.
            sliver: StaggerGroup(
              key: ValueKey(_filter),
              itemCount: items.length.clamp(1, 8),
              child: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 262,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => StaggerItem(
                  index: index,
                  child: DrinkCard(item: items[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final hour = AppScope.of(context).clock().hour;
    final greeting = hour < 12 ? l10n.greetingMorning : (hour < 17 ? l10n.greetingAfternoon : l10n.greetingEvening);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: text.bodyMedium!.copyWith(color: BobaColors.muted)),
              Text(l10n.menuHeadline, style: text.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 18, color: BobaColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${l10n.storeName} · ${l10n.storeDistance}',
                      style: text.labelMedium!.copyWith(color: BobaColors.primaryInk),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CartButton(semanticLabel: l10n.cartTitle, onPressed: () => context.push('/cart')),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final rewards = AppScope.of(context).rewards;
    return Pressable(
      onTap: () => context.go('/rewards'),
      scale: 0.97,
      semanticLabel: '${l10n.promoTitle}. ${l10n.promoCta}',
      borderRadius: BorderRadius.circular(BobaRadii.card),
      child: ClayBox(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BobaColors.primary, Color(0xFFA855F7), BobaColors.pink],
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: rewards,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.promoTitle,
                        style: text.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _StampProgress(stamps: rewards.stamps),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.promoProgress(rewards.stamps)}  ·  ${l10n.promoCta} →',
                        style: text.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                      ),
                    ],
                  ),
                ),
              ),
              const CupView(
                config: CupConfig(base: BaseId.taro, toppings: {ToppingId.pearls}),
                height: 104,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampProgress extends StatelessWidget {
  const _StampProgress({required this.stamps});

  final int stamps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < RewardsController.cardSize; i++)
          Expanded(
            child: AnimatedContainer(
              duration: context.motion(BobaMotion.slow),
              curve: BobaMotion.fluid,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i < stamps ? Colors.white : Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final MenuFilter selected;
  final ValueChanged<MenuFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(MenuFilter filter) => switch (filter) {
      MenuFilter.all => l10n.filterAll,
      MenuFilter.tea => l10n.filterTea,
      MenuFilter.milk => l10n.filterMilk,
      MenuFilter.cheeseFoam => l10n.filterFoam,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.menuSection, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final filter in MenuFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterPill(label: label(filter), selected: filter == selected, onTap: () => onChanged(filter)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DrinkCard extends StatelessWidget {
  const DrinkCard({super.key, required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final config = item.preset;
    final name = config.name(context.locale);
    final tag = item.tag;
    return Pressable(
      onTap: () => context.push('/build/${item.id}'),
      scale: 0.96,
      semanticLabel: '$name, ${baht(config.unitPrice)}',
      borderRadius: BorderRadius.circular(BobaRadii.card),
      child: ClayBox(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: config.tea.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'cup-${item.id}',
                      child: CupView(config: config, height: 124),
                    ),
                  ),
                  if (tag != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _TagPill(label: l10n.tagLabel(tag), tag: tag),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ExcludeSemantics(
                child: Text(name, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(baht(config.unitPrice), style: text.labelLarge!.copyWith(color: BobaColors.primaryInk)),
                  ),
                ),
                _QuickAdd(item: item, name: name),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.tag});

  final String label;
  final MenuTag tag;

  @override
  Widget build(BuildContext context) {
    final color = switch (tag) {
      MenuTag.bestseller => BobaColors.pink,
      MenuTag.isNew => BobaColors.successInk,
      MenuTag.signature => BobaColors.primaryDeep,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.item, required this.name});

  final MenuItem item;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Pressable(
      onTap: () {
        AppScope.of(context).cart.add(item.preset);
        BobaToast.show(context, l10n.addedNamed(name), actionLabel: l10n.viewCart, onAction: () => context.push('/cart'), bottom: 160);
      },
      semanticLabel: l10n.quickAdd(name),
      borderRadius: BorderRadius.circular(18),
      child: const SizedBox.square(
        dimension: 38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BobaColors.primary, BobaColors.primaryDeep],
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x557C3AED), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
