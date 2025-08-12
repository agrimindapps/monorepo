// Flutter imports:
import 'package:flutter/foundation.dart';

/// Business rules configuration for VeiculosPage
///
/// This class manages all business logic rules that can be configured
/// externally without requiring code changes. Supports different user
/// profiles and remote configuration updates.
class VeiculosBusinessRules {
  // Private constructor for singleton pattern
  VeiculosBusinessRules._internal();
  static final VeiculosBusinessRules _instance =
      VeiculosBusinessRules._internal();
  static VeiculosBusinessRules get instance => _instance;

  // Current configuration
  VeiculosBusinessConfig _config = VeiculosBusinessConfig.defaultConfig();

  /// ========================================
  /// PUBLIC API
  /// ========================================

  /// Get current business configuration
  VeiculosBusinessConfig get config => _config;

  /// Update configuration (for remote config updates)
  void updateConfig(VeiculosBusinessConfig newConfig) {
    _config = newConfig;
    _validateConfiguration();
    if (kDebugMode) {
      debugPrint(
          '[VeiculosBusinessRules] Configuration updated: ${_config.profileName}');
    }
  }

  /// Load configuration from external source
  Future<void> loadConfiguration({
    UserProfile? profile,
    Map<String, dynamic>? remoteConfig,
  }) async {
    try {
      if (remoteConfig != null) {
        _config = VeiculosBusinessConfig.fromRemoteConfig(remoteConfig);
      } else if (profile != null) {
        _config = VeiculosBusinessConfig.fromProfile(profile);
      }
      _validateConfiguration();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VeiculosBusinessRules] Error loading config: $e');
      }
      // Fall back to default config
      _config = VeiculosBusinessConfig.defaultConfig();
    }
  }

  /// ========================================
  /// BUSINESS RULE GETTERS
  /// ========================================

  /// Maximum number of vehicles allowed
  int get maxVehicles => _config.maxVehicles;

  /// Minimum vehicle year allowed
  int get minVehicleYear => _config.minVehicleYear;

  /// Maximum vehicle year allowed (current year + future years)
  int get maxVehicleYear => _config.maxVehicleYear;

  /// Whether premium features are enabled
  bool get isPremiumEnabled => _config.isPremiumEnabled;

  /// Whether export features are enabled
  bool get isExportEnabled => _config.isExportEnabled;

  /// Whether advanced statistics are enabled
  bool get isAdvancedStatsEnabled => _config.isAdvancedStatsEnabled;

  /// Maximum file size for imports (in MB)
  double get maxImportFileSizeMB => _config.maxImportFileSizeMB;

  /// Whether bulk operations are enabled
  bool get isBulkOperationsEnabled => _config.isBulkOperationsEnabled;

  /// ========================================
  /// BUSINESS RULE VALIDATION METHODS
  /// ========================================

  /// Validate if user can create a new vehicle
  bool canCreateVehicle(int currentVehicleCount) {
    return currentVehicleCount < maxVehicles;
  }

  /// Validate vehicle year
  bool isValidVehicleYear(int year) {
    return year >= minVehicleYear && year <= maxVehicleYear;
  }

  /// Validate if operation is allowed for current profile
  bool isOperationAllowed(BusinessOperation operation) {
    switch (operation) {
      case BusinessOperation.export:
        return isExportEnabled;
      case BusinessOperation.advancedStats:
        return isAdvancedStatsEnabled;
      case BusinessOperation.bulkOperations:
        return isBulkOperationsEnabled;
      case BusinessOperation.premiumFeatures:
        return isPremiumEnabled;
    }
  }

  /// Get restriction message for denied operations
  String getRestrictionMessage(BusinessOperation operation) {
    switch (operation) {
      case BusinessOperation.export:
        return 'Funcionalidade de exportação disponível apenas para usuários premium.';
      case BusinessOperation.advancedStats:
        return 'Estatísticas avançadas disponíveis apenas para usuários premium.';
      case BusinessOperation.bulkOperations:
        return 'Operações em lote disponíveis apenas para usuários premium.';
      case BusinessOperation.premiumFeatures:
        return 'Esta funcionalidade está disponível apenas para usuários premium.';
    }
  }

  /// ========================================
  /// CONFIGURATION VALIDATION
  /// ========================================

  void _validateConfiguration() {
    assert(_config.maxVehicles > 0, 'maxVehicles must be greater than 0');
    assert(_config.minVehicleYear > 1900, 'minVehicleYear must be reasonable');
    assert(_config.maxVehicleYear >= _config.minVehicleYear,
        'maxVehicleYear must be >= minVehicleYear');
    assert(_config.maxImportFileSizeMB > 0,
        'maxImportFileSizeMB must be positive');
  }

  /// ========================================
  /// DEBUGGING AND MONITORING
  /// ========================================

  /// Get configuration summary for debugging
  Map<String, dynamic> getConfigSummary() {
    return {
      'profile': _config.profileName,
      'maxVehicles': _config.maxVehicles,
      'isPremium': _config.isPremiumEnabled,
      'exportEnabled': _config.isExportEnabled,
      'advancedStatsEnabled': _config.isAdvancedStatsEnabled,
      'bulkOpsEnabled': _config.isBulkOperationsEnabled,
      'yearRange': '${_config.minVehicleYear}-${_config.maxVehicleYear}',
      'maxImportSizeMB': _config.maxImportFileSizeMB,
    };
  }
}

/// ========================================
/// CONFIGURATION CLASS
/// ========================================

