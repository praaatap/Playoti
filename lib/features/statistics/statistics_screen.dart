import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/category_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _period = 'week';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statisticsProvider(_period));
    final categories = ref.watch(categoryNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          Row(
            children: ['week', 'month', 'all'].map((p) {
              final isSelected = p == _period;
              final label =
                  p == 'week' ? 'This Week' : p == 'month' ? 'This Month' : 'All Time';
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: p != 'all' ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _period = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Stat cards
          Row(
            children: [
              _statCard('Total', '${stats.total}', Icons.list_alt_rounded,
                  AppColors.primary),
              const SizedBox(width: 8),
              _statCard('Done', '${stats.completed}',
                  Icons.check_circle_rounded, AppColors.success),
              const SizedBox(width: 8),
              _statCard(
                  'Rate',
                  '${(stats.completionRate * 100).toInt()}%',
                  Icons.trending_up_rounded,
                  AppColors.accent),
              const SizedBox(width: 8),
              _statCard('Streak', '${stats.currentStreak}',
                  Icons.local_fire_department_rounded, AppColors.accentLight),
            ],
          ),

          const SizedBox(height: 24),

          // Completion chart
          if (stats.dailyCompleted.isNotEmpty) ...[
            const Text(
              'Daily Completions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: stats.dailyCompleted.values.isEmpty
                      ? 5
                      : (stats.dailyCompleted.values
                                  .reduce((a, b) => a > b ? a : b)
                                  .toDouble() +
                              1),
                  barGroups: stats.dailyCompleted.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: AppColors.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final entries =
                              stats.dailyCompleted.keys.toList();
                          if (value.toInt() >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final day = entries[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Priority breakdown
          if (stats.byPriority.isNotEmpty) ...[
            const Text(
              'By Priority',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.byPriority.entries.map((entry) {
              final color = entry.key == 'high'
                  ? AppColors.priorityHigh
                  : entry.key == 'medium'
                      ? AppColors.priorityMedium
                      : AppColors.priorityLow;
              final total = stats.total > 0 ? stats.total : 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        entry.key[0].toUpperCase() + entry.key.substring(1),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // Category breakdown
          if (stats.byCategory.isNotEmpty) ...[
            const Text(
              'By Category',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.byCategory.entries.map((entry) {
              final cat = categories
                  .where((c) => c.id == entry.key)
                  .firstOrNull;
              final color =
                  cat != null ? Color(cat.colorValue) : AppColors.textTertiary;
              final name = cat?.name ?? 'Uncategorized';
              final total = stats.total > 0 ? stats.total : 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
