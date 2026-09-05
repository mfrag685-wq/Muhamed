import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../productivity/providers/productivity_providers.dart';
import '../../../spiritual/models/prayer.dart';
import '../../../spiritual/providers/spiritual_providers.dart';

/// Morning Brief modal: a quick, readable summary of prayers, wird and top
/// tasks. The "play" action is a TODO stub for TTS.
class MorningBriefSheet extends ConsumerWidget {
  const MorningBriefSheet({super.key});

  /// Opens the brief as a rounded modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const MorningBriefSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spiritual = ref.watch(spiritualProvider);
    final topTasks = ref.watch(topTasksProvider);

    final remainingPrayers = spiritual.prayers
        .where((p) => !p.done)
        .map((p) => p.name.label(l10n))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.morningBrief,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(l10n.morningBriefSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xl),
            _BriefRow(
              icon: Icons.mosque_outlined,
              title: l10n.morningBriefPrayers,
              body: remainingPrayers.isEmpty
                  ? '${spiritual.prayersDone}/${spiritual.prayers.length}'
                  : remainingPrayers.join('  ·  '),
            ),
            _BriefRow(
              icon: Icons.menu_book_outlined,
              title: l10n.morningBriefWird,
              body: l10n.quranPages(
                  spiritual.quranPagesDone, spiritual.quranPagesGoal),
            ),
            _BriefRow(
              icon: Icons.task_alt_outlined,
              title: l10n.morningBriefTasks,
              body: topTasks.isEmpty
                  ? l10n.noTasks
                  : topTasks.map((t) => t.title).join('\n'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    // TODO(meezan): wire up text-to-speech playback of the brief.
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.morningBriefPlay)),
                      );
                    },
                    icon: const Icon(Icons.volume_up_outlined),
                    label: Text(l10n.morningBriefPlay),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefRow extends StatelessWidget {
  const _BriefRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
