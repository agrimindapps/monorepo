import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Settings provider following SOLID principles
/// 
/// Follows SRP: Single responsibility of managing settings state
/// Follows DIP: Depends on abstractions (SharedPreferences interface)
/// Follows OCP: Open for extension via new settings types
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required SharedPreferences preferences,
    required IAppRatingRepository appRatingRepository,
  }) : _preferences = preferences,
       _appRatingRepository = appRatingRepository {
    _loadSettings();
  }

  final SharedPreferences _preferences;
  final IAppRatingRepository _appRatingRepository;

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  bool _globalErrorBoundaryEnabled = true;
  bool _notificationsEnabled = true;
  bool _fuelAlertsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  // =========================================================================
  // GETTERS (Read-only access)
  // =========================================================================

  bool get globalErrorBoundaryEnabled => _globalErrorBoundaryEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get fuelAlertsEnabled => _fuelAlertsEnabled;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  // =========================================================================
  // BUSINESS LOGIC METHODS
  // =========================================================================

  /// Load settings from persistent storage
  Future<void> _loadSettings() async {
    _setLoading(true);
    
    try {
      _globalErrorBoundaryEnabled = _preferences.getBool('global_error_boundary_enabled') ?? true;
      _notificationsEnabled = _preferences.getBool('notifications_enabled') ?? true;
      _fuelAlertsEnabled = _preferences.getBool('fuel_alerts_enabled') ?? true;
      
      // Load theme mode
      final themeIndex = _preferences.getInt('theme_mode') ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeIndex];
      
      notifyListeners();
    } catch (e) {
      // Handle error silently - use defaults
      debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle error boundary setting
  Future<void> toggleErrorBoundary(bool enabled) async {
    if (_globalErrorBoundaryEnabled == enabled) return;
    
    _setLoading(true);
    try {
      await _preferences.setBool('global_error_boundary_enabled', enabled);
      _globalErrorBoundaryEnabled = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving error boundary setting: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle notifications setting
  Future<void> toggleNotifications(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    
    _setLoading(true);
    try {
      await _preferences.setBool('notifications_enabled', enabled);
      _notificationsEnabled = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle fuel alerts setting
  Future<void> toggleFuelAlerts(bool enabled) async {
    if (_fuelAlertsEnabled == enabled) return;
    
    _setLoading(true);
    try {
      await _preferences.setBool('fuel_alerts_enabled', enabled);
      _fuelAlertsEnabled = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving fuel alerts setting: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Change theme mode
  Future<void> changeTheme(ThemeMode newTheme) async {
    if (_themeMode == newTheme) return;
    
    _setLoading(true);
    try {
      await _preferences.setInt('theme_mode', newTheme.index);
      _themeMode = newTheme;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme setting: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Handle app rating with business logic
  Future<bool> handleAppRating(BuildContext context) async {
    try {
      return await _appRatingRepository.showRatingDialog(context: context);
    } catch (e) {
      debugPrint('Error showing app rating: $e');
      return false;
    }
  }

  /// Check if app rating can be shown
  Future<bool> canShowRating() async {
    try {
      return await _appRatingRepository.canShowRatingDialog();
    } catch (e) {
      debugPrint('Error checking rating availability: $e');
      return false;
    }
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // =========================================================================
  // CLEANUP
  // =========================================================================

}