import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';
import 'database_provider.dart';

class NoteNotifier extends StateNotifier<List<Note>> {
  final NoteRepository _repo;

  NoteNotifier(this._repo) : super(_repo.getAllNotes());

  void refresh() => state = _repo.getAllNotes();

  Future<void> addNote(Note note) async {
    await _repo.addNote(note);
    refresh();
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateNote(note);
    refresh();
  }

  Future<void> deleteNote(String id) async {
    await _repo.deleteNote(id);
    refresh();
  }

  Future<void> togglePin(String id) async {
    await _repo.togglePin(id);
    refresh();
  }
}

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier(ref.watch(noteRepositoryProvider));
});

final noteSearchProvider =
    Provider.family<List<Note>, String>((ref, query) {
  if (query.isEmpty) return [];
  final notes = ref.watch(noteNotifierProvider);
  final lower = query.toLowerCase();
  return notes.where((note) {
    return note.title.toLowerCase().contains(lower) ||
        note.content.toLowerCase().contains(lower);
  }).toList();
});
