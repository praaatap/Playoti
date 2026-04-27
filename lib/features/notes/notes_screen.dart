import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 40))
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 300.ms,
              delay: Duration(milliseconds: index * 40),
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
    final bgColor = note.colorValue != null
        ? Color(note.colorValue!).withAlpha(30)
        : AppColors.surface;

    return GestureDetector(
      onTap: () => context.push('/note/edit/${note.id}'),
      onLongPress: () async {
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.isPinned)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Icon(Icons.push_pin_rounded,
                    size: 14, color: AppColors.textTertiary),
              ),
            Text(
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
    );
  }
}
