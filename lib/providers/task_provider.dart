import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../data/services/widget_service.dart';
import 'database_provider.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repo;

  TaskNotifier(this._repo) : super(_repo.getAllTasks());

  void refresh() {
    state = _repo.getAllTasks();
    WidgetService.updateWidget();
  }

  Future<void> addTask(Task task) async {
    await _repo.addTask(task);
    refresh();
  }

  Future<void> updateTask(Task task) async {
    await _repo.updateTask(task);
    refresh();
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    refresh();
  }

  Future<void> toggleComplete(String id) async {
    await _repo.toggleComplete(id);
    refresh();
  }

  Future<void> reorderTasks(List<Task> tasks) async {
    await _repo.reorderTasks(tasks);
    refresh();
  }

  Future<void> pushTaskToTomorrow(String id) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await _repo.pushTaskToDate(id, tomorrow);
    refresh();
  }

  Future<void> rescueOverdue() async {
    await _repo.rescueOverdue(DateTime.now());
    refresh();
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});

final tasksForDateProvider =
    Provider.family<List<Task>, DateTime>((ref, date) {
  final tasks = ref.watch(taskNotifierProvider);
  final dateOnly = DateTime(date.year, date.month, date.day);
  return tasks.where((task) {
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    return taskDate == dateOnly;
  }).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
});

final tasksForWeekProvider =
    Provider.family<List<Task>, DateTime>((ref, weekStart) {
  final tasks = ref.watch(taskNotifierProvider);
  final weekEnd = weekStart.add(const Duration(days: 6));
  final startDate =
      DateTime(weekStart.year, weekStart.month, weekStart.day);
  final endDate =
      DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
  return tasks.where((task) {
    return !task.date.isBefore(startDate) && !task.date.isAfter(endDate);
  }).toList();
});

final tasksForMonthProvider =
    Provider.family<List<Task>, DateTime>((ref, month) {
  final tasks = ref.watch(taskNotifierProvider);
  return tasks.where((task) {
    return task.date.year == month.year && task.date.month == month.month;
  }).toList();
});

final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskNotifierProvider);
  final cutoff = DateTime.now();
  final todayStart = DateTime(cutoff.year, cutoff.month, cutoff.day);
  return tasks.where((task) {
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    return taskDate.isBefore(todayStart) && !task.isCompleted;
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final taskSearchProvider =
    Provider.family<List<Task>, String>((ref, query) {
  if (query.isEmpty) return [];
  final tasks = ref.watch(taskNotifierProvider);
  final lower = query.toLowerCase();
  return tasks.where((task) {
    return task.title.toLowerCase().contains(lower) ||
        (task.description?.toLowerCase().contains(lower) ?? false);
  }).toList();
});
