import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/task.dart';
import '../../../providers/task_provider.dart';

class QuickAddBar extends ConsumerStatefulWidget {
  const QuickAddBar({super.key});

  @override
  ConsumerState<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends ConsumerState<QuickAddBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Priority _priority = Priority.medium;

  static const _priorities = [Priority.high, Priority.medium, Priority.low];

  Color _colorFor(Priority p) {
    switch (p) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  String _labelFor(Priority p) {
    switch (p) {
      case Priority.high:
        return 'H';
      case Priority.medium:
        return 'M';
      case Priority.low:
        return 'L';
    }
  }

  void _cyclePriority() {
    final idx = _priorities.indexOf(_priority);
    setState(() {
      _priority = _priorities[(idx + 1) % _priorities.length];
    });
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      date: DateTime(now.year, now.month, now.day),
      priority: _priority,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(taskNotifierProvider.notifier).addTask(task);
    _controller.clear();
    setState(() => _priority = Priority.medium);
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _colorFor(_priority);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
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
          // Priority pill — tap to cycle
          GestureDetector(
            onTap: _cyclePriority,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: priorityColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _labelFor(_priority),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (_) => _addTask(),
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a task...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _addTask,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
