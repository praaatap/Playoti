import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/category_provider.dart';

class CategoryPicker extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const CategoryPicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryNotifierProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'None',
            color: AppColors.textTertiary,
            isSelected: selectedId == null,
            onTap: () => onChanged(null),
          ),
          ...categories.map((cat) {
            return _chip(
              label: cat.name,
              color: Color(cat.colorValue),
              isSelected: selectedId == cat.id,
              onTap: () => onChanged(cat.id),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(25) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
