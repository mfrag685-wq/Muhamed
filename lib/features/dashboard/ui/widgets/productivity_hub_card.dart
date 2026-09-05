import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../productivity/models/task.dart';
import '../../../productivity/providers/productivity_providers.dart';

/// Summary of the top 3 tasks by priority, each with a partial-progress bar.
/// Completing a task fades it out, then archives it (removing it from the list).
class ProductivityHubCard extends ConsumerWidget {
  const ProductivityHubCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(topTasksProvider);

    return SectionCard(
      title: l10n.productivityHubTitle,
      icon: Icons.task_alt_outlined,
      child: tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                l10n.noTasks,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                for (final task in tasks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TaskTile(task: task),
                  ),
              ],
            ),
    );
  }
}

class _TaskTile extends ConsumerStatefulWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  ConsumerState<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<_TaskTile> {
  bool _fadingOut = false;

  void _complete() {
    ref.read(tasksProvider.notifier).complete(widget.task.id);
    setState(() => _fadingOut = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final task = widget.task;
    final priorityColor = task.priority.color;

    return AnimatedOpacity(
      opacity: _fadingOut ? 0 : 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      // When the fade finishes, archive so the task leaves the top-3 list.
      onEnd: () {
        if (_fadingOut) ref.read(tasksProvider.notifier).archive(task.id);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          border: Border(
            left: BorderSide(color: priorityColor, width: 4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _PriorityBadge(
                        label: task.priority.label(l10n),
                        color: priorityColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: task.progress),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              tooltip: l10n.taskCompleted,
              onPressed: _fadingOut ? null : _complete,
              icon: Icon(
                task.isComplete
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.isComplete ? priorityColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
