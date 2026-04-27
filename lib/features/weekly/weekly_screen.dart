import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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
  late DateTime _weekStart;
  int? _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _weekStart = DateTime.now().startOfWeek;
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDayIndex = null;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDayIndex = null;
    });
  }

  void _goToToday() {
    setState(() {
      _weekStart = DateTime.now().startOfWeek;
      _selectedDayIndex = DateTime.now().weekday - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekStart.daysInWeek;
    final weekTasks = ref.watch(tasksForWeekProvider(_weekStart));

    return Column(
      children: [
        // Week navigation header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _previousWeek,
                color: AppColors.textSecondary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _goToToday,
                  child: Text(
                    AppDateUtils.getWeekRangeLabel(_weekStart),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _nextWeek,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),

        // Day columns
        SizedBox(
          height: 200,
          child: Row(
            children: List.generate(7, (i) {
              final day = days[i];
              final dayTasks = weekTasks.where((t) {
                return t.date.isSameDay(day);
              }).toList();
              final isToday = day.isToday;
              final isSelected = _selectedDayIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primary.withAlpha(50))
                          : null,
                    ),
                    child: Column(
                      children: [
                        const Gap(8),
                        Text(
                          day.formattedShortWeekday,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const Gap(4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight:
                                    isToday ? FontWeight.w600 : FontWeight.w400,
                                color:
                                    isToday ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: dayTasks.isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 16,
                                    color: AppColors.textTertiary.withAlpha(80),
                                  ),
                                )
                              : ListView(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: dayTasks.take(4).map((task) {
                                    return _TaskChip(task: task);
                                  }).toList(),
                                ),
                        ),
                        if (dayTasks.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '+${dayTasks.length - 4}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const Divider(height: 1),

        // Selected day tasks
        Expanded(
          child: _selectedDayIndex != null
              ? _DayTasksList(
                  day: days[_selectedDayIndex!],
                  tasks: weekTasks
                      .where(
                          (t) => t.date.isSameDay(days[_selectedDayIndex!]))
                      .toList(),
                )
              : const EmptyState(
                  icon: Icons.touch_app_rounded,
                  title: 'Tap a day to see tasks',
                ),
        ),
      ],
    );
  }
}

class _TaskChip extends StatelessWidget {
  final Task task;
  const _TaskChip({required this.task});

  Color get _priorityColor {
    switch (task.priority) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _priorityColor.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: _priorityColor, width: 2)),
      ),
      child: Text(
        task.title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          color: task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DayTasksList extends StatelessWidget {
  final DateTime day;
  final List<Task> tasks;
  const _DayTasksList({required this.day, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_rounded,
        title: 'No tasks on ${day.formattedShortWeekday}, ${day.formattedShortDate}',
        subtitle: 'Tap + to add a task',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TaskTile(task: tasks[i]),
      ),
    );
  }
}
