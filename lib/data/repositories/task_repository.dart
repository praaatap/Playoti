import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskRepository {
  Box get _box => DatabaseService.tasksBox;

  List<Task> getAllTasks() {
    return _box.values
        .map((e) => Task.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Task> getTasksForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return getAllTasks().where((task) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      return taskDate == dateOnly;
    }).toList();
  }

  List<Task> getTasksForDateRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return getAllTasks().where((task) {
      return !task.date.isBefore(startDate) && !task.date.isAfter(endDate);
    }).toList();
  }

  List<Task> getTasksForMonth(int year, int month) {
    return getAllTasks().where((task) {
      return task.date.year == year && task.date.month == month;
    }).toList();
  }

  Task? getTask(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return Task.fromMap(Map<dynamic, dynamic>.from(map as Map));
  }

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleComplete(String id) async {
    final task = getTask(id);
    if (task == null) return;
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
      clearCompletedAt: task.isCompleted,
    );
    await _box.put(id, updated.toMap());
  }

  Future<void> reorderTasks(List<Task> tasks) async {
    for (var i = 0; i < tasks.length; i++) {
      final updated = tasks[i].copyWith(sortOrder: i);
      await _box.put(updated.id, updated.toMap());
    }
  }

  List<Task> getOverdueTasks() {
    final todayStart = DateTime.now();
    final cutoff = DateTime(todayStart.year, todayStart.month, todayStart.day);
    return getAllTasks().where((task) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      return taskDate.isBefore(cutoff) && !task.isCompleted;
    }).toList();
  }

  Future<void> pushTaskToDate(String id, DateTime targetDate) async {
    final task = getTask(id);
    if (task == null) return;
    final updated = task.copyWith(
      date: DateTime(targetDate.year, targetDate.month, targetDate.day,
          task.date.hour, task.date.minute),
      updatedAt: DateTime.now(),
    );
    await _box.put(id, updated.toMap());
  }

  Future<void> rescueOverdue(DateTime toDate) async {
    final overdue = getOverdueTasks();
    for (final task in overdue) {
      await pushTaskToDate(task.id, toDate);
    }
  }

  List<Task> searchTasks(String query) {
    final lower = query.toLowerCase();
    return getAllTasks().where((task) {
      return task.title.toLowerCase().contains(lower) ||
          (task.description?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }
}
