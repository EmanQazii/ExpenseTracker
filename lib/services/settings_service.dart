import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';

class SettingsService {
  final _supabase = Supabase.instance.client;

  String get userId => _supabase.auth.currentUser!.id;

  // Cache for settings to reduce database calls
  final Map<String, String> _cache = {};

  /// Fetch specific setting with caching
  Future<String?> getSetting(String key, {bool useCache = true}) async {
    if (useCache && _cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final data = await _supabase
          .from('settings')
          .select('value')
          .eq('user_id', userId)
          .eq('key', key)
          .maybeSingle();

      final value = data?['value'];
      if (value != null) {
        _cache[key] = value;
      }
      return value;
    } catch (e) {
      print('Error fetching setting $key: $e');
      return null;
    }
  }

  /// Update or insert setting with proper upsert
  Future<bool> setSetting(String key, String value) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Use upsert with proper conflict resolution
      await _supabase.from('settings').upsert(
        {'user_id': userId, 'key': key, 'value': value, 'updated_at': now},
        onConflict: 'user_id,key', // Specify the unique constraint columns
      );

      _cache[key] = value;
      return true;
    } catch (e) {
      print('Error setting $key: $e');

      // If upsert fails, try direct insert as fallback
      try {
        await _supabase.from('settings').insert({
          'user_id': userId,
          'key': key,
          'value': value,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        _cache[key] = value;
        return true;
      } catch (insertError) {
        print('Error inserting $key: $insertError');
        return false;
      }
    }
  }

  /// Load all settings
  Future<Map<String, String>> getAllSettings() async {
    try {
      final data = await _supabase
          .from('settings')
          .select()
          .eq('user_id', userId);

      final settings = <String, String>{};
      for (var item in data) {
        settings[item['key']] = item['value'];
      }

      _cache.addAll(settings);
      return settings;
    } catch (e) {
      print('Error loading all settings: $e');
      return {};
    }
  }

  /// Initialize default settings for a new user
  Future<bool> initializeDefaultSettings() async {
    try {
      final existingSettings = await getAllSettings();

      // Only initialize if no settings exist
      if (existingSettings.isEmpty) {
        final defaults = {
          SettingsKeys.theme: 'system',
          SettingsKeys.currency: 'PKR',
          SettingsKeys.budgetAlert: 'true',
          SettingsKeys.notifications: 'true',
        };

        return await setBatchSettings(defaults);
      }

      return true;
    } catch (e) {
      print('Error initializing default settings: $e');
      return false;
    }
  }

  /// Batch update multiple settings
  Future<bool> setBatchSettings(Map<String, String> settings) async {
    try {
      final now = DateTime.now().toIso8601String();
      final records = settings.entries
          .map(
            (entry) => {
              'user_id': userId,
              'key': entry.key,
              'value': entry.value,
              'created_at': now,
              'updated_at': now,
            },
          )
          .toList();

      await _supabase
          .from('settings')
          .upsert(records, onConflict: 'user_id,key');

      _cache.addAll(settings);
      return true;
    } catch (e) {
      print('Error batch setting: $e');
      return false;
    }
  }

  /// Delete a setting
  Future<bool> deleteSetting(String key) async {
    try {
      await _supabase
          .from('settings')
          .delete()
          .eq('user_id', userId)
          .eq('key', key);

      _cache.remove(key);
      return true;
    } catch (e) {
      print('Error deleting setting $key: $e');
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Get setting with default value
  Future<String> getSettingOrDefault(String key, String defaultValue) async {
    final value = await getSetting(key);
    return value ?? defaultValue;
  }
}
