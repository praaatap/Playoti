import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import 'widgets/priority_picker.dart';
import 'widgets/category_picker.dart';
import 'widgets/recurrence_picker.dart';
import 'widgets/subtask_list.dart';

class TaskCreateScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const TaskCreateScreen({super.key, this.initialDate});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Priority _priority = Priority.medium;
  String? _categoryId;
  RecurrenceType? _recurrence;
  DateTime? _reminderDateTime;
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _pickReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderDateTime != null
          ? TimeOfDay.fromDateTime(_reminderDateTime!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _reminderDateTime = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, pickedTime.hour, pickedTime.minute);
    });
  }

  void _showPrioritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            const Text('Priority',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            PriorityPicker(
              selected: _priority,
              onChanged: (p) {
                setState(() => _priority = p);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            const Text('Category',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            CategoryPicker(
              selectedId: _categoryId,
              onChanged: (id) {
                setState(() => _categoryId = id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRecurrenceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            const Text('Recurrence',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            RecurrencePicker(
              selected: _recurrence,
              onChanged: (r) {
                setState(() => _recurrence = r);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  DateTime? _timeOfDayToDateTime(TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
  }

  String _priorityLabel() {
    switch (_priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  String _recurrenceLabel() {
    if (_recurrence == null) return 'None';
    switch (_recurrence!) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String _reminderLabel() {
    if (_reminderDateTime == null) return 'None';
    final d = _reminderDateTime!;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}  $h:$m';
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      date: DateTime(_date.year, _date.month, _date.day),
      startTime: _timeOfDayToDateTime(_startTime),
      endTime: _timeOfDayToDateTime(_endTime),
      priority: _priority,
      categoryId: _categoryId,
      recurrenceType: _recurrence,
      subtasks: _subtasks.where((s) => s.title.isNotEmpty).toList(),
      reminderDateTime: _reminderDateTime,
      createdAt: now,
      updatedAt: now,
    );
    ref.read(taskNotifierProvider.notifier).addTask(task);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryNotifierProvider);
    final cat = _categoryId != null
        ? categories.where((c) => c.id == _categoryId).firstOrNull
        : null;
    final catName = cat?.name ?? 'None';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Task'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text('Save',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            maxLines: null,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: 'Task name',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: null,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary),
            decoration: const InputDecoration.collapsed(
              hintText: 'Add notes...',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          _PropertyRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: '${_date.day}/${_date.month}/${_date.year}',
            isSet: true,
            onTap: _pickDate,
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.schedule_rounded,
            label: 'Start',
            value: _startTime?.format(context) ?? 'None',
            isSet: _startTime != null,
            onTap: _pickStartTime,
            showClear: _startTime != null,
            onClear: () => setState(() => _startTime = null),
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.schedule_outlined,
            label: 'End',
            value: _endTime?.format(context) ?? 'None',
            isSet: _endTime != null,
            onTap: _pickEndTime,
            showClear: _endTime != null,
            onClear: () => setState(() => _endTime = null),
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: _priorityLabel(),
            isSet: true,
            onTap: _showPrioritySheet,
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.label_outline_rounded,
            label: 'Category',
            value: catName,
            isSet: _categoryId != null,
            onTap: _showCategorySheet,
            showClear: _categoryId != null,
            onClear: () => setState(() => _categoryId = null),
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.repeat_rounded,
            label: 'Recurrence',
            value: _recurrenceLabel(),
            isSet: _recurrence != null,
            onTap: _showRecurrenceSheet,
            showClear: _recurrence != null,
            onClear: () => setState(() => _recurrence = null),
          ),
          const Divider(color: AppColors.divider, indent: 50),
          _PropertyRow(
            icon: Icons.notifications_outlined,
            label: 'Reminder',
            value: _reminderLabel(),
            isSet: _reminderDateTime != null,
            onTap: _pickReminder,
            showClear: _reminderDateTime != null,
            onClear: () => setState(() => _reminderDateTime = null),
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.checklist_rounded,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Subtasks',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SubtaskListEditor(
            subtasks: _subtasks,
            onChanged: (list) => setState(() => _subtasks = list),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSet;
  final VoidCallback onTap;
  final bool showClear;
  final VoidCallback? onClear;

  const _PropertyRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSet,
    required this.onTap,
    this.showClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: isSet
                      ? AppColors.textSecondary
                      : AppColors.textTertiary,
                ),
              ),
              if (showClear) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close_rounded,
                      size: 15, color: AppColors.textTertiary),
                ),
              ] else ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
