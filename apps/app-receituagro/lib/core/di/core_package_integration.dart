import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import '../../features/analytics/analytics_service.dart';
import '../providers/auth_notifier.dart';
import '../services/device_identity_service.dart';
import '../services/receituagro_validation_service.dart';
import 'injection_container.dart' as di;

/// Core Package Integration Configuration for ReceitaAgro
/// This file centralizes all Core Package service registrations
/// Following the patterns established in app-gasometer and app-plantis
class CorePackageIntegration {
  CorePackageIntegration._(); // Private constructor prevents instantiation

  static core.GetIt get _sl => di.sl;

  /// Initialize all Core Package services for ReceitaAgro
  static Future<void> initializeCoreServices() async {
    await _registerCoreRepositories();
    await _registerEnhancedServices();
    await _registerNetworkAndConnectivity();
    await _registerCrossAppServices();
    await _registerSyncAndFirebase();
    await _registerDevelopmentTools();
    await _registerReceitaAgroSpecificServices();
  }

  /// Initialize only auth-related Core Package services (Sprint 1)
  static Future<void> initializeAuthServices() async {
    await _registerAuthServices();
    await _registerAnalyticsServices();
    await _registerConnectivityServices(); // Added for EnhancedConnectivityService
    await _registerPerformanceAndCrashlyticsServices(); // Added for Firebase services migration
    await _registerReceitaAgroAuthServices();
  }

