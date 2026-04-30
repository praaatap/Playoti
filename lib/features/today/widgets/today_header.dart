import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TodayHeader extends StatelessWidget {
  final String greeting;
  final String date;
  final int totalTasks;
  final int completedTasks;

  const TodayHeader({
    super.key,
    required this.greeting,
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalTasks - completedTasks;
    final allDone = totalTasks > 0 && remaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (totalTasks > 0) ...[
              const SizedBox(width: 12),
              _RingProgress(
                completed: completedTasks,
                total: totalTasks,
                allDone: allDone,
                remaining: remaining,
              ),
            ],
          ],
        ),
        if (totalTasks > 0) ...[
          const SizedBox(height: 12),
          _ProgressBar(
            completed: completedTasks,
            total: totalTasks,
            allDone: allDone,
          ),
        ],
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final bool allDone;

  const _ProgressBar({
    required this.completed,
    required this.total,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final barColor = allDone ? AppColors.success : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(barColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          allDone
              ? 'All tasks complete!'
              : '$completed of $total tasks done',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: allDone ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RingProgress extends StatelessWidget {
  final int completed;
  final int total;
  final bool allDone;
  final int remaining;

  const _RingProgress({
    required this.completed,
    required this.total,
    required this.allDone,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    allDone ? AppColors.success : AppColors.primary,
                  ),
                  strokeWidth: 4.5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Center(
                child: allDone
                    ? const Icon(Icons.check_rounded,
                        size: 22, color: AppColors.success)
                    : Text(
                        '$remaining',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          allDone ? 'All done!' : 'left',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: allDone ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
