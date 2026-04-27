import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../providers/task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/task.dart';
import '../../shared/widgets/task_tile.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/quick_add_bar.dart';
import 'widgets/today_header.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String? _expandedTaskId;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _completeSelected() {
    for (final id in _selectedIds) {
      ref.read(taskNotifierProvider.notifier).toggleComplete(id);
    }
    _exitSelection();
  }

  void _deleteSelected() {
    for (final id in _selectedIds) {
      ref.read(taskNotifierProvider.notifier).deleteTask(id);
    }
    _exitSelection();
  }

  void _moveSelectedToTomorrow() {
    for (final id in _selectedIds) {
      ref.read(taskNotifierProvider.notifier).pushTaskToTomorrow(id);
    }
    _exitSelection();
  }

  Map<String, List<Task>> _groupByTime(List<Task> tasks) {
    final morning = <Task>[];
    final afternoon = <Task>[];
    final evening = <Task>[];
    final anytime = <Task>[];

    for (final t in tasks) {
      if (t.startTime == null) {
        anytime.add(t);
      } else {
        final hour = t.startTime!.hour;
        if (hour < 12) {
          morning.add(t);
        } else if (hour < 18) {
          afternoon.add(t);
        } else {
          evening.add(t);
        }
      }
    }

    return {
      if (morning.isNotEmpty) 'Morning': morning,
      if (afternoon.isNotEmpty) 'Afternoon': afternoon,
      if (evening.isNotEmpty) 'Evening': evening,
      if (anytime.isNotEmpty) 'Anytime': anytime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tasks = ref.watch(tasksForDateProvider(today.dateOnly));
    final overdueTasks = ref.watch(overdueTasksProvider);
    final settings = ref.watch(settingsNotifierProvider);

    final activeTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final showCompleted = settings.showCompletedTasks;
    final isEmpty = tasks.isEmpty && overdueTasks.isEmpty;

    final grouped = _groupByTime(activeTasks);
    final suppressHeader =
        grouped.length == 1 && grouped.containsKey('Anytime');

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectionMode) _exitSelection();
      },
      child: Column(
        children: [
          Expanded(
            child: isEmpty
                ? const EmptyState(
                    icon: Icons.today_rounded,
                    title: AppStrings.noTasksToday,
                    subtitle: AppStrings.addFirstTask,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.14)),
                        ),
                        child: TodayHeader(
                          greeting: AppDateUtils.getGreeting(),
                          date: today.formattedFullDate,
                          totalTasks: tasks.length,
                          completedTasks: completedTasks.length,
                        ),
                      ),
                      // Overdue section
                      if (overdueTasks.isNotEmpty) ...[
                        const Gap(16),
                        _OverdueSection(count: overdueTasks.length),
                        const Gap(8),
                        ...overdueTasks.map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskTile(
                                task: task,
                                showDate: true,
                                isExpanded: _expandedTaskId == task.id,
                                isSelectionMode: _isSelectionMode,
                                isSelected: _selectedIds.contains(task.id),
                                onTap: _isSelectionMode
                                    ? () => _toggleSelection(task.id)
                                    : () => setState(() {
                                          _expandedTaskId =
                                              _expandedTaskId == task.id
                                                  ? null
                                                  : task.id;
                                        }),
                                onLongPress: !_isSelectionMode
                                    ? () => setState(() {
                                          _isSelectionMode = true;
                                          _selectedIds.add(task.id);
                                        })
                                    : null,
                                onSelectionToggle: () =>
                                    _toggleSelection(task.id),
                              ),
                            )),
                      ],
                      // Time-grouped active tasks
                      for (final entry in grouped.entries) ...[
                        if (!suppressHeader) ...[
                          const Gap(16),
                          _TimeSectionHeader(
                              label: entry.key, count: entry.value.length),
                          const Gap(8),
                        ] else
                          const Gap(16),
                        ...entry.value.asMap().entries.map((e) {
                          final task = e.value;
                          final isExpanded = _expandedTaskId == task.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskTile(
                              task: task,
                              isExpanded: isExpanded,
                              isSelectionMode: _isSelectionMode,
                              isSelected: _selectedIds.contains(task.id),
                              onTap: _isSelectionMode
                                  ? () => _toggleSelection(task.id)
                                  : () => setState(() {
                                        _expandedTaskId =
                                            isExpanded ? null : task.id;
                                      }),
                              onLongPress: !_isSelectionMode
                                  ? () => setState(() {
                                        _isSelectionMode = true;
                                        _selectedIds.add(task.id);
                                      })
                                  : null,
                              onSelectionToggle: () =>
                                  _toggleSelection(task.id),
                            )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: Duration(
                                      milliseconds: e.key * 50),
                                )
                                .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: Duration(
                                      milliseconds: e.key * 50),
                                ),
                          );
                        }),
                      ],
                      // Completed section
                      if (showCompleted && completedTasks.isNotEmpty) ...[
                        const Gap(16),
                        Row(
                          children: [
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${completedTasks.length}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        ...completedTasks.map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Opacity(
                                opacity: 0.6,
                                child: TaskTile(
                                  task: task,
                                  isExpanded: _expandedTaskId == task.id,
                                  onTap: () => setState(() {
                                    _expandedTaskId =
                                        _expandedTaskId == task.id
                                            ? null
                                            : task.id;
                                  }),
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
          ),
          if (_isSelectionMode)
            _BatchActionBar(
              selectedCount: _selectedIds.length,
              onCompleteAll: _completeSelected,
              onDeleteAll: _deleteSelected,
              onMoveToTomorrow: _moveSelectedToTomorrow,
              onCancel: _exitSelection,
            ),
          const QuickAddBar(),
        ],
      ),
    );
  }
}

class _TimeSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _TimeSectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCompleteAll;
  final VoidCallback onDeleteAll;
  final VoidCallback onMoveToTomorrow;
  final VoidCallback onCancel;

  const _BatchActionBar({
    required this.selectedCount,
    required this.onCompleteAll,
    required this.onDeleteAll,
    required this.onMoveToTomorrow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount selected',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onCompleteAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Complete',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ),
          TextButton(
            onPressed: onMoveToTomorrow,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tomorrow',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ),
          TextButton(
            onPressed: onDeleteAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Delete',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: onCancel,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _OverdueSection extends ConsumerWidget {
  final int count;
  const _OverdueSection({required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.overdue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.overdue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: AppColors.overdue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count overdue task${count == 1 ? '' : 's'} — swipe right to postpone',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.overdue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await ref.read(taskNotifierProvider.notifier).rescueOverdue();
              if (context.mounted) {
                SnackbarUtils.showSuccess(
                  context,
                  '$count task${count == 1 ? '' : 's'} moved to today',
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.overdue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Rescue all',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
