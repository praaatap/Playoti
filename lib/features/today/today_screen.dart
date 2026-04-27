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
import '../../shared/widgets/task_tile.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/quick_add_bar.dart';
import 'widgets/today_header.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final tasks = ref.watch(tasksForDateProvider(today.dateOnly));
    final overdueTasks = ref.watch(overdueTasksProvider);
    final settings = ref.watch(settingsNotifierProvider);

    final activeTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final showCompleted = settings.showCompletedTasks;

    final isEmpty = tasks.isEmpty && overdueTasks.isEmpty;

    return Column(
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
                    TodayHeader(
                      greeting: AppDateUtils.getGreeting(),
                      date: today.formattedFullDate,
                      totalTasks: tasks.length,
                      completedTasks: completedTasks.length,
                    ),
                    if (overdueTasks.isNotEmpty) ...[
                      const Gap(16),
                      _OverdueSection(count: overdueTasks.length),
                      const Gap(8),
                      ...overdueTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TaskTile(task: task, showDate: true),
                          )),
                    ],
                    if (activeTasks.isNotEmpty) ...[
                      const Gap(16),
                      const _SectionLabel(label: 'Today'),
                      const Gap(8),
                      ...activeTasks.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskTile(task: entry.value)
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: Duration(milliseconds: entry.key * 50),
                              )
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                delay: Duration(milliseconds: entry.key * 50),
                              ),
                        );
                      }),
                    ] else if (overdueTasks.isEmpty) ...[
                      const Gap(16),
                      const EmptyState(
                        icon: Icons.today_rounded,
                        title: AppStrings.noTasksToday,
                        subtitle: AppStrings.addFirstTask,
                      ),
                    ],
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
                      ...completedTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Opacity(
                            opacity: 0.6,
                            child: TaskTile(task: task),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
        ),
        const QuickAddBar(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
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
