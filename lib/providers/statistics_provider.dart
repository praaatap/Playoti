import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_provider.dart';

class TaskStats {
  final int total;
  final int completed;
  final double completionRate;
  final int currentStreak;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;
  final Map<DateTime, int> dailyCompleted;

  const TaskStats({
    this.total = 0,
    this.completed = 0,
    this.completionRate = 0,
    this.currentStreak = 0,
    this.byCategory = const {},
    this.byPriority = const {},
    this.dailyCompleted = const {},
  });
}

final statisticsProvider = Provider.family<TaskStats, String>((ref, period) {
  final tasks = ref.watch(taskNotifierProvider);

  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  DateTime startDate;
  switch (period) {
    case 'week':
      final diff = now.weekday - DateTime.monday;
      startDate = todayDate.subtract(Duration(days: diff));
      break;
    case 'month':
      startDate = DateTime(now.year, now.month, 1);
      break;
    default:
      startDate = DateTime(2000);
  }

  final filtered = tasks.where((t) => !t.date.isBefore(startDate)).toList();
  final completedTasks = filtered.where((t) => t.isCompleted).toList();

  final byCategory = <String, int>{};
  for (final task in filtered) {
    final key = task.categoryId ?? 'uncategorized';
    byCategory[key] = (byCategory[key] ?? 0) + 1;
  }

  final byPriority = <String, int>{};
  for (final task in filtered) {
    final key = task.priority.name;
    byPriority[key] = (byPriority[key] ?? 0) + 1;
  }

  final dailyCompleted = <DateTime, int>{};
  for (final task in completedTasks) {
    if (task.completedAt != null) {
      final day = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      dailyCompleted[day] = (dailyCompleted[day] ?? 0) + 1;
    }
  }

  int streak = 0;
  var checkDate = todayDate;
  while (true) {
    final dayTasks = tasks.where((t) {
      final td = DateTime(t.date.year, t.date.month, t.date.day);
      return td == checkDate;
    }).toList();
    if (dayTasks.isEmpty) break;
    final allDone = dayTasks.every((t) => t.isCompleted);
    if (!allDone) break;
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return TaskStats(
    total: filtered.length,
    completed: completedTasks.length,
    completionRate:
        filtered.isEmpty ? 0 : completedTasks.length / filtered.length,
    currentStreak: streak,
    byCategory: byCategory,
    byPriority: byPriority,
    dailyCompleted: dailyCompleted,
  );
});
