import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(cat.colorValue).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconFromName(cat.iconName),
                  size: 18,
                  color: Color(cat.colorValue),
                ),
              ),
              title: Text(
                cat.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        size: 18, color: AppColors.textTertiary),
                    onPressed: () =>
                        _showCategoryDialog(context, ref, category: cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    onPressed: () async {
                      final ok = await ConfirmDialog.show(
                        context,
                        title: 'Delete Category',
                        message: 'Delete "${cat.name}"?',
                      );
                      if (ok == true) {
                        ref
                            .read(categoryNotifierProvider.notifier)
                            .deleteCategory(cat.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref,
      {TaskCategory? category}) {
    final nameController =
        TextEditingController(text: category?.name ?? '');
    var selectedColor = category != null
        ? Color(category.colorValue)
        : AppColors.categoryColors[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              category == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration:
                      const InputDecoration(hintText: 'Category name'),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppColors.categoryColors.map((c) {
                    final isSelected = c.toARGB32() == selectedColor.toARGB32();
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.textPrimary, width: 2.5)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  if (category == null) {
                    ref.read(categoryNotifierProvider.notifier).addCategory(
                          TaskCategory(
                            id: const Uuid().v4(),
                            name: name,
                            colorValue: selectedColor.toARGB32(),
                            createdAt: DateTime.now(),
                          ),
                        );
                  } else {
                    ref.read(categoryNotifierProvider.notifier).updateCategory(
                          category.copyWith(
                            name: name,
                            colorValue: selectedColor.toARGB32(),
                          ),
                        );
                  }
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Save',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconFromName(String name) {
    const map = {
      'person': Icons.person_rounded,
      'work': Icons.work_rounded,
      'favorite': Icons.favorite_rounded,
      'shopping_cart': Icons.shopping_cart_rounded,
      'menu_book': Icons.menu_book_rounded,
      'home': Icons.home_rounded,
      'circle': Icons.circle,
      'star': Icons.star_rounded,
      'fitness': Icons.fitness_center_rounded,
      'music': Icons.music_note_rounded,
    };
    return map[name] ?? Icons.circle;
  }
}
