import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/settings_repository.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());
final noteRepositoryProvider = Provider((ref) => NoteRepository());
final settingsRepositoryProvider = Provider((ref) => SettingsRepository());
