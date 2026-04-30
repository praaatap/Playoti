import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/today/today_screen.dart';
import '../../features/weekly/weekly_screen.dart';
import '../../features/monthly/monthly_screen.dart';
import '../../features/notes/notes_screen.dart';

import '../../features/task/task_create_screen.dart';
import '../../features/task/task_edit_screen.dart';
import '../../features/notes/note_editor_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/templates/templates_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.today,
            name: RouteNames.today,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.weekly,
            name: RouteNames.weekly,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WeeklyScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.monthly,
            name: RouteNames.monthly,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MonthlyScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.notes,
            name: RouteNames.notes,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.noteCreate,
        name: RouteNames.noteCreate,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NoteEditorScreen(noteId: null),
      ),
      GoRoute(
        path: RoutePaths.taskCreate,
        name: RouteNames.taskCreate,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final dateStr = state.uri.queryParameters['date'];
          final initialDate =
              dateStr != null ? DateTime.tryParse(dateStr) : null;
          return TaskCreateScreen(initialDate: initialDate);
        },
      ),
      GoRoute(
        path: RoutePaths.taskEdit,
        name: RouteNames.taskEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskEditScreen(taskId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.noteEdit,
        name: RouteNames.noteEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return NoteEditorScreen(noteId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.categories,
        name: RouteNames.categories,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.statistics,
        name: RouteNames.statistics,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.export_,
        name: RouteNames.export_,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.templates,
        name: RouteNames.templates,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TemplatesScreen(),
      ),
    ],
  );
});
