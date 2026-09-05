import 'package:flutter/widgets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

enum TaskPriority { high, medium, low }

extension TaskPriorityX on TaskPriority {
  Color get color => switch (this) {
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.low => AppColors.priorityLow,
      };

  String label(AppLocalizations l10n) => switch (this) {
        TaskPriority.high => l10n.priorityHigh,
        TaskPriority.medium => l10n.priorityMedium,
        TaskPriority.low => l10n.priorityLow,
      };

  /// Sort weight — higher priority sorts first.
  int get weight => switch (this) {
        TaskPriority.high => 3,
        TaskPriority.medium => 2,
        TaskPriority.low => 1,
      };
}

@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.priority,
    this.progress = 0,
    this.archived = false,
  });

  final String id;
  final String title;
  final TaskPriority priority;

  /// Partial completion, 0..1. A value of 1 means the task is complete.
  final double progress;

  /// Completed tasks fade out and archive; archived tasks leave the top list.
  final bool archived;

  bool get isComplete => progress >= 1.0;

  Task copyWith({double? progress, bool? archived}) => Task(
        id: id,
        title: title,
        priority: priority,
        progress: progress ?? this.progress,
        archived: archived ?? this.archived,
      );
}
