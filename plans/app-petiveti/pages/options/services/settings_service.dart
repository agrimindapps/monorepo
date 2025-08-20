// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../models/settings_model.dart';

class SettingsService {
  static const String _boxName = 'settings_box';
  static const String _settingsKey = 'app_settings';

  Box<String>? _box;

  Future<void> _initializeBox() async {
    if (_box == null || !_box!.isOpen) {
      try {
        _box = await Hive.openBox<String>(_boxName);
      } catch (e) {
        debugPrint('Error opening settings box: $e');
        rethrow;
      }
    }
  }

  Future<SettingsData> loadSettings() async {
    try {
      await _initializeBox();
      
      final jsonString = _box?.get(_settingsKey);
      if (jsonString == null) {
        return SettingsRepository.getDefaultSettings();
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return SettingsData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return SettingsRepository.getDefaultSettings();
    }
  }

  Future<void> saveSettings(SettingsData settings) async {
    try {
      await _initializeBox();
      
      final jsonString = jsonEncode(settings.toJson());
      await _box?.put(_settingsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<void> clearSettings() async {
    try {
      await _initializeBox();
      await _box?.delete(_settingsKey);
    } catch (e) {
      debugPrint('Error clearing settings: $e');
      throw Exception('Failed to clear settings: $e');
    }
  }

  Future<bool> hasSettings() async {
    try {
      await _initializeBox();
      return _box?.containsKey(_settingsKey) ?? false;
    } catch (e) {
      debugPrint('Error checking settings existence: $e');
      return false;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = SettingsRepository.getDefaultSettings();
      await saveSettings(defaultSettings);
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
      throw Exception('Failed to reset settings: $e');
    }
  }

  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await loadSettings();
      return {
        'settings': settings.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      throw Exception('Failed to export settings: $e');
    }
  }

  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData == null) {
        throw Exception('Invalid settings data');
      }

      final settings = SettingsData.fromJson(settingsData);
      await saveSettings(settings);
    } catch (e) {
      debugPrint('Error importing settings: $e');
      throw Exception('Failed to import settings: $e');
    }
  }

  Future<void> updateLastBackupDate(DateTime date) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(lastBackupDate: date);
      await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error updating backup date: $e');
      throw Exception('Failed to update backup date: $e');
    }
  }

  Future<Map<String, dynamic>> getSettingsInfo() async {
    try {
      await _initializeBox();
      
      final hasData = await hasSettings();
      final settings = hasData ? await loadSettings() : null;
      
      return {
        'hasSettings': hasData,
        'boxIsOpen': _box?.isOpen ?? false,
        'settingsVersion': settings != null ? '1.0' : null,
        'lastModified': settings != null ? DateTime.now().toIso8601String() : null,
      };
    } catch (e) {
      debugPrint('Error getting settings info: $e');
      return {
        'hasSettings': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> dispose() async {
    try {
      await _box?.close();
      _box = null;
    } catch (e) {
      debugPrint('Error disposing settings service: $e');
    }
  }
}
