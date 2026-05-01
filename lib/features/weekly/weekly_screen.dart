import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../shared/widgets/task_tile.dart';
import '../../shared/widgets/empty_state.dart';

class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key});

  @override
  ConsumerState<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends ConsumerState<WeeklyScreen> {
  late EasyInfiniteDateTimelineController _timelineController;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _timelineController = EasyInfiniteDateTimelineController();
    _selectedDay = DateTime.now().dateOnly;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _jumpToToday() {
    final today = DateTime.now().dateOnly;
    setState(() => _selectedDay = today);
    _timelineController.animateToCurrentData();
  }

  bool get _isToday => _selectedDay.isToday;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final allTasks = ref.watch(
      tasksForWeekProvider(_selectedDay.startOfWeek),
    );
    final dayTasks = allTasks
        .where((t) => t.date.isSameDay(_selectedDay))
        .toList();

    return Column(
      children: [
        // ── Header strip ─────────────────────────────────────────────────
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Month label + Today button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      AppDateUtils.getMonthLabel(_selectedDay),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (!_isToday)
                      GestureDetector(
                        onTap: _jumpToToday,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.today_rounded,
                                  size: 14, color: primary),
                              const SizedBox(width: 4),
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms).scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                          ),
                  ],
                ),
              ),

              // Infinite scrollable day timeline
              EasyInfiniteDateTimeLine(
                controller: _timelineController,
                firstDate: DateTime(2020),
                focusDate: _selectedDay,
                lastDate: DateTime(2100),
                onDateChange: (selected) {
                  setState(() => _selectedDay = selected);
                },
                showTimelineHeader: false,
                activeColor: primary,
                dayProps: EasyDayProps(
                  height: 74,
                  width: 52,
                  dayStructure: DayStructure.dayStrDayNum,
                  activeDayStyle: DayStyle(
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    dayStrStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    dayNumStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  inactiveDayStyle: DayStyle(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    dayStrStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                    dayNumStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  todayHighlightStyle: TodayHighlightStyle.withBorder,
                  todayHighlightColor: primary,
                  todayStyle: DayStyle(
                    dayStrStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                    dayNumStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Task count pill for selected day
              _DayTaskSummary(
                  day: _selectedDay, count: dayTasks.length, primary: primary),
              const SizedBox(height: 4),
              const Divider(height: 1),
            ],
          ),
        ),

        // ── Task list for selected day ────────────────────────────────────
        Expanded(
          child: _DayTasksList(
            key: ValueKey(_selectedDay),
            day: _selectedDay,
            tasks: dayTasks,
          ),
        ),
      ],
    );
  }
}

// ── Day summary pill ─────────────────────────────────────────────────────────

class _DayTaskSummary extends StatelessWidget {
  final DateTime day;
  final int count;
  final Color primary;
  const _DayTaskSummary(
      {required this.day, required this.count, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            _dayLabel(day),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count task${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    if (d.isToday) return 'Today';
    final diff = d.difference(DateTime.now().dateOnly).inDays;
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${d.formattedShortWeekday}, ${d.formattedShortDate}';
  }
}

// ── Task list with time-grouping ─────────────────────────────────────────────

class _DayTasksList extends ConsumerStatefulWidget {
  final DateTime day;
  final List<Task> tasks;
  const _DayTasksList({super.key, required this.day, required this.tasks});

  @override
  ConsumerState<_DayTasksList> createState() => _DayTasksListState();
}

class _DayTasksListState extends ConsumerState<_DayTasksList> {
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

  void _exitSelection() => setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });

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
        final h = t.startTime!.hour;
        if (h < 12) {
          morning.add(t);
        } else if (h < 18) {
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
    if (widget.tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_rounded,
        title: 'Nothing scheduled',
        subtitle: 'Tap + to add a task for this day',
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    final grouped = _groupByTime(widget.tasks);
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                for (final entry in grouped.entries) ...[
                  if (!suppressHeader) ...[
                    _SectionHeader(
                        label: entry.key,
                        count: entry.value.length,
                        primary: primary),
                    const Gap(8),
                  ],
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
                        onSelectionToggle: () => _toggleSelection(task.id),
                      )
                          .animate()
                          .fadeIn(
                            duration: 280.ms,
                            delay: Duration(milliseconds: e.key * 40),
                          )
                          .slideY(
                            begin: 0.08,
                            end: 0,
                            duration: 280.ms,
                            delay: Duration(milliseconds: e.key * 40),
                          ),
                    );
                  }),
                  if (!suppressHeader) const Gap(8),
                ],
              ],
            ),
          ),
          if (_isSelectionMode)
            _WeeklyBatchBar(
              selectedCount: _selectedIds.length,
              onComplete: _completeSelected,
              onDelete: _deleteSelected,
              onTomorrow: _moveSelectedToTomorrow,
              onCancel: _exitSelection,
            ),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color primary;
  const _SectionHeader(
      {required this.label, required this.count, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: primary,
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
            color: primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Batch action bar ─────────────────────────────────────────────────────────

class _WeeklyBatchBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTomorrow;
  final VoidCallback onCancel;

  const _WeeklyBatchBar({
    required this.selectedCount,
    required this.onComplete,
    required this.onDelete,
    required this.onTomorrow,
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
          Text('$selectedCount selected',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(
            onPressed: onComplete,
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
            onPressed: onTomorrow,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tomorrow',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ),
          TextButton(
            onPressed: onDelete,
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
