import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPinned = false;
  int? _colorValue;
  bool _initialized = false;

  final _noteColors = [
    null,
    AppColors.categoryColors[0].toARGB32(),
    AppColors.categoryColors[1].toARGB32(),
    AppColors.categoryColors[3].toARGB32(),
    AppColors.categoryColors[5].toARGB32(),
    AppColors.categoryColors[7].toARGB32(),
    AppColors.categoryColors[11].toARGB32(),
  ];

  bool get _isNew => widget.noteId == null;

  void _initFromNote(Note? note) {
    if (_initialized) return;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _isPinned = note?.isPinned ?? false;
    _colorValue = note?.colorValue;
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    if (_isNew) {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    if (_isNew) {
      final note = Note(
        id: const Uuid().v4(),
        title: title,
        content: _contentController.text,
        colorValue: _colorValue,
        isPinned: _isPinned,
        createdAt: now,
        updatedAt: now,
      );
      ref.read(noteNotifierProvider.notifier).addNote(note);
    } else {
      final notes = ref.read(noteNotifierProvider);
      final existing = notes.where((n) => n.id == widget.noteId).firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          title: title,
          content: _contentController.text,
          colorValue: _colorValue,
          clearColor: _colorValue == null,
          isPinned: _isPinned,
        );
        ref.read(noteNotifierProvider.notifier).updateNote(updated);
      }
    }
    context.pop();
  }

  Future<void> _delete() async {
    if (_isNew) {
      context.pop();
      return;
    }
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Note',
      message: 'Are you sure you want to delete this note?',
    );
    if (confirmed == true) {
      ref.read(noteNotifierProvider.notifier).deleteNote(widget.noteId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isNew) {
      final notes = ref.watch(noteNotifierProvider);
      final note = notes.where((n) => n.id == widget.noteId).firstOrNull;
      _initFromNote(note);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isNew ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: _delete,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Color picker bar
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _noteColors.map((c) {
                final isSelected = c == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: c != null ? Color(c).withAlpha(60) : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: c == null
                        ? const Icon(Icons.format_color_reset_rounded,
                            size: 14, color: AppColors.textTertiary)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    autofocus: _isNew,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
