import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_providers.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/balance_provider.dart';
import 'widgets/balance_rings.dart';
import 'widgets/morning_brief_sheet.dart';
import 'widgets/productivity_hub_card.dart';
import 'widgets/spiritual_hub_card.dart';
import 'widgets/streak_strip.dart';

/// Meezan's home: the unified dashboard. Fully implemented for this run.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.toggleLanguage,
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            tooltip: l10n.toggleTheme,
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: cap content width on large phones / foldables so the
            // layout stays comfortable rather than stretching edge-to-edge.
            final maxWidth = constraints.maxWidth;
            final horizontalPadding = maxWidth > 600 ? maxWidth * 0.08 : AppSpacing.lg;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList.list(
                    children: const [
                      _Greeting(),
                      SizedBox(height: AppSpacing.lg),
                      _BalanceHero(),
                      SizedBox(height: AppSpacing.xl),
                      StreakStrip(),
                      SizedBox(height: AppSpacing.lg),
                      SpiritualHubCard(),
                      SizedBox(height: AppSpacing.lg),
                      ProductivityHubCard(),
                      SizedBox(height: AppSpacing.xl),
                      _MorningBriefButton(),
                    ],
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

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.greetingMorning
        : hour < 18
            ? l10n.greetingAfternoon
            : l10n.greetingEvening;

    return Text(
      greeting,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _BalanceHero extends ConsumerWidget {
  const _BalanceHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final balance = ref.watch(balanceScoreProvider);

    return Column(
      children: [
        Center(
          child: BalanceRings(
            score: balance.score,
            spiritual: balance.spiritual,
            worldly: balance.worldly,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.balanceSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        // Ring legend.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: theme.colorScheme.primary, label: l10n.ringSpiritual),
            const SizedBox(width: AppSpacing.xl),
            _LegendDot(color: theme.colorScheme.tertiary, label: l10n.ringWorldly),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _MorningBriefButton extends StatelessWidget {
  const _MorningBriefButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => MorningBriefSheet.show(context),
        icon: const Icon(Icons.wb_sunny_outlined),
        label: Text(l10n.morningBrief),
      ),
    );
  }
}
