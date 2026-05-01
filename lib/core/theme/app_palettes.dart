import 'package:flutter/material.dart';

class AppPalette {
  final String id;
  final String name;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color background;
  final Color surfaceVariant;

  const AppPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.background,
    required this.surfaceVariant,
  });

  static const amber = AppPalette(
    id: 'amber',
    name: 'Warm Amber',
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFDE68A),
    primaryDark: Color(0xFFD97706),
    accent: Color(0xFFF97316),
    accentLight: Color(0xFFFED7AA),
    background: Color(0xFFFFFBF0),
    surfaceVariant: Color(0xFFFEF3C7),
  );

  static const ocean = AppPalette(
    id: 'ocean',
    name: 'Ocean Blue',
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFFBFDBFE),
    primaryDark: Color(0xFF1D4ED8),
    accent: Color(0xFF06B6D4),
    accentLight: Color(0xFFCFFAFE),
    background: Color(0xFFF0F7FF),
    surfaceVariant: Color(0xFFDBEAFE),
  );

  static const forest = AppPalette(
    id: 'forest',
    name: 'Forest Green',
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFFA7F3D0),
    primaryDark: Color(0xFF047857),
    accent: Color(0xFF84CC16),
    accentLight: Color(0xFFD9F99D),
    background: Color(0xFFF0FBF5),
    surfaceVariant: Color(0xFFD1FAE5),
  );

  static const rose = AppPalette(
    id: 'rose',
    name: 'Rose Petal',
    primary: Color(0xFFEC4899),
    primaryLight: Color(0xFFFBCFE8),
    primaryDark: Color(0xFFBE185D),
    accent: Color(0xFFF43F5E),
    accentLight: Color(0xFFFFE4E6),
    background: Color(0xFFFFF0F7),
    surfaceVariant: Color(0xFFFCE7F3),
  );

  static const midnight = AppPalette(
    id: 'midnight',
    name: 'Midnight Purple',
    primary: Color(0xFF8B5CF6),
    primaryLight: Color(0xFFDDD6FE),
    primaryDark: Color(0xFF6D28D9),
    accent: Color(0xFF6366F1),
    accentLight: Color(0xFFE0E7FF),
    background: Color(0xFFF5F0FF),
    surfaceVariant: Color(0xFFEDE9FE),
  );

  static const all = [amber, ocean, forest, rose, midnight];

  static AppPalette forId(String id) {
    return all.firstWhere((p) => p.id == id, orElse: () => amber);
  }
}
