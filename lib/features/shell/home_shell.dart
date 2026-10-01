import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';
import '../../state/app_scope.dart';

/// Space tab screens leave at the bottom so content clears the nav bar.
const shellBottomSpace = 128.0;

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: shell),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CartBar(visible: shell.currentIndex == 0),
                  _NavBar(
                    index: shell.currentIndex,
                    onSelect: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.local_cafe_outlined, Icons.local_cafe_rounded, l10n.navMenu),
      (Icons.receipt_long_outlined, Icons.receipt_long_rounded, l10n.navOrders),
      (Icons.star_outline_rounded, Icons.stars_rounded, l10n.navRewards),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];
    return ClayBox(
      height: 70,
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: context.motion(BobaMotion.standard),
                curve: BobaMotion.signature,
                left: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: BobaColors.selectedTint, borderRadius: BorderRadius.all(Radius.circular(22))),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: items[i].$1,
                        selectedIcon: items[i].$2,
                        label: items[i].$3,
                        selected: i == index,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.selectedIcon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BobaColors.primary : BobaColors.muted;
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(22),
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: context.motion(BobaMotion.standard),
              curve: BobaMotion.signature,
              child: Icon(selected ? selectedIcon : icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: selected ? BobaColors.primaryInk : BobaColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// "2 cups · ฿140 · View cart", sliding up while the cart has something.
class _CartBar extends StatelessWidget {
  const _CartBar({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.of(context).cart;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final show = visible && !cart.isEmpty;
        return AnimatedSwitcher(
          duration: context.motion(BobaMotion.slow),
          reverseDuration: context.motion(BobaMotion.quick),
          switchInCurve: BobaMotion.fluid,
          switchOutCurve: BobaMotion.exit,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.bottomCenter,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: show
              ? _CartBarBody(key: const ValueKey('bar'), count: cart.cupCount, subtotal: cart.subtotal)
              : const SizedBox(key: ValueKey('none'), width: double.infinity),
        );
      },
    );
  }
}

class _CartBarBody extends StatelessWidget {
  const _CartBarBody({super.key, required this.count, required this.subtotal});

  final int count;
  final int subtotal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onTap: () => context.push('/cart'),
        scale: 0.96,
        semanticLabel: '${l10n.viewCart}, ${l10n.cupCount(count)}',
        child: ClayBox(
          height: 58,
          radius: 22,
          gradient: const LinearGradient(colors: [BobaColors.primary, BobaColors.pink]),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ExcludeSemantics(
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(l10n.cupCount(count), style: text),
                const SizedBox(width: 8),
                AnimatedBaht(subtotal, style: text.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                const Spacer(),
                Text(l10n.viewCart, style: text),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
