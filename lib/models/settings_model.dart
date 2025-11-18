class SettingModel {
  final String key;
  final String value;
  final DateTime? updatedAt;

  SettingModel({required this.key, required this.value, this.updatedAt});

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      key: json['key'],
      value: json['value'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SettingModel copyWith({String? key, String? value, DateTime? updatedAt}) {
    return SettingModel(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Settings keys constants
class SettingsKeys {
  static const String theme = 'theme';
  static const String currency = 'currency';
  static const String budgetAlert = 'budget_alert';
  static const String notifications = 'notifications';
  static const String language = 'language';
  static const String biometricAuth = 'biometric_auth';
  static const String exportFormat = 'export_format';
}

// App theme modes (renamed to avoid conflict with Flutter's ThemeMode)
enum AppThemeMode {
  light,
  dark,
  system;

  String get value => name;

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
