import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';
import 'database_provider.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(_repo.getSettings());

  void refresh() => state = _repo.getSettings();

  Future<void> completeOnboarding() async {
    await _repo.completeOnboarding();
    refresh();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _repo.saveSettings(settings);
    refresh();
  }

  Future<void> toggleShowCompleted() async {
    await _repo.saveSettings(
      state.copyWith(showCompletedTasks: !state.showCompletedTasks),
    );
    refresh();
  }

  Future<void> setDefaultView(int index) async {
    await _repo.saveSettings(state.copyWith(defaultViewIndex: index));
    refresh();
  }

  Future<void> setWeekStartDay(int day) async {
    await _repo.saveSettings(state.copyWith(weekStartDay: day));
    refresh();
  }

  Future<void> toggleNotifications() async {
    await _repo.saveSettings(
      state.copyWith(notificationsEnabled: !state.notificationsEnabled),
    );
    refresh();
  }

  Future<void> setTheme(String id) async {
    await _repo.saveSettings(state.copyWith(themeId: id));
    refresh();
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});
