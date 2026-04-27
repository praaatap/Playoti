import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryRepository {
  Box get _box => DatabaseService.categoriesBox;

  List<TaskCategory> getAllCategories() {
    return _box.values
        .map((e) => TaskCategory.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  TaskCategory? getCategory(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return TaskCategory.fromMap(Map<dynamic, dynamic>.from(map as Map));
  }

  Future<void> addCategory(TaskCategory category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<void> updateCategory(TaskCategory category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
