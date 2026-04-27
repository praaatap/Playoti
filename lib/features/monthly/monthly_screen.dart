import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/date_extensions.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../shared/widgets/task_tile.dart';
import '../../shared/widgets/empty_state.dart';

class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);
    final monthTasks = ref.watch(tasksForMonthProvider(focusedMonth));
    final selectedDayTasks = ref.watch(tasksForDateProvider(selectedDate.dateOnly));

    return Column(
      children: [
        TableCalendar<Task>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: focusedMonth,
          selectedDayPredicate: (day) => day.isSameDay(selectedDate),
          onDaySelected: (selected, focused) {
            ref.read(selectedDateProvider.notifier).state = selected;
            ref.read(focusedMonthProvider.notifier).state = focused;
          },
          onPageChanged: (focused) {
            ref.read(focusedMonthProvider.notifier).state = focused;
          },
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            leftChevronIcon:
                Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            rightChevronIcon:
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            weekendStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            todayTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            defaultTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            weekendTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            outsideTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markerSize: 5,
            markersAnchor: 0.7,
          ),
          eventLoader: (day) {
            return monthTasks.where((t) => t.date.isSameDay(day)).toList();
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((task) {
                    Color dotColor;
                    switch (task.priority) {
                      case Priority.high:
                        dotColor = AppColors.priorityHigh;
                      case Priority.medium:
                        dotColor = AppColors.priorityMedium;
                      case Priority.low:
                        dotColor = AppColors.priorityLow;
                    }
                    return Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration:
                          BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                selectedDate.formattedFullDate,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${selectedDayTasks.length} tasks',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: selectedDayTasks.isEmpty
              ? const EmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'No tasks on this day',
                  subtitle: 'Tap + to add a task',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectedDayTasks.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TaskTile(task: selectedDayTasks[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
