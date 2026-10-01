import 'package:flutter/material.dart';

import '../format.dart';
import '../motion/motion.dart';
import '../motion/pressable.dart';
import '../theme/clay.dart';
import '../theme/tokens.dart';

const _violet = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [BobaColors.primary, BobaColors.primaryDeep],
);

enum ClayButtonTone { primary, light }

/// The main call to action: a puffy violet clay button.
class ClayButton extends StatelessWidget {
  const ClayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.tone = ClayButtonTone.primary,
    this.height = 56,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? trailing;
  final ClayButtonTone tone;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final primary = tone == ClayButtonTone.primary;
    final foreground = primary ? Colors.white : BobaColors.primaryInk;
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(color: foreground, fontSize: 16);
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Pressable(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(BobaRadii.button),
        child: SizedBox(
          height: height,
          width: expand ? double.infinity : null,
          child: CustomPaint(
            painter: ClayPainter(
              gradient: primary ? _violet : null,
              borderRadius: BorderRadius.circular(BobaRadii.button),
              elevation: primary ? 1 : 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: foreground, size: 20), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), DefaultTextStyle.merge(style: textStyle, child: trailing!)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round clay button with an icon, e.g. back or cart.
class ClayIconButton extends StatelessWidget {
  const ClayIconButton({super.key, required this.icon, required this.onPressed, required this.semanticLabel, this.size = 44, this.badge});

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: ClayPainter(borderRadius: radius, elevation: 0.7)),
            ),
            Center(child: Icon(icon, size: 22, color: BobaColors.ink)),
            if (badge != null) Positioned(top: -5, right: -5, child: badge!),
          ],
        ),
      ),
    );
  }
}

/// Pink count pill; the number pops when it changes.
class CountBadge extends StatelessWidget {
  const CountBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minWidth: 20),
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: BobaColors.pink,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: context.motion(BobaMotion.standard),
          switchInCurve: BobaMotion.signature,
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Text(
            '$count',
            key: ValueKey(count),
            style: const TextStyle(fontFamily: 'Anuphan', fontWeight: FontWeight.w600, fontSize: 11, height: 1, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Segmented control whose violet thumb slides with the signature overshoot.
class ClaySegmented<T> extends StatelessWidget {
  const ClaySegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.semanticLabel,
    this.height = 40,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    const inset = 3.0;
    final index = values.indexOf(selected);
    final radius = BorderRadius.circular(height / 2);
    final style = Theme.of(context).textTheme.labelMedium!;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: CustomPaint(
          painter: ClayPainter(color: BobaColors.track, depth: ClayDepth.pressed, borderRadius: radius),
          child: LayoutBuilder(
            builder: (context, box) {
              final width = (box.maxWidth - inset * 2) / values.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: context.motion(BobaMotion.standard),
                    curve: BobaMotion.signature,
                    left: inset + width * index,
                    top: inset,
                    bottom: inset,
                    width: width,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _violet,
                        borderRadius: BorderRadius.circular(height / 2 - inset),
                        boxShadow: [
                          BoxShadow(color: BobaColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final value in values)
                        Expanded(
                          child: Pressable(
                            onTap: () => onChanged(value),
                            selected: value == selected,
                            scale: 0.94,
                            borderRadius: radius,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: context.motion(BobaMotion.standard),
                                style: style.copyWith(color: value == selected ? Colors.white : BobaColors.muted),
                                child: Text(label(value), maxLines: 1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Toggle chip: raised when off, pressed into the surface when on.
class ToppingChip extends StatelessWidget {
  const ToppingChip({super.key, required this.label, required this.price, required this.selected, required this.onTap});

  final String label;
  final int price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(BobaRadii.chip);
    return Pressable(
      onTap: onTap,
      selected: selected,
      borderRadius: radius,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: context.motion(BobaMotion.standard),
        curve: BobaMotion.fluid,
        builder: (context, t, child) => CustomPaint(
          painter: ClayPainter(
            color: Color.lerp(BobaColors.surface, BobaColors.selectedTint, t)!,
            depth: t > 0.5 ? ClayDepth.pressed : ClayDepth.raised,
            elevation: 0.5 * (1 - t),
            borderRadius: radius,
          ),
          child: child,
        ),
        child: SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            // Long names ("Cheese foam") shrink to fit rather than get cut off.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(label, style: text.labelMedium!.copyWith(color: selected ? BobaColors.primaryInk : BobaColors.ink), maxLines: 1),
                  Text('+${baht(price)}', style: text.labelSmall!.copyWith(color: selected ? BobaColors.primaryInk : BobaColors.muted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Category pill for the menu filter.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Pressable(
      onTap: onTap,
      selected: selected,
      borderRadius: radius,
      child: AnimatedScale(
        scale: selected ? 1 : 0.96,
        duration: context.motion(BobaMotion.standard),
        curve: BobaMotion.signature,
        child: AnimatedContainer(
          duration: context.motion(BobaMotion.standard),
          curve: BobaMotion.fluid,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: selected ? _violet : null,
            color: selected ? null : BobaColors.surface,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: BobaColors.primary.withValues(alpha: selected ? 0.32 : 0.1),
                blurRadius: selected ? 14 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // widthFactor 1: hug the label instead of filling a Wrap row.
          child: Align(
            widthFactor: 1,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: selected ? Colors.white : BobaColors.ink)),
          ),
        ),
      ),
    );
  }
}

/// On/off switch with a clay track and a springy knob.
class ClaySwitch extends StatelessWidget {
  const ClaySwitch({super.key, required this.value, required this.onChanged, required this.semanticLabel});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(BobaMotion.standard);
    return Semantics(
      toggled: value,
      child: Pressable(
        onTap: () => onChanged(!value),
        semanticLabel: semanticLabel,
        scale: 0.95,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 54,
          height: 32,
          child: Stack(
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: value ? BobaColors.primary : BobaColors.track),
                  duration: duration,
                  builder: (context, color, _) => CustomPaint(
                    painter: ClayPainter(color: color!, depth: ClayDepth.pressed, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              AnimatedAlign(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                duration: duration,
                curve: BobaMotion.signature,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: SizedBox.square(
                    dimension: 26,
                    child: CustomPaint(painter: ClayPainter(borderRadius: BorderRadius.circular(13), elevation: 0.5)),
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

/// Small label above a control.
class ControlLabel extends StatelessWidget {
  const ControlLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Row(
        children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.labelSmall)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Price that counts to its new value instead of jumping.
class AnimatedBaht extends StatelessWidget {
  const AnimatedBaht(this.amount, {super.key, this.style});

  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount.toDouble()),
      duration: context.motion(BobaMotion.slow),
      curve: BobaMotion.fluid,
      builder: (context, value, _) => Text(baht(value.round()), style: style, semanticsLabel: baht(amount)),
    );
  }
}
