import 'dart:math';
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
import '../../providers/focus_timer_provider.dart';
import 'category_dot.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  final bool showDate;
  final bool isExpanded;
  final VoidCallback? onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;

  const TaskTile({
    super.key,
    required this.task,
    this.showDate = false,
    this.isExpanded = false,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelectionMode) {
      return _SelectionTile(
        task: task,
        showDate: showDate,
        isSelected: isSelected,
        onToggle: onSelectionToggle,
      );
    }

    final primary = Theme.of(context).colorScheme.primary;

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) {
              ref
                  .read(taskNotifierProvider.notifier)
                  .pushTaskToTomorrow(task.id);
              SnackbarUtils.showInfo(context, 'Moved to tomorrow');
            },
            backgroundColor: primary,
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
      child: _ExpandableTile(
        task: task,
        showDate: showDate,
        isExpanded: isExpanded,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

class _ExpandableTile extends ConsumerWidget {
  final Task task;
  final bool showDate;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ExpandableTile({
    required this.task,
    required this.showDate,
    required this.isExpanded,
    this.onTap,
    this.onLongPress,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final categories = ref.watch(categoryNotifierProvider);
    final category = task.categoryId != null
        ? categories.where((c) => c.id == task.categoryId).firstOrNull
        : null;
    final priorityColor = _priorityColor(task.priority);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/task/edit/${task.id}'),
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isCompleted
                ? AppColors.divider
                : priorityColor.withValues(alpha: 0.25),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row
                Row(
                  children: [
                    // Priority stripe
                    Container(
                      width: 4,
                      height: 56,
                      color: task.isCompleted ? AppColors.divider : priorityColor,
                    ),
                    const SizedBox(width: 12),
                    // Checkbox
                    _BurstCheckbox(
                      isCompleted: task.isCompleted,
                      color: priorityColor,
                      onTap: () => ref
                          .read(taskNotifierProvider.notifier)
                          .toggleComplete(task.id),
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
                                      size: 7),
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
                    if (task.subtasks.isNotEmpty)
                      _SubtaskProgress(task: task, primary: primary),
                    const SizedBox(width: 12),
                  ],
                ),
                // Expanded content
                if (isExpanded)
                  _ExpandedContent(task: task, primary: primary),
              ],
            ),
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
}

class _ExpandedContent extends ConsumerWidget {
  final Task task;
  final Color primary;
  const _ExpandedContent({required this.task, required this.primary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceVariant = Theme.of(context).colorScheme.secondaryContainer;
    return Container(
      color: surfaceVariant.withValues(alpha: 0.5),
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.description!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...task.subtasks.asMap().entries.map((e) {
              final index = e.key;
              final sub = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => _toggleSubtaskAtIndex(ref, task, index),
                  child: Row(
                    children: [
                      Icon(
                        sub.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: sub.isCompleted
                            ? primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: sub.isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            decoration: sub.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (!task.isCompleted) ...[
                TextButton.icon(
                  icon: const Icon(Icons.timer_rounded, size: 15),
                  label: const Text('Focus',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      ref.read(focusTimerProvider.notifier).startFocus(task),
                ),
                const SizedBox(width: 4),
              ],
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Edit',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push('/task/edit/${task.id}'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Delete',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () =>
                    ref.read(taskNotifierProvider.notifier).deleteTask(task.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _toggleSubtaskAtIndex(WidgetRef ref, Task task, int index) {
  final subs = [...task.subtasks];
  subs[index] = subs[index].copyWith(isCompleted: !subs[index].isCompleted);
  ref
      .read(taskNotifierProvider.notifier)
      .updateTask(task.copyWith(subtasks: subs));
}

class _SubtaskProgress extends StatelessWidget {
  final Task task;
  final Color primary;
  const _SubtaskProgress({required this.task, required this.primary});

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
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _BurstCheckbox extends StatefulWidget {
  final bool isCompleted;
  final Color color;
  final VoidCallback onTap;

  const _BurstCheckbox({
    required this.isCompleted,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BurstCheckbox> createState() => _BurstCheckboxState();
}

class _BurstCheckboxState extends State<_BurstCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(_BurstCheckbox old) {
    super.didUpdateWidget(old);
    if (!old.isCompleted && widget.isCompleted) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => CustomPaint(
                painter: _BurstPainter(_ctrl.value, widget.color),
                size: const Size(44, 44),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? widget.color
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.isCompleted
                      ? widget.color
                      : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: widget.isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double t;
  final Color color;
  static const _count = 6;

  _BurstPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = Curves.easeOut.transform(t) * 18;
    final opacity = (1.0 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withValues(alpha: opacity);
    for (int i = 0; i < _count; i++) {
      final angle = (i / _count) * 2 * pi;
      final pos = center + Offset(cos(angle) * radius, sin(angle) * radius);
      canvas.drawCircle(pos, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.color != color;
}

class _SelectionTile extends StatelessWidget {
  final Task task;
  final bool showDate;
  final bool isSelected;
  final VoidCallback? onToggle;

  const _SelectionTile({
    required this.task,
    required this.showDate,
    required this.isSelected,
    this.onToggle,
  });

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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final priorityColor = _priorityColor(task.priority);
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isSelected ? 1.0 : 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primary.withValues(alpha: 0.4)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              // Selection circle
              Container(
                width: 44,
                height: 56,
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? primary : AppColors.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.startTime != null || showDate) ...[
                        const SizedBox(height: 3),
                        Text(
                          showDate
                              ? task.date.formattedShortDate
                              : task.startTime!.formattedTime,
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
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
