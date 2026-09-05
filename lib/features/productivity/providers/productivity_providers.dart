import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';

/// Holds today's tasks. Seeded with sample data for the MVP.
class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return const [
      Task(id: 't1', title: 'Finish project proposal', priority: TaskPriority.high, progress: 0.6),
      Task(id: 't2', title: 'Reply to client emails', priority: TaskPriority.medium, progress: 0.25),
      Task(id: 't3', title: 'Read 20 pages', priority: TaskPriority.low, progress: 0.1),
      Task(id: 't4', title: 'Plan weekly groceries', priority: TaskPriority.low, progress: 0.0),
      Task(id: 't5', title: 'Call the plumber', priority: TaskPriority.medium, progress: 0.0),
    ];
  }

  /// Nudge a task's partial progress. When it reaches 1.0 it counts as complete
  /// and (after the fade-out animation in the UI) is archived.
  void setProgress(String id, double progress) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(progress: progress.clamp(0, 1)) else t,
    ];
  }

  /// Mark complete (progress = 1). The UI plays a fade, then calls [archive].
  void complete(String id) => setProgress(id, 1);

  void archive(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(archived: true) else t,
    ];
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

/// Active (non-archived) tasks sorted by priority then progress.
final activeTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).where((t) => !t.archived).toList();
  tasks.sort((a, b) {
    final byPriority = b.priority.weight.compareTo(a.priority.weight);
    if (byPriority != 0) return byPriority;
    return b.progress.compareTo(a.progress);
  });
  return tasks;
});

/// Top 3 tasks for the dashboard summary card.
final topTasksProvider = Provider<List<Task>>(
  (ref) => ref.watch(activeTasksProvider).take(3).toList(),
);

/// Today's task completion (0..1): average progress across active tasks.
/// Feeds the "worldly" half of the Life Balance Score.
final taskCompletionProvider = Provider<double>((ref) {
  final tasks = ref.watch(activeTasksProvider);
  if (tasks.isEmpty) return 1; // nothing pending == a clear day
  final total = tasks.fold<double>(0, (sum, t) => sum + t.progress);
  return (total / tasks.length).clamp(0, 1);
});
