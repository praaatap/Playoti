class AppSettings {
  final bool hasCompletedOnboarding;
  final bool showCompletedTasks;
  final int defaultViewIndex;
  final int weekStartDay;
  final bool notificationsEnabled;
  final String defaultPriority;
  final String exportFormat;

  const AppSettings({
    this.hasCompletedOnboarding = false,
    this.showCompletedTasks = true,
    this.defaultViewIndex = 0,
    this.weekStartDay = 1,
    this.notificationsEnabled = true,
    this.defaultPriority = 'medium',
    this.exportFormat = 'json',
  });

  AppSettings copyWith({
    bool? hasCompletedOnboarding,
    bool? showCompletedTasks,
    int? defaultViewIndex,
    int? weekStartDay,
    bool? notificationsEnabled,
    String? defaultPriority,
    String? exportFormat,
  }) {
    return AppSettings(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      defaultViewIndex: defaultViewIndex ?? this.defaultViewIndex,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'showCompletedTasks': showCompletedTasks,
      'defaultViewIndex': defaultViewIndex,
      'weekStartDay': weekStartDay,
      'notificationsEnabled': notificationsEnabled,
      'defaultPriority': defaultPriority,
      'exportFormat': exportFormat,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      hasCompletedOnboarding: map['hasCompletedOnboarding'] as bool? ?? false,
      showCompletedTasks: map['showCompletedTasks'] as bool? ?? true,
      defaultViewIndex: map['defaultViewIndex'] as int? ?? 0,
      weekStartDay: map['weekStartDay'] as int? ?? 1,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      defaultPriority: map['defaultPriority'] as String? ?? 'medium',
      exportFormat: map['exportFormat'] as String? ?? 'json',
    );
  }
}
