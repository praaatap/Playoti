import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool showLabel;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = false,
  });

  Color get _color {
    switch (priority) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  String get _label {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Med';
      case Priority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _color.withAlpha(30),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          _label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      );
    }
    return Container(
      width: 6,
      height: 24,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
