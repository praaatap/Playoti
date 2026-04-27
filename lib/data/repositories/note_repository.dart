import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteRepository {
  Box get _box => DatabaseService.notesBox;

  List<Note> getAllNotes() {
    final notes = _box.values
        .map((e) => Note.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  Note? getNote(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return Note.fromMap(Map<dynamic, dynamic>.from(map as Map));
  }

  Future<void> addNote(Note note) async {
    await _box.put(note.id, note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _box.put(note.id, note.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  Future<void> togglePin(String id) async {
    final note = getNote(id);
    if (note == null) return;
    await _box.put(id, note.copyWith(isPinned: !note.isPinned).toMap());
  }

  List<Note> searchNotes(String query) {
    final lower = query.toLowerCase();
    return getAllNotes().where((note) {
      return note.title.toLowerCase().contains(lower) ||
          note.content.toLowerCase().contains(lower);
    }).toList();
  }
}