  /// Register connectivity services needed for Sprint 1
  static Future<void> _registerConnectivityServices() async {
    try {
      _sl.registerLazySingleton<core.EnhancedConnectivityService>(
        () => core.EnhancedConnectivityService(),
      );
      if (kDebugMode) {
        developer.log(
          'Enhanced Connectivity Service registered',
          name: 'CorePackageIntegration',
          level: 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Enhanced Connectivity Service registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register Core Package repositories (primary integration layer)
  static Future<void> _registerCoreRepositories() async {
    // ✅ Storage implementation simplified
    // Legacy storage removed
    
    // ⚠️ REMOVED: EnhancedStorageService no longer exists
    // try {
    //   _sl.registerLazySingleton<core.EnhancedStorageService>(
    //     () => core.EnhancedStorageService(),
    //   );
    // } catch (e) {
    //   if (kDebugMode) {
    //     developer.log(
    //       'EnhancedStorageService registration failed',
    //       name: 'CorePackageIntegration',
    //       error: e,
    //       level: 1000,
    //     );
    //   }
    // }
    try {
      _sl.registerLazySingleton<core.IFileRepository>(
        () => core.FileManagerService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'IFileRepository registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    // IAuthRepository is already registered by core.InjectionContainer.init()
    // IStorageRepository is already registered by core.InjectionContainer.init()
  }

  /// Register enhanced services from Core Package
  static Future<void> _registerEnhancedServices() async {
    try {
      _sl.registerLazySingleton<core.EnhancedLoggingService>(
        () => core.EnhancedLoggingService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'EnhancedLoggingService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.SecurityService>(
        () => core.SecurityService.instance,
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'SecurityService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.EnhancedSecurityService>(
        () => core.EnhancedSecurityService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'EnhancedSecurityService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.IPerformanceRepository>(
        () => core.PerformanceService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'IPerformanceRepository registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.ValidationService>(
        () => core.ValidationService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'ValidationService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.EnhancedImageService>(
        () => core.EnhancedImageService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'EnhancedImageService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register network and connectivity services
  static Future<void> _registerNetworkAndConnectivity() async {
    // EnhancedConnectivityService is already registered in _registerConnectivityServices()
    // Skip duplicate registration
    try {
      _sl.registerLazySingleton<core.HttpClientService>(
        () => core.HttpClientService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'HttpClientService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register cross-app services for monorepo consistency
  static Future<void> _registerCrossAppServices() async {
    try {
      _sl.registerLazySingleton<core.MonorepoAuthCache>(
        () => core.MonorepoAuthCache(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'MonorepoAuthCache registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
    try {
      _sl.registerLazySingleton<core.FileManagerService>(
        () => core.FileManagerService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'FileManagerService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register sync and Firebase services
  static Future<void> _registerSyncAndFirebase() async {
    try {
      if (kDebugMode) {
        developer.log(
          'SelectiveSyncService registration disabled',
          name: 'CorePackageIntegration',
          level: 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'SelectiveSyncService registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register development and debugging tools
  static Future<void> _registerDevelopmentTools() async {
    if (kDebugMode) {
      developer.log(
        'DatabaseInspectorService registration disabled - constructor may require parameters',
        name: 'CorePackageIntegration',
        level: 500,
      );
    }
  }

  /// Register ReceitaAgro-specific services that extend Core Package functionality
  static Future<void> _registerReceitaAgroSpecificServices() async {
    _sl.registerLazySingleton<ReceitaAgroValidationService>(
      () => ReceitaAgroValidationService(),
    );
    await _initializeEnhancedServices();
  }

  /// Initialize services that require dependencies
  static Future<void> _initializeEnhancedServices() async {
    try {
      final validationService = _sl<ReceitaAgroValidationService>();
      if (_sl.isRegistered<core.ValidationService>()) {
        validationService.initialize(_sl<core.ValidationService>());
      } else {
        if (kDebugMode) {
          developer.log(
            'Core ValidationService not available for ReceitaAgro Validation initialization',
            name: 'CorePackageIntegration',
            level: 900,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'ReceitaAgro Validation Service initialization failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Get Core Package service integration status
  static Map<String, bool> getIntegrationStatus() {
    final services = {
      'EnhancedLoggingService': _sl.isRegistered<core.EnhancedLoggingService>(),
      'EnhancedSecurityService':
          _sl.isRegistered<core.EnhancedSecurityService>(),
      'SecurityService': _sl.isRegistered<core.SecurityService>(),
      'PerformanceService': _sl.isRegistered<core.IPerformanceRepository>(),
      'ValidationService': _sl.isRegistered<core.ValidationService>(),
      'EnhancedConnectivityService':
          _sl.isRegistered<core.EnhancedConnectivityService>(),
      'HttpClientService': _sl.isRegistered<core.HttpClientService>(),
      'EnhancedImageService': _sl.isRegistered<core.EnhancedImageService>(),
      'MonorepoAuthCache': _sl.isRegistered<core.MonorepoAuthCache>(),
      // ⚠️ REMOVED: Services no longer exist
      // 'DatabaseInspectorService': false,
      // 'SelectiveSyncService': false,
      // 'SyncFirebaseService': false,
      // 'EnhancedStorageService': _sl.isRegistered<core.EnhancedStorageService>(),
      'FileManagerService': _sl.isRegistered<core.FileManagerService>(),
      'ReceitaAgroValidationService':
          _sl.isRegistered<ReceitaAgroValidationService>(),
    };

    return services;
  }

  /// Get integration statistics
  static Map<String, dynamic> getIntegrationStats() {
    final status = getIntegrationStatus();
    final totalServices = status.length;
    final integratedServices =
        status.values.where((integrated) => integrated).length;
    final integrationPercentage =
        (integratedServices / totalServices * 100).round();

    return {
      'total_services': totalServices,
      'integrated_services': integratedServices,
      'integration_percentage': integrationPercentage,
      'missing_services':
          status.entries
              .where((entry) => !entry.value)
              .map((entry) => entry.key)
              .toList(),
    };
  }

  /// Validate that all critical Core Package services are available
  static bool validateCriticalServicesIntegration() {
    final criticalServices = [
      'EnhancedLoggingService',
      'ValidationService',
      'MonorepoAuthCache',
      // ⚠️ REMOVED: 'EnhancedStorageService' no longer exists
    ];

    final status = getIntegrationStatus();
    return criticalServices.every((service) => status[service] == true);
  }

  /// Generate integration report for debugging
  static String generateIntegrationReport() {
    final stats = getIntegrationStats();
    final status = getIntegrationStatus();

    final buffer = StringBuffer();
    buffer.writeln('=== RECEITUAGRO CORE PACKAGE INTEGRATION REPORT ===');
    buffer.writeln(
      'Integration: ${stats['integration_percentage']}% (${stats['integrated_services']}/${stats['total_services']})',
    );
    buffer.writeln('');

    buffer.writeln('INTEGRATED SERVICES:');
    status.entries
        .where((entry) => entry.value)
        .forEach((entry) => buffer.writeln('✅ ${entry.key}'));

    buffer.writeln('');
    buffer.writeln('MISSING SERVICES:');
    status.entries
        .where((entry) => !entry.value)
        .forEach((entry) => buffer.writeln('❌ ${entry.key}'));

    buffer.writeln('');
    buffer.writeln(
      'CRITICAL SERVICES STATUS: ${validateCriticalServicesIntegration() ? "PASSED" : "FAILED"}',
    );

    return buffer.toString();
  }

  /// Register only auth services from Core Package
  static Future<void> _registerAuthServices() async {
    // ✅ Storage implementation simplified
    // Legacy storage removed
    
    // IAuthRepository is already registered by core.InjectionContainer.init()
    // Skip registration to avoid duplicate registration error
    if (kDebugMode) {
      developer.log(
        'Firebase Auth Service already registered by core package',
        name: 'CorePackageIntegration',
        level: 500,
      );
    }
  }

  /// Register analytics services from Core Package
  static Future<void> _registerAnalyticsServices() async {
    // IAnalyticsRepository and ICrashlyticsRepository are already registered by core.InjectionContainer.init()
    // Skip registration to avoid duplicate registration error
    if (kDebugMode) {
      developer.log(
        'Firebase Analytics Service already registered by core package',
        name: 'CorePackageIntegration',
        level: 500,
      );
      developer.log(
        'Firebase Crashlytics Service already registered by core package',
        name: 'CorePackageIntegration',
        level: 500,
      );
    }
  }

  /// Register Performance and Crashlytics services for Firebase migration
  static Future<void> _registerPerformanceAndCrashlyticsServices() async {
    try {
      if (!_sl.isRegistered<core.IPerformanceRepository>()) {
        _sl.registerLazySingleton<core.IPerformanceRepository>(
          () => core.PerformanceService(),
        );
        if (kDebugMode) {
          developer.log(
            'Performance Service registered',
            name: 'CorePackageIntegration',
            level: 500,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Performance Service registration failed',
          name: 'CorePackageIntegration',
          error: e,
          level: 1000,
        );
      }
    }
  }

  /// Register ReceitaAgro-specific auth services
  static Future<void> _registerReceitaAgroAuthServices() async {
    try {
      if (!_sl.isRegistered<ReceitaAgroAnalyticsService>()) {
        _sl.registerLazySingleton<ReceitaAgroAnalyticsService>(
          () => ReceitaAgroAnalyticsService(
            analyticsRepository: _sl<core.IAnalyticsRepository>(),
            crashlyticsRepository: _sl<core.ICrashlyticsRepository>(),
          ),
        );
        if (kDebugMode) {
          developer.log(
            'Analytics Service wrapper registered successfully',
            name: 'ReceitaAgroIntegration',
            level: 500,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Analytics Service wrapper registration failed',
          name: 'ReceitaAgroIntegration',
          error: e,
          level: 1000,
        );
      }
      rethrow;
    }
    // AuthNotifier is now managed by Riverpod, no need for DI registration

    if (kDebugMode) {
      developer.log(
        'Auth services registered successfully (Provider + Riverpod)',
        name: 'ReceitaAgroIntegration',
        level: 500,
      );
    }
  }
}
