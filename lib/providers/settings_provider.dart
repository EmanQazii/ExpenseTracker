import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();

  // Settings state
  AppThemeMode _themeMode = AppThemeMode.system;
  String _currency = 'PKR';
  String _currencySymbol = '₨';
  bool _budgetAlerts = true;
  bool _notifications = true;
  bool _isInitialized = false;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  bool get budgetAlerts => _budgetAlerts;
  bool get notifications => _notifications;
  bool get isInitialized => _isInitialized;

  // Convert AppThemeMode to Flutter's ThemeMode
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Currency map for symbols
  static const Map<String, String> currencySymbols = {
    'PKR': '₨',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'AED': 'د.إ',
    'SAR': 'ر.س',
  };

  /// Initialize settings - call this on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Initialize defaults if needed
      await _settingsService.initializeDefaultSettings();

      // Load all settings
      final settings = await _settingsService.getAllSettings();

      _themeMode = AppThemeMode.fromString(
        settings[SettingsKeys.theme] ?? 'system',
      );
      _currency = settings[SettingsKeys.currency] ?? 'PKR';
      _currencySymbol = currencySymbols[_currency] ?? '₨';
      _budgetAlerts = (settings[SettingsKeys.budgetAlert] ?? 'true') == 'true';
      _notifications =
          (settings[SettingsKeys.notifications] ?? 'true') == 'true';

      _isInitialized = true;

      // Setup notifications if enabled
      if (_notifications) {
        await _setupNotifications();
      }

      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Setup notifications based on settings
  Future<void> _setupNotifications() async {
    // Request permissions
    final hasPermission = await _notificationService.requestPermissions();
    if (!hasPermission) return;

    // Schedule daily reminder at 8 PM
    await _notificationService.scheduleDailyReminder(
      hour: 20,
      minute: 0,
      title: '💰 Daily Expense Reminder',
      body: 'Don\'t forget to track your expenses today!',
    );

    // Schedule weekly summary on Sunday at 6 PM
    await _notificationService.scheduleWeeklySummary(
      dayOfWeek: 7, // Sunday
      hour: 18,
      minute: 0,
    );
  }

  /// Update theme
  Future<bool> updateTheme(AppThemeMode mode) async {
    final success = await _settingsService.setSetting(
      SettingsKeys.theme,
      mode.value,
    );

    if (success) {
      _themeMode = mode;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update currency
  Future<bool> updateCurrency(String currency) async {
    final success = await _settingsService.setSetting(
      SettingsKeys.currency,
      currency,
    );

    if (success) {
      _currency = currency;
      _currencySymbol = currencySymbols[currency] ?? '₨';
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update budget alerts
  Future<bool> updateBudgetAlerts(bool value) async {
    final success = await _settingsService.setSetting(
      SettingsKeys.budgetAlert,
      value.toString(),
    );

    if (success) {
      _budgetAlerts = value;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update notifications
  Future<bool> updateNotifications(bool value) async {
    final success = await _settingsService.setSetting(
      SettingsKeys.notifications,
      value.toString(),
    );

    if (success) {
      _notifications = value;

      if (value) {
        // Enable notifications
        await _setupNotifications();
      } else {
        // Disable notifications
        await _notificationService.cancelAllNotifications();
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Check budget and send alert if needed
  Future<void> checkBudgetAlert({
    required String category,
    required double spent,
    required double budget,
  }) async {
    if (!_budgetAlerts) return;
    if (budget <= 0) return;

    final percentage = (spent / budget) * 100;

    // Only alert at 75%, 90%, and 100%+ thresholds
    if (percentage >= 75) {
      await _notificationService.showBudgetAlert(
        category: category,
        spentAmount: spent,
        budgetAmount: budget,
        percentage: percentage,
      );
    }
  }

  /// Send custom notification
  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notifications) return;

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Test notification
  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  /// Format amount with currency symbol
  String formatAmount(double amount, {bool showSymbol = true}) {
    final formatted = amount.toStringAsFixed(2);
    return showSymbol ? '$_currencySymbol $formatted' : formatted;
  }

  /// Parse amount string to double
  double parseAmount(String amount) {
    final cleaned = amount.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await _settingsService.setBatchSettings({
      SettingsKeys.theme: 'system',
      SettingsKeys.currency: 'PKR',
      SettingsKeys.budgetAlert: 'true',
      SettingsKeys.notifications: 'true',
    });

    _themeMode = AppThemeMode.system;
    _currency = 'PKR';
    _currencySymbol = '₨';
    _budgetAlerts = true;
    _notifications = true;

    await _setupNotifications();
    notifyListeners();
  }

  /// Clear cache and reload
  Future<void> reload() async {
    _settingsService.clearCache();
    _isInitialized = false;
    await initialize();
  }
}
