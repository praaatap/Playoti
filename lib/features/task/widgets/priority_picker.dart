import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task.dart';

class PriorityPicker extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const PriorityPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = p == selected;
        final color = _color(p);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != Priority.low ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(30) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _label(p),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(Priority p) {
    switch (p) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  String _label(Priority p) {
    switch (p) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }
}