class VeiculosBusinessConfig {
  final String profileName;
  final int maxVehicles;
  final int minVehicleYear;
  final int maxVehicleYear;
  final bool isPremiumEnabled;
  final bool isExportEnabled;
  final bool isAdvancedStatsEnabled;
  final double maxImportFileSizeMB;
  final bool isBulkOperationsEnabled;

  const VeiculosBusinessConfig({
    required this.profileName,
    required this.maxVehicles,
    required this.minVehicleYear,
    required this.maxVehicleYear,
    required this.isPremiumEnabled,
    required this.isExportEnabled,
    required this.isAdvancedStatsEnabled,
    required this.maxImportFileSizeMB,
    required this.isBulkOperationsEnabled,
  });

  /// Default configuration (free tier)
  factory VeiculosBusinessConfig.defaultConfig() {
    final currentYear = DateTime.now().year;
    return VeiculosBusinessConfig(
      profileName: 'Free',
      maxVehicles: 2,
      minVehicleYear: 1950,
      maxVehicleYear: currentYear + 2,
      isPremiumEnabled: false,
      isExportEnabled: false,
      isAdvancedStatsEnabled: false,
      maxImportFileSizeMB: 1.0,
      isBulkOperationsEnabled: false,
    );
  }

  /// Configuration from user profile
  factory VeiculosBusinessConfig.fromProfile(UserProfile profile) {
    final currentYear = DateTime.now().year;

    switch (profile) {
      case UserProfile.free:
        return VeiculosBusinessConfig.defaultConfig();

      case UserProfile.premium:
        return VeiculosBusinessConfig(
          profileName: 'Premium',
          maxVehicles: 10,
          minVehicleYear: 1900,
          maxVehicleYear: currentYear + 5,
          isPremiumEnabled: true,
          isExportEnabled: true,
          isAdvancedStatsEnabled: true,
          maxImportFileSizeMB: 10.0,
          isBulkOperationsEnabled: true,
        );

      case UserProfile.enterprise:
        return VeiculosBusinessConfig(
          profileName: 'Enterprise',
          maxVehicles: 100,
          minVehicleYear: 1800,
          maxVehicleYear: currentYear + 10,
          isPremiumEnabled: true,
          isExportEnabled: true,
          isAdvancedStatsEnabled: true,
          maxImportFileSizeMB: 100.0,
          isBulkOperationsEnabled: true,
        );
    }
  }

  /// Configuration from remote config (Firebase Remote Config, etc.)
  factory VeiculosBusinessConfig.fromRemoteConfig(Map<String, dynamic> config) {
    final currentYear = DateTime.now().year;

    return VeiculosBusinessConfig(
      profileName: config['profile_name'] ?? 'Remote',
      maxVehicles: config['max_vehicles'] ?? 2,
      minVehicleYear: config['min_vehicle_year'] ?? 1950,
      maxVehicleYear: config['max_vehicle_year'] ?? currentYear + 2,
      isPremiumEnabled: config['is_premium_enabled'] ?? false,
      isExportEnabled: config['is_export_enabled'] ?? false,
      isAdvancedStatsEnabled: config['is_advanced_stats_enabled'] ?? false,
      maxImportFileSizeMB:
          (config['max_import_file_size_mb'] ?? 1.0).toDouble(),
      isBulkOperationsEnabled: config['is_bulk_operations_enabled'] ?? false,
    );
  }

  /// Convert to map for persistence
  Map<String, dynamic> toMap() {
    return {
      'profile_name': profileName,
      'max_vehicles': maxVehicles,
      'min_vehicle_year': minVehicleYear,
      'max_vehicle_year': maxVehicleYear,
      'is_premium_enabled': isPremiumEnabled,
      'is_export_enabled': isExportEnabled,
      'is_advanced_stats_enabled': isAdvancedStatsEnabled,
      'max_import_file_size_mb': maxImportFileSizeMB,
      'is_bulk_operations_enabled': isBulkOperationsEnabled,
    };
  }
}

/// ========================================
/// ENUMS
/// ========================================

enum UserProfile {
  free,
  premium,
  enterprise,
}

enum BusinessOperation {
  export,
  advancedStats,
  bulkOperations,
  premiumFeatures,
}

/// ========================================
/// CONFIGURATION PRESETS
/// ========================================

class VeiculosBusinessPresets {
  static const Map<String, VeiculosBusinessConfig> presets = {
    'free': VeiculosBusinessConfig(
      profileName: 'Free',
      maxVehicles: 2,
      minVehicleYear: 1950,
      maxVehicleYear: 2027,
      isPremiumEnabled: false,
      isExportEnabled: false,
      isAdvancedStatsEnabled: false,
      maxImportFileSizeMB: 1.0,
      isBulkOperationsEnabled: false,
    ),
    'premium': VeiculosBusinessConfig(
      profileName: 'Premium',
      maxVehicles: 10,
      minVehicleYear: 1900,
      maxVehicleYear: 2030,
      isPremiumEnabled: true,
      isExportEnabled: true,
      isAdvancedStatsEnabled: true,
      maxImportFileSizeMB: 10.0,
      isBulkOperationsEnabled: true,
    ),
    'enterprise': VeiculosBusinessConfig(
      profileName: 'Enterprise',
      maxVehicles: 100,
      minVehicleYear: 1800,
      maxVehicleYear: 2035,
      isPremiumEnabled: true,
      isExportEnabled: true,
      isAdvancedStatsEnabled: true,
      maxImportFileSizeMB: 100.0,
      isBulkOperationsEnabled: true,
    ),
  };

  static VeiculosBusinessConfig? getPreset(String name) {
    return presets[name];
  }

  static List<String> getAvailablePresets() {
    return presets.keys.toList();
  }
}
