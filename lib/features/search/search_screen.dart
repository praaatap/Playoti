import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../shared/widgets/task_tile.dart';
import '../../shared/widgets/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  Priority? _priorityFilter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskResults = ref.watch(taskSearchProvider(_query));
    final noteResults = ref.watch(noteSearchProvider(_query));

    final filteredTasks = _priorityFilter != null
        ? taskResults.where((t) => t.priority == _priorityFilter).toList()
        : taskResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
          decoration: const InputDecoration(
            hintText: AppStrings.search,
            border: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', null),
                _filterChip('High', Priority.high),
                _filterChip('Medium', Priority.medium),
                _filterChip('Low', Priority.low),
              ],
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const EmptyState(
                    icon: Icons.search_rounded,
                    title: 'Search tasks and notes',
                  )
                : filteredTasks.isEmpty && noteResults.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No results found',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (filteredTasks.isNotEmpty) ...[
                            _sectionLabel(
                                'Tasks (${filteredTasks.length})'),
                            const SizedBox(height: 8),
                            ...filteredTasks.map((task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TaskTile(task: task, showDate: true),
                                )),
                          ],
                          if (noteResults.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _sectionLabel(
                                'Notes (${noteResults.length})'),
                            const SizedBox(height: 8),
                            ...noteResults.map((note) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: AppColors.divider),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (note.content.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, Priority? priority) {
    final isSelected = _priorityFilter == priority;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => setState(() => _priorityFilter = priority),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primaryDark,
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
}
