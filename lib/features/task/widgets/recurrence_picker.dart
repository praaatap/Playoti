import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task.dart';

class RecurrencePicker extends StatelessWidget {
  final RecurrenceType? selected;
  final ValueChanged<RecurrenceType?> onChanged;

  const RecurrencePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [null, ...RecurrenceType.values];
    return Wrap(
      spacing: 8,
      children: options.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(25)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              _label(type),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(RecurrenceType? type) {
    if (type == null) return 'None';
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }
}
