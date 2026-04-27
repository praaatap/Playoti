import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/app_settings.dart';
import '../../core/constants/app_colors.dart';

class DatabaseService {
  static const _tasksBox = 'tasks';
  static const _categoriesBox = 'categories';
  static const _notesBox = 'notes';
  static const _settingsBox = 'settings';
  static const _settingsKey = 'app_settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_tasksBox);
    await Hive.openBox(_categoriesBox);
    await Hive.openBox(_notesBox);
    await Hive.openBox(_settingsBox);
    await _seedDefaultCategories();
  }

  static Box get tasksBox => Hive.box(_tasksBox);
  static Box get categoriesBox => Hive.box(_categoriesBox);
  static Box get notesBox => Hive.box(_notesBox);
  static Box get settingsBox => Hive.box(_settingsBox);

  static AppSettings getSettings() {
    final map = settingsBox.get(_settingsKey);
    if (map == null) return const AppSettings();
    return AppSettings.fromMap(Map<dynamic, dynamic>.from(map as Map));
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put(_settingsKey, settings.toMap());
  }

  static Future<void> _seedDefaultCategories() async {
    final box = categoriesBox;
    if (box.isNotEmpty) return;

    const uuid = Uuid();
    final now = DateTime.now();
    final defaults = [
      {'name': 'Personal', 'color': AppColors.categoryColors[0].toARGB32(), 'icon': 'person'},
      {'name': 'Work', 'color': AppColors.categoryColors[6].toARGB32(), 'icon': 'work'},
      {'name': 'Health', 'color': AppColors.categoryColors[1].toARGB32(), 'icon': 'favorite'},
      {'name': 'Shopping', 'color': AppColors.categoryColors[3].toARGB32(), 'icon': 'shopping_cart'},
      {'name': 'Study', 'color': AppColors.categoryColors[11].toARGB32(), 'icon': 'menu_book'},
      {'name': 'Home', 'color': AppColors.categoryColors[9].toARGB32(), 'icon': 'home'},
    ];

    for (var i = 0; i < defaults.length; i++) {
      final id = uuid.v4();
      await box.put(id, {
        'id': id,
        'name': defaults[i]['name'],
        'colorValue': defaults[i]['color'],
        'iconName': defaults[i]['icon'],
        'sortOrder': i,
        'createdAt': now.toIso8601String(),
      });
    }
  }

  static Future<void> clearAllData() async {
    await tasksBox.clear();
    await categoriesBox.clear();
    await notesBox.clear();
    await settingsBox.clear();
    await _seedDefaultCategories();
  }
}
