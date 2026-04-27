import '../models/app_settings.dart';
import '../services/database_service.dart';

class SettingsRepository {
  AppSettings getSettings() => DatabaseService.getSettings();

  Future<void> saveSettings(AppSettings settings) =>
      DatabaseService.saveSettings(settings);

  Future<void> completeOnboarding() async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(hasCompletedOnboarding: true));
  }

  bool get hasCompletedOnboarding => getSettings().hasCompletedOnboarding;
}
