import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
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

  DateTime? _timeOfDayToDateTime(TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description:
          _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      date: DateTime(_date.year, _date.month, _date.day),
      startTime: _timeOfDayToDateTime(_startTime),
      endTime: _timeOfDayToDateTime(_endTime),
      priority: _priority,
      categoryId: _categoryId,
      recurrenceType: _recurrence,
      subtasks: _subtasks.where((s) => s.title.isNotEmpty).toList(),
      createdAt: now,
      updatedAt: now,
    );

    ref.read(taskNotifierProvider.notifier).addTask(task);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
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
            decoration: const InputDecoration(hintText: 'Description (optional)'),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Date & Time'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _dateTile()),
              const SizedBox(width: 8),
              Expanded(child: _timeTile('Start', _startTime, _pickStartTime)),
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
