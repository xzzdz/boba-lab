import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/clay_controls.dart';
import '../core/widgets/feedback.dart';
import '../data/models.dart';
import '../features/cup/cup_view.dart';
import '../state/app_scope.dart';

/// On wide screens (a recruiter's laptop) the app runs inside a phone frame
/// with a short pitch beside it. Phones get the app full screen.
class PortfolioFrame extends StatelessWidget {
  const PortfolioFrame({super.key, required this.child});

  final Widget child;

  static const phone = Size(390, 844);
  static const _bezel = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < 720 || box.maxHeight < 560) return child;
        final media = MediaQuery.of(context);
        const insets = EdgeInsets.only(top: 50, bottom: 28);
        final device = _Device(
          child: MediaQuery(
            data: media.copyWith(size: phone, padding: insets, viewPadding: insets, viewInsets: EdgeInsets.zero),
            child: child,
          ),
        );
        final deviceSize = Size(phone.width + _bezel * 2, phone.height + _bezel * 2);
        final scale = math.min(1.0, (box.maxHeight - 48) / deviceSize.height);
        final showPitch = box.maxWidth >= 1040;
        // The frame sits outside the app's Material, so give it a real text style.
        return DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: ColoredBox(
            color: BobaColors.background,
            child: Stack(
              children: [
                const Positioned.fill(child: DriftingBlobs()),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showPitch) ...[const SizedBox(width: 360, child: _Pitch()), const SizedBox(width: 72)],
                      SizedBox(
                        width: deviceSize.width * scale,
                        height: deviceSize.height * scale,
                        child: FittedBox(
                          child: SizedBox.fromSize(size: deviceSize, child: device),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Device extends StatelessWidget {
  const _Device({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1724),
        borderRadius: BorderRadius.circular(58),
        boxShadow: [
          BoxShadow(color: BobaColors.primary.withValues(alpha: 0.25), blurRadius: 60, offset: const Offset(0, 30)),
          const BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(PortfolioFrame._bezel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(46),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              const Positioned(top: 0, left: 0, right: 0, height: 50, child: IgnorePointer(child: _StatusBar())),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final now = AppScope.of(context).clock();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 14, 28, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              time,
              style: const TextStyle(fontFamily: 'Anuphan', fontWeight: FontWeight.w600, fontSize: 15, color: BobaColors.ink),
            ),
          ),
          Container(
            width: 118,
            height: 34,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.signal_cellular_alt_rounded, size: 17, color: BobaColors.ink),
                SizedBox(width: 4),
                Icon(Icons.wifi_rounded, size: 17, color: BobaColors.ink),
                SizedBox(width: 4),
                Icon(Icons.battery_full_rounded, size: 19, color: BobaColors.ink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final settings = AppScope.of(context).settings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CupView(
              config: CupConfig(base: BaseId.brownSugar, toppings: {ToppingId.pearls}),
              height: 64,
            ),
            const SizedBox(width: 10),
            Text(l10n.appTitle, style: text.displaySmall!.copyWith(color: BobaColors.primaryInk)),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.frameBody, style: text.bodyLarge!.copyWith(color: BobaColors.muted)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in const ['Flutter', 'go_router', 'Lottie', 'CustomPainter', 'TH / EN'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: BobaColors.surface, borderRadius: BorderRadius.circular(14)),
                child: Text(label, style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: settings,
          builder: (context, _) => SizedBox(
            width: 200,
            child: ClaySegmented<String>(
              values: const ['th', 'en'],
              selected: settings.locale.languageCode,
              label: (code) => code == 'th' ? l10n.languageThai : l10n.languageEnglish,
              semanticLabel: l10n.language,
              onChanged: (code) => settings.setLocale(Locale(code)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.touch_app_rounded, color: BobaColors.primary),
            const SizedBox(width: 8),
            Text(l10n.frameHint, style: text.labelLarge!.copyWith(color: BobaColors.primaryInk)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, color: BobaColors.primary, size: 20),
          ],
        ),
      ],
    );
  }
}
