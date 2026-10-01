import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/pressable.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';
import '../../core/widgets/feedback.dart';
import '../../state/app_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  static const _lotties = [BobaLotties.onboardBuild, BobaLotties.onboardOrder, BobaLotties.onboardStamps];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    AppScope.of(context).settings.completeOnboarding();
    context.go('/menu');
  }

  void _next() {
    if (_index == _lotties.length - 1) {
      _finish();
      return;
    }
    _pages.nextPage(duration: context.motion(BobaMotion.page), curve: BobaMotion.fluid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.onboard1Title, l10n.onboard2Title, l10n.onboard3Title];
    final bodies = [l10n.onboard1Body, l10n.onboard2Body, l10n.onboard3Body];
    final last = _index == _lotties.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DriftingBlobs()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, 12, 0),
                  child: Row(
                    children: [
                      const _LanguageToggle(),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: last ? 0 : 1,
                        duration: context.motion(BobaMotion.standard),
                        child: Pressable(
                          onTap: last ? null : _finish,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Text(l10n.skip, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: BobaColors.muted)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _lotties.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) => _OnboardingPage(
                      controller: _pages,
                      index: index,
                      lottie: _lotties[index],
                      title: titles[index],
                      body: bodies[index],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 8, BobaSpace.gutter, 24),
                  child: Column(
                    children: [
                      _Dots(count: _lotties.length, index: _index),
                      const SizedBox(height: 24),
                      ClayButton(label: last ? l10n.getStarted : l10n.next, icon: last ? Icons.local_cafe_rounded : null, onPressed: _next),
                      const SizedBox(height: 14),
                      Text(l10n.demoNotice, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.controller, required this.index, required this.lottie, required this.title, required this.body});

  final PageController controller;
  final int index;
  final String lottie;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.haveDimensions ? controller.page ?? 0 : 0.0;
        final offset = (index - page).clamp(-1.0, 1.0);
        // Illustration lags behind the swipe a little: parallax.
        return Transform.translate(offset: Offset(offset * 60, 0), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BobaSpace.gutter + 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClayBox(
                    radius: 150,
                    color: const Color(0xCCFFFFFF),
                    padding: const EdgeInsets.all(18),
                    child: BobaLottie(lottie, stillProgress: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(title, textAlign: TextAlign.center, style: text.headlineSmall),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: text.bodyLarge!.copyWith(color: BobaColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page dots; the active one stretches into a pill with the signature curve.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: context.motion(BobaMotion.slow),
            curve: BobaMotion.signature,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? BobaColors.primary : BobaColors.primarySoft,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => SizedBox(
        width: 150,
        child: ClaySegmented<String>(
          height: 36,
          values: const ['th', 'en'],
          selected: settings.locale.languageCode,
          label: (code) => code == 'th' ? l10n.languageThai : l10n.languageEnglish,
          semanticLabel: l10n.language,
          onChanged: (code) => settings.setLocale(Locale(code)),
        ),
      ),
    );
  }
}
