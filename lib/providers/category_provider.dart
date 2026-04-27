import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';
import 'database_provider.dart';

class CategoryNotifier extends StateNotifier<List<TaskCategory>> {
  final CategoryRepository _repo;

  CategoryNotifier(this._repo) : super(_repo.getAllCategories());

  void refresh() => state = _repo.getAllCategories();

  Future<void> addCategory(TaskCategory category) async {
    await _repo.addCategory(category);
    refresh();
  }

  Future<void> updateCategory(TaskCategory category) async {
    await _repo.updateCategory(category);
    refresh();
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    refresh();
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, List<TaskCategory>>((ref) {
  return CategoryNotifier(ref.watch(categoryRepositoryProvider));
});
