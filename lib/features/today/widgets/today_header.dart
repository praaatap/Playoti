import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TodayHeader extends StatelessWidget {
  final String greeting;
  final String date;
  final int totalTasks;
  final int completedTasks;
  final int streak;

  const TodayHeader({
    super.key,
    required this.greeting,
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    this.streak = 0,
  });

  String _motivationalLine(int total, int completed) {
    if (total == 0) return 'Your day is clear.';
    if (completed == 0) return 'Ready to make progress? Let\'s go!';
    if (completed == total) return 'Amazing! All tasks cleared today 🎉';
    final pct = (completed / total * 100).round();
    if (pct >= 75) return 'Almost there — keep the momentum!';
    if (pct >= 50) return 'Great progress, more than halfway done!';
    return 'You\'ve started — keep going!';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
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
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _motivationalLine(totalTasks, completedTasks),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: allDone ? AppColors.success : primary,
                    ),
                  ),
                  if (streak > 1) ...[
                    const SizedBox(height: 8),
                    _StreakBadge(streak: streak),
                  ],
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
                primary: primary,
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
            primary: primary,
          ),
        ],
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    const fire = Color(0xFFFF6B00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fire.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fire.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            '$streak day streak',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fire,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final bool allDone;
  final Color primary;

  const _ProgressBar({
    required this.completed,
    required this.total,
    required this.allDone,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final barColor = allDone ? AppColors.success : primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 6,
            ),
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
  final Color primary;

  const _RingProgress({
    required this.completed,
    required this.total,
    required this.allDone,
    required this.remaining,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            children: [
              SizedBox.expand(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    backgroundColor: primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      allDone ? AppColors.success : primary,
                    ),
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              Center(
                child: allDone
                    ? const Icon(Icons.check_rounded,
                        size: 22, color: AppColors.success)
                    : Text(
                        '$remaining',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primary,
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
