import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/date_extensions.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import 'category_dot.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  final bool showDate;

  const TaskTile({super.key, required this.task, this.showDate = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryNotifierProvider);
    final category = task.categoryId != null
        ? categories.where((c) => c.id == task.categoryId).firstOrNull
        : null;

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) {
              ref.read(taskNotifierProvider.notifier).pushTaskToTomorrow(task.id);
              SnackbarUtils.showInfo(context, 'Moved to tomorrow');
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.schedule_rounded,
            label: 'Tomorrow',
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) {
              final deleted = task;
              ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
              SnackbarUtils.showUndo(
                context,
                message: 'Task deleted',
                onUndo: () {
                  ref.read(taskNotifierProvider.notifier).addTask(deleted);
                },
              );
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ],
      ),
      child: _TaskCard(task: task, category: category, showDate: showDate),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final Task task;
  final dynamic category;
  final bool showDate;

  const _TaskCard({required this.task, required this.category, required this.showDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color priorityColor = _priorityColor(task.priority);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/task/edit/${task.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: task.isCompleted
                ? AppColors.surface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isCompleted
                  ? AppColors.divider
                  : priorityColor.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: task.isCompleted
                ? null
                : [
                    BoxShadow(
                      color: priorityColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Priority stripe
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.divider
                      : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Checkbox
              GestureDetector(
                onTap: () => ref
                    .read(taskNotifierProvider.notifier)
                    .toggleComplete(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? priorityColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted
                          ? priorityColor
                          : AppColors.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (category != null) ...[
                            CategoryDot(
                              color: Color(category.colorValue),
                              size: 7,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: task.isCompleted
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (_hasSubtitle) ...[
                        const SizedBox(height: 3),
                        Text(
                          _subtitle(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Time or subtask indicator
              if (task.subtasks.isNotEmpty)
                _SubtaskProgress(task: task),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasSubtitle =>
      task.startTime != null || showDate || task.description != null;

  String _subtitle() {
    final parts = <String>[];
    if (showDate) parts.add(task.date.formattedShortDate);
    if (task.startTime != null) {
      parts.add(task.startTime!.formattedTime);
      if (task.endTime != null) parts.add('→ ${task.endTime!.formattedTime}');
    }
    if (task.description != null && task.description!.isNotEmpty) {
      parts.add(task.description!);
    }
    return parts.join(' · ');
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }
}

class _SubtaskProgress extends StatelessWidget {
  final Task task;
  const _SubtaskProgress({required this.task});

  @override
  Widget build(BuildContext context) {
    final done = task.subtasks.where((s) => s.isCompleted).length;
    final total = task.subtasks.length;
    final pct = total > 0 ? done / total : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$done/$total',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 28,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 3,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
