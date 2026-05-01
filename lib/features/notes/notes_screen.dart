import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/date_extensions.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../shared/widgets/empty_state.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteNotifierProvider);

    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.sticky_note_2_rounded,
        title: AppStrings.noNotes,
        subtitle: AppStrings.addFirstNote,
      );
    }

    // Pinned notes on top
    final sorted = [...notes]
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    final pinned = sorted.where((n) => n.isPinned).toList();
    final unpinned = sorted.where((n) => !n.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (pinned.isNotEmpty) ...[
          _SectionLabel(label: 'Pinned', icon: Icons.push_pin_rounded),
          const SizedBox(height: 8),
          _NoteGrid(notes: pinned, startIndex: 0),
          const SizedBox(height: 16),
        ],
        if (unpinned.isNotEmpty) ...[
          if (pinned.isNotEmpty)
            _SectionLabel(label: 'Notes', icon: Icons.sticky_note_2_outlined),
          if (pinned.isNotEmpty) const SizedBox(height: 8),
          _NoteGrid(notes: unpinned, startIndex: pinned.length),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _NoteGrid extends ConsumerWidget {
  final List<Note> notes;
  final int startIndex;
  const _NoteGrid({required this.notes, required this.startIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NoteCard(note: note)
            .animate()
            .fadeIn(
              duration: 280.ms,
              delay: Duration(milliseconds: (startIndex + index) * 35),
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 280.ms,
              delay: Duration(milliseconds: (startIndex + index) * 35),
            );
      },
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = note.colorValue != null
        ? Color(note.colorValue!).withAlpha(30)
        : AppColors.surface;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) {
              ref.read(noteNotifierProvider.notifier).togglePin(note.id);
            },
            backgroundColor: primary,
            foregroundColor: Colors.white,
            icon: note.isPinned
                ? Icons.push_pin_outlined
                : Icons.push_pin_rounded,
            label: note.isPinned ? 'Unpin' : 'Pin',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) {
              final deleted = note;
              ref.read(noteNotifierProvider.notifier).deleteNote(note.id);
              SnackbarUtils.showUndo(
                context,
                message: 'Note deleted',
                onUndo: () {
                  ref.read(noteNotifierProvider.notifier).addNote(deleted);
                },
              );
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.push('/note/edit/${note.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: note.isPinned
                  ? primary.withValues(alpha: 0.3)
                  : AppColors.divider,
            ),
            boxShadow: note.isPinned
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin badge + title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.push_pin_rounded,
                        size: 13, color: primary),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.updatedAt.formattedShortDate,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
