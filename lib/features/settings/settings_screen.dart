import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/route_names.dart';
import '../../providers/settings_provider.dart';
import '../../data/services/database_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/note_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('General'),
          const SizedBox(height: 8),
          _settingsTile(
            icon: Icons.view_agenda_rounded,
            title: 'Default view',
            subtitle: ['Today', 'Weekly', 'Monthly'][settings.defaultViewIndex],
            onTap: () async {
              final views = ['Today', 'Weekly', 'Monthly'];
              final picked = await showDialog<int>(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Default view',
                      style: TextStyle(fontFamily: 'Poppins')),
                  children: views.asMap().entries.map((e) {
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, e.key),
                      child: Text(e.value,
                          style: const TextStyle(fontFamily: 'Poppins')),
                    );
                  }).toList(),
                ),
              );
              if (picked != null) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setDefaultView(picked);
              }
            },
          ),
          _settingsTile(
            icon: Icons.calendar_today_rounded,
            title: 'Week starts on',
            subtitle: settings.weekStartDay == 1 ? 'Monday' : 'Sunday',
            onTap: () {
              final newDay = settings.weekStartDay == 1 ? 7 : 1;
              ref.read(settingsNotifierProvider.notifier).setWeekStartDay(newDay);
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Show completed tasks',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            subtitle: const Text('Display completed tasks in views',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary)),
            value: settings.showCompletedTasks,
            activeTrackColor: AppColors.primaryLight,
            activeThumbColor: AppColors.primary,
            onChanged: (_) {
              ref.read(settingsNotifierProvider.notifier).toggleShowCompleted();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Data'),
          const SizedBox(height: 8),
          _settingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export data',
            subtitle: 'JSON or CSV backup',
            onTap: () => context.push(RoutePaths.export_),
          ),
          _settingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Clear all data',
            subtitle: 'Remove all tasks, notes, and categories',
            titleColor: AppColors.error,
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Clear All Data',
                message:
                    'This will permanently delete all your tasks, notes, and categories. This cannot be undone.',
                confirmLabel: 'Clear All',
              );
              if (confirmed == true) {
                await DatabaseService.clearAllData();
                ref.read(taskNotifierProvider.notifier).refresh();
                ref.read(categoryNotifierProvider.notifier).refresh();
                ref.read(noteNotifierProvider.notifier).refresh();
                ref.read(settingsNotifierProvider.notifier).refresh();
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionLabel('About'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.event_note_rounded,
                      size: 30, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ployti',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your personal planner.\nLocal-first. Private. Beautiful.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: titleColor ?? AppColors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
