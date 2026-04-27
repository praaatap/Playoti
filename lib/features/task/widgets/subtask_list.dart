import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task.dart';

class SubtaskListEditor extends StatefulWidget {
  final List<Subtask> subtasks;
  final ValueChanged<List<Subtask>> onChanged;

  const SubtaskListEditor({
    super.key,
    required this.subtasks,
    required this.onChanged,
  });

  @override
  State<SubtaskListEditor> createState() => _SubtaskListEditorState();
}

class _SubtaskListEditorState extends State<SubtaskListEditor> {
  late List<Subtask> _subtasks;

  @override
  void initState() {
    super.initState();
    _subtasks = List.from(widget.subtasks);
  }

  void _add() {
    setState(() {
      _subtasks.add(const Subtask(title: ''));
    });
    widget.onChanged(_subtasks);
  }

  void _remove(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
    widget.onChanged(_subtasks);
  }

  void _update(int index, String title) {
    _subtasks[index] = _subtasks[index].copyWith(title: title);
    widget.onChanged(_subtasks);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._subtasks.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.drag_handle_rounded,
                    size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => _update(entry.key, v),
                    controller: TextEditingController(text: entry.value.title)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: entry.value.title.length)),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Subtask ${entry.key + 1}',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textTertiary),
                  onPressed: () => _remove(entry.key),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Add subtask',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
        ),
      ],
    );
  }
}
