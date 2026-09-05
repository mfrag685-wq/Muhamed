import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../spiritual/models/prayer.dart';
import '../../../spiritual/providers/spiritual_providers.dart';

/// Summary of today's worship: 5 prayer chips, Qur'an wird, charity, dhikr.
class SpiritualHubCard extends ConsumerWidget {
  const SpiritualHubCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(spiritualProvider);

    return SectionCard(
      title: l10n.spiritualHubTitle,
      icon: Icons.self_improvement_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.prayersToday,
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in state.prayers)
                _PrayerChip(
                  status: p,
                  label: p.name.label(l10n),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(spiritualProvider.notifier).togglePrayer(p.name);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _MetricBar(
            label: l10n.quranWird,
            valueLabel: l10n.quranPages(state.quranPagesDone, state.quranPagesGoal),
            progress: state.quranCompletion,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricBar(
            label: l10n.charityGoal,
            valueLabel: l10n.charityAmount(state.charityDone, state.charityGoal),
            progress: state.charityCompletion,
          ),
          const SizedBox(height: AppSpacing.lg),
          _DhikrCounter(count: state.dhikrCount),
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  const _PrayerChip({
    required this.status,
    required this.label,
    required this.onTap,
  });

  final PrayerStatus status;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = status.done;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Material(
        color: done ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: done ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    color: done ? scheme.onPrimary : scheme.onSurface,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.valueLabel,
    required this.progress,
  });

  final String label;
  final String valueLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text(valueLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) =>
                LinearProgressIndicator(value: value),
          ),
        ),
      ],
    );
  }
}

class _DhikrCounter extends StatelessWidget {
  const _DhikrCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        ),
        child: Row(
          children: [
            Icon(Icons.spa_outlined, color: scheme.onSecondaryContainer),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dhikrCounter,
                      style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(l10n.dhikrTapHint,
                      style: TextStyle(
                        color: scheme.onSecondaryContainer.withValues(alpha: 0.7),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(spiritualProvider.notifier).resetDhikr(),
              child: Text(l10n.dhikrReset),
            ),
            const SizedBox(width: AppSpacing.sm),
            // The big tappable count — medium-impact haptic on each tap.
            InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(spiritualProvider.notifier).incrementDhikr();
              },
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
