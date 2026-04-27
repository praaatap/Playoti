import 'dart:convert';
import 'package:flutter/services.dart';
import '../repositories/task_repository.dart';

class WidgetService {
  static const _channel = MethodChannel('com.example.ployti/widget');
  static final _repo = TaskRepository();

  static Future<void> updateWidget() async {
    try {
      final today = DateTime.now();
      final tasks = _repo.getTasksForDate(today);
      final data = jsonEncode(tasks.map((t) => t.toMap()).toList());
      await _channel.invokeMethod('updateWidget', {'data': data});
    } catch (_) {
      // Widget update is best-effort — never crash the app
    }
  }
}
