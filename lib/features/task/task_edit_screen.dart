import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'widgets/priority_picker.dart';
import 'widgets/category_picker.dart';
import 'widgets/recurrence_picker.dart';
import 'widgets/subtask_list.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskEditScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late Priority _priority;
  String? _categoryId;
  RecurrenceType? _recurrence;
  late List<Subtask> _subtasks;
  bool _initialized = false;

  void _initFromTask(Task task) {
    if (_initialized) return;
    _titleController = TextEditingController(text: task.title);
    _descController = TextEditingController(text: task.description ?? '');
    _date = task.date;
    _startTime = task.startTime != null
        ? TimeOfDay.fromDateTime(task.startTime!)
        : null;
    _endTime =
        task.endTime != null ? TimeOfDay.fromDateTime(task.endTime!) : null;
    _priority = task.priority;
    _categoryId = task.categoryId;
    _recurrence = task.recurrenceType;
    _subtasks = List.from(task.subtasks);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _titleController.dispose();
      _descController.dispose();
    }
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

  DateTime? _timeOfDayToDateTime(TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(
        _date.year, _date.month, _date.day, time.hour, time.minute);
  }

  void _save(Task original) {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = original.copyWith(
      title: title,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      clearDescription: _descController.text.trim().isEmpty,
      date: DateTime(_date.year, _date.month, _date.day),
      startTime: _timeOfDayToDateTime(_startTime),
      clearStartTime: _startTime == null,
      endTime: _timeOfDayToDateTime(_endTime),
      clearEndTime: _endTime == null,
      priority: _priority,
      categoryId: _categoryId,
      clearCategory: _categoryId == null,
      recurrenceType: _recurrence,
      clearRecurrence: _recurrence == null,
      subtasks: _subtasks.where((s) => s.title.isNotEmpty).toList(),
      updatedAt: DateTime.now(),
    );

    ref.read(taskNotifierProvider.notifier).updateTask(updated);
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete this task?',
    );
    if (confirmed == true) {
      ref.read(taskNotifierProvider.notifier).deleteTask(widget.taskId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskNotifierProvider);
    final task = tasks.where((t) => t.id == widget.taskId).firstOrNull;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Task not found')),
      );
    }

    _initFromTask(task);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: _delete,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: () => _save(task),
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
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            minLines: 1,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration:
                const InputDecoration(hintText: 'Description (optional)'),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Date & Time'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _dateTile()),
              const SizedBox(width: 8),
              Expanded(
                  child: _timeTile('Start', _startTime, _pickStartTime)),
              const SizedBox(width: 8),
              Expanded(child: _timeTile('End', _endTime, _pickEndTime)),
            ],
          ),
          const SizedBox(height: 24),
          _sectionLabel('Priority'),
          const SizedBox(height: 8),
          PriorityPicker(
            selected: _priority,
            onChanged: (p) => setState(() => _priority = p),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Category'),
          const SizedBox(height: 8),
          CategoryPicker(
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Recurrence'),
          const SizedBox(height: 8),
          RecurrencePicker(
            selected: _recurrence,
            onChanged: (r) => setState(() => _recurrence = r),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Subtasks'),
          const SizedBox(height: 8),
          SubtaskListEditor(
            subtasks: _subtasks,
            onChanged: (list) => _subtasks = list,
          ),
          const SizedBox(height: 40),
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

  Widget _dateTile() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay? time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                time != null ? time.format(context) : label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: time != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
