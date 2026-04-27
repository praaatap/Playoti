import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/utils/snackbar_utils.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _format = 'json';
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final tasks = ref.read(taskNotifierProvider);
      final notes = ref.read(noteNotifierProvider);
      final categories = ref.read(categoryNotifierProvider);
      final dir = await getApplicationDocumentsDirectory();

      String filePath;
      if (_format == 'json') {
        final data = {
          'version': '1.0.0',
          'exportedAt': DateTime.now().toIso8601String(),
          'tasks': tasks.map((t) => t.toMap()).toList(),
          'notes': notes.map((n) => n.toMap()).toList(),
          'categories': categories.map((c) => c.toMap()).toList(),
        };
        filePath = '${dir.path}/ployti_backup.json';
        await File(filePath)
            .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      } else {
        final rows = <List<String>>[
          ['Title', 'Description', 'Date', 'Priority', 'Status', 'Category'],
          ...tasks.map((t) {
            final cat = categories
                .where((c) => c.id == t.categoryId)
                .firstOrNull;
            return [
              t.title,
              t.description ?? '',
              t.date.toIso8601String().split('T')[0],
              t.priority.name,
              t.isCompleted ? 'Completed' : 'Active',
              cat?.name ?? '',
            ];
          }),
        ];
        filePath = '${dir.path}/ployti_tasks.csv';
        await File(filePath).writeAsString(const ListToCsvConverter().convert(rows));
      }

      await Share.shareXFiles([XFile(filePath)]);

      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Exported successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Export failed: $e');
      }
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    // Simple JSON import from clipboard or file
    SnackbarUtils.showSuccess(context, 'Import coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final taskCount = ref.watch(taskNotifierProvider).length;
    final noteCount = ref.watch(noteNotifierProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Export & Import')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Export Format',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _formatOption('json', 'JSON', 'Full backup with all data',
                  Icons.data_object_rounded),
              const SizedBox(width: 12),
              _formatOption('csv', 'CSV', 'Tasks as spreadsheet',
                  Icons.table_chart_rounded),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data to export',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$taskCount tasks, $noteCount notes',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _exporting ? null : _export,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: Text(
                _exporting ? 'Exporting...' : 'Export',
                style: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Import',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Restore from a JSON backup file',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _import,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Import from JSON',
                  style: TextStyle(fontFamily: 'Poppins')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatOption(
      String value, String label, String desc, IconData icon) {
    final isSelected = _format == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _format = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 28,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
