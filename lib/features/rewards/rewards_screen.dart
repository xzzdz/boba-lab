import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/motion/stagger.dart';
import '../../core/theme/clay.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/boba_lottie.dart';
import '../../core/widgets/clay_controls.dart';
import '../../state/app_scope.dart';
import '../../state/rewards_controller.dart';
import '../shell/home_shell.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = AppScope.of(context).rewards;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: rewards,
        builder: (context, _) => StaggerGroup(
          itemCount: 4,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(BobaSpace.gutter, 12, BobaSpace.gutter, shellBottomSpace),
            children: [
              StaggerItem(index: 0, child: Text(l10n.rewardsTitle, style: text.headlineSmall)),
              const SizedBox(height: 16),
              StaggerItem(
                index: 1,
                child: _StampCard(
                  stamps: rewards.stamps,
                  fresh: rewards.freshStamps,
                  completed: rewards.completedCard,
                  onPlayed: rewards.acknowledge,
                ),
              ),
              const SizedBox(height: 22),
              StaggerItem(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlLabel(l10n.freeCups),
                    if (rewards.freeCups == 0)
                      Text(l10n.noFreeCups, style: text.bodyMedium!.copyWith(color: BobaColors.muted))
                    else
                      for (var i = 0; i < rewards.freeCups; i++)
                        const Padding(padding: EdgeInsets.only(bottom: 10), child: _FreeCupTicket()),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const StaggerItem(index: 3, child: _HowItWorks()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ten slots. Stamps that arrived since the card was last seen slam in one
/// after another; a full card also gets confetti.
class _StampCard extends StatefulWidget {
  const _StampCard({required this.stamps, required this.fresh, required this.completed, required this.onPlayed});

  final int stamps;
  final int fresh;
  final bool completed;
  final VoidCallback onPlayed;

  @override
  State<_StampCard> createState() => _StampCardState();
}

class _StampCardState extends State<_StampCard> with SingleTickerProviderStateMixin {
  static const _each = 450;
  static const _gap = 180;

  late final AnimationController _play = AnimationController(vsync: this);
  int _fresh = 0;
  bool _celebrate = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(_StampCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fresh != oldWidget.fresh || widget.completed != oldWidget.completed || widget.stamps != oldWidget.stamps) _start();
  }

  void _start() {
    if (widget.fresh <= 0 && !widget.completed) return;
    _fresh = widget.fresh;
    _celebrate = widget.completed;
    _play.duration = Duration(milliseconds: _each + _gap * math.max(0, _fresh - 1));
    _play.forward(from: 0).whenComplete(() {
      if (mounted) widget.onPlayed();
    });
  }

  Animation<double> _slotAnimation(int order) {
    final total = _play.duration!.inMilliseconds;
    final start = _gap * order / total;
    return _play.drive(CurveTween(curve: Interval(start, math.min(1, start + _each / total))));
  }

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final stamps = widget.stamps;
    final firstFresh = stamps - _fresh;
    final toGo = RewardsController.cardSize - stamps;

    Widget slot(int i) {
      if (i < stamps) {
        final fresh = i >= firstFresh;
        return BobaLottie(
          BobaLotties.stamp,
          repeat: false,
          controller: fresh ? _slotAnimation(i - firstFresh) : const AlwaysStoppedAnimation(1),
        );
      }
      final last = i == RewardsController.cardSize - 1;
      return Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Center(
            child: last
                ? const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20)
                : Text('${i + 1}', style: text.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.8))),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_celebrate) ...[
              ClayBox(
                color: const Color(0xFFD1FAE5),
                elevation: 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.celebration_rounded, color: BobaColors.successInk),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.cardComplete, style: text.labelLarge!.copyWith(color: BobaColors.successInk)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Semantics(
              label: '${l10n.promoProgress(stamps)}. ${l10n.stampsToGo(toGo)}',
              child: ExcludeSemantics(
                child: ClayBox(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BobaColors.primary, Color(0xFFA855F7), BobaColors.pink],
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Boba Lab', style: text.titleLarge!.copyWith(color: Colors.white)),
                          ),
                          Text('$stamps / ${RewardsController.cardSize}', style: text.titleMedium!.copyWith(color: Colors.white)),
                        ],
                      ),
                      Text(l10n.stampsToGo(toGo), style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                      const SizedBox(height: 12),
                      for (var row = 0; row < 2; row++)
                        Row(
                          children: [
                            for (var col = 0; col < 5; col++) Expanded(child: AspectRatio(aspectRatio: 1, child: slot(row * 5 + col))),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_celebrate)
          const Positioned(
            left: -20,
            right: -20,
            top: -60,
            height: 420,
            child: IgnorePointer(child: BobaLottie(BobaLotties.confetti, repeat: false, stillProgress: 0)),
          ),
      ],
    );
  }
}

class _FreeCupTicket extends StatelessWidget {
  const _FreeCupTicket();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return ClayBox(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: BobaColors.pinkSoft, shape: BoxShape.circle),
            child: const Icon(Icons.card_giftcard_rounded, color: BobaColors.pink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.freeCupTicket, style: text.labelLarge),
                Text(l10n.freeCupHint, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final steps = [l10n.how1, l10n.how2, l10n.how3];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ControlLabel(l10n.howItWorks),
        ClayBox(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: BobaColors.selectedTint, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: text.labelMedium!.copyWith(color: BobaColors.primaryInk)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(steps[i], style: text.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
