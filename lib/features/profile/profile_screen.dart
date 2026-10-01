import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/stagger.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../state/app_scope.dart';
import '../shell/home_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final settings = controllers.settings;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => StaggerGroup(
          itemCount: 4,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, shellBottomSpace),
            children: [
              StaggerItem(
                index: 0,
                child: Row(
                  children: [
                    const ClayBox(
                      width: 64,
                      height: 64,
                      radius: 32,
                      gradient: LinearGradient(colors: [BobaColors.primarySoft, BobaColors.pinkSoft]),
                      child: Icon(Icons.person_rounded, color: BobaColors.primaryInk, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.guest, style: text.titleLarge),
                          Text(l10n.member, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StaggerItem(
                index: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlLabel(l10n.settings),
                    ClayBox(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
                          _SettingRow(
                            icon: Icons.translate_rounded,
                            title: l10n.language,
                            trailing: SizedBox(
                              width: 164,
                              child: ClaySegmented<String>(
                                height: 36,
                                values: const ['th', 'en'],
                                selected: settings.locale.languageCode,
                                label: (code) => code == 'th' ? l10n.languageThai : l10n.languageEnglish,
                                semanticLabel: l10n.language,
                                onChanged: (code) => settings.setLocale(Locale(code)),
                              ),
                            ),
                          ),
                          const _Divider(),
                          _SettingRow(
                            icon: Icons.motion_photos_off_rounded,
                            title: l10n.reduceMotion,
                            subtitle: l10n.reduceMotionHint,
                            trailing: ClaySwitch(
                              value: settings.reduceMotion,
                              onChanged: settings.setReduceMotion,
                              semanticLabel: l10n.reduceMotion,
                            ),
                          ),
                          const _Divider(),
                          _SettingRow(
                            icon: Icons.replay_rounded,
                            title: l10n.replayOnboarding,
                            onTap: () {
                              settings.replayOnboarding();
                              context.go('/onboarding');
                            },
                          ),
                          const _Divider(),
                          _SettingRow(
                            icon: Icons.restart_alt_rounded,
                            title: l10n.resetDemo,
                            onTap: () {
                              controllers.resetDemo();
                              BobaToast.show(context, l10n.resetDone, bottom: 110);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StaggerItem(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlLabel(l10n.aboutTitle),
                    ClayBox(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.aboutBody, style: text.bodyMedium),
                          const SizedBox(height: 14),
                          Text(l10n.builtWith, style: text.labelSmall),
                          const SizedBox(height: 6),
                          const _Chips(['Flutter', 'go_router', 'Lottie', 'CustomPainter', 'gen-l10n']),
                          const SizedBox(height: 12),
                          Text(l10n.designedWith, style: text.labelSmall),
                          const SizedBox(height: 6),
                          const _Chips(['ui-ux-pro-max', 'motion-design', 'Mitr + Anuphan']),
                          const SizedBox(height: 14),
                          Text(l10n.version('1.0.0'), style: text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: BobaColors.selectedTint, shape: BoxShape.circle),
            child: Icon(icon, color: BobaColors.primaryInk, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.labelLarge),
                if (subtitle != null) Text(subtitle!, style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ?? const Icon(Icons.chevron_right_rounded, color: BobaColors.muted),
        ],
      ),
    );
    if (onTap == null) return row;
    return Pressable(onTap: onTap, scale: 0.98, borderRadius: BorderRadius.circular(16), child: row);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: BobaColors.line);
}

class _Chips extends StatelessWidget {
  const _Chips(this.labels);

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(color: BobaColors.primaryInk);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: BobaColors.selectedTint, borderRadius: BorderRadius.circular(12)),
            child: Text(label, style: style),
          ),
      ],
    );
  }
}
