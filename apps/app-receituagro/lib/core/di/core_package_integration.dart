// Flutter imports
// Package imports
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

// Local imports
import '../../features/analytics/enhanced_analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../services/device_identity_service.dart';
import '../services/receituagro_validation_service.dart';
import 'injection_container.dart' as di;

/// Core Package Integration Configuration for ReceitaAgro
/// This file centralizes all Core Package service registrations
/// Following the patterns established in app-gasometer and app-plantis
class CorePackageIntegration {
  // Use the same GetIt instance as injection_container.dart
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
    await _registerReceitaAgroAuthServices();
  }

  /// Register connectivity services needed for Sprint 1
  static Future<void> _registerConnectivityServices() async {
    // Enhanced Connectivity Service (needed by main.dart initialization)
    try {
      _sl.registerLazySingleton<core.EnhancedConnectivityService>(
        () => core.EnhancedConnectivityService(),
      );
      if (kDebugMode) print('✅ Core Package: Enhanced Connectivity Service registered');
    } catch (e) {
      if (kDebugMode) print('❌ Core Package: Enhanced Connectivity Service registration failed - $e');
    }
  }

  /// Register Core Package repositories (primary integration layer)
  static Future<void> _registerCoreRepositories() async {
    // Hive Manager from Core Package (essential for Hive repositories)
    try {
      final hiveManager = core.HiveManager.instance;
      _sl.registerLazySingleton<core.IHiveManager>(() => hiveManager);
      
      // Initialize the HiveManager
      final initResult = await hiveManager.initialize('receituagro');
      if (!initResult.isError) {
        if (kDebugMode) print('✅ Core Package: Hive Manager registered and initialized');
      } else {
        if (kDebugMode) print('❌ Core Package: Hive Manager initialization failed - ${initResult.error}');
      }
    } catch (e) {
      if (kDebugMode) print('IHiveManager registration failed: $e');
    }
    
    // Enhanced Storage Service from Core Package (advanced features)
    try {
      _sl.registerLazySingleton<core.EnhancedStorageService>(
        () => core.EnhancedStorageService(),
      );
    } catch (e) {
      // Fallback if constructor not available
      if (kDebugMode) print('EnhancedStorageService registration failed: $e');
    }
    
    // File Repository from Core Package
    try {
      _sl.registerLazySingleton<core.IFileRepository>(
        () => core.FileManagerService(),
      );
    } catch (e) {
      if (kDebugMode) print('IFileRepository registration failed: $e');
    }
    
    // Auth Repository from Core Package
    try {
      _sl.registerLazySingleton<core.IAuthRepository>(
        () => core.FirebaseAuthService(),
      );
    } catch (e) {
      if (kDebugMode) print('IAuthRepository registration failed: $e');
    }
    
    // Storage Repository from Core Package
    try {
      _sl.registerLazySingleton<core.IStorageRepository>(
        () => core.FirebaseStorageService(),
      );
    } catch (e) {
      if (kDebugMode) print('IStorageRepository registration failed: $e');
    }
    
    // Encrypted Storage Repository - Currently not implemented in Core Package
    // Using Enhanced Storage Service instead
    // _sl.registerLazySingleton<core.IEncryptedStorageRepository>(
    //   () => core.EncryptedStorageService(), // When available
    // );
  }

  /// Register enhanced services from Core Package
  static Future<void> _registerEnhancedServices() async {
    // Enhanced Logging Service (replaces local ErrorHandlerService)
    try {
      _sl.registerLazySingleton<core.EnhancedLoggingService>(
        () => core.EnhancedLoggingService(),
      );
    } catch (e) {
      if (kDebugMode) print('EnhancedLoggingService registration failed: $e');
    }
    
    // Security Service from Core Package (singleton instance)
    try {
      _sl.registerLazySingleton<core.SecurityService>(
        () => core.SecurityService.instance,
      );
    } catch (e) {
      if (kDebugMode) print('SecurityService registration failed: $e');
    }
    
    // Enhanced Security Service (separate service with additional features)
    try {
      _sl.registerLazySingleton<core.EnhancedSecurityService>(
        () => core.EnhancedSecurityService(),
      );
    } catch (e) {
      if (kDebugMode) print('EnhancedSecurityService registration failed: $e');
    }
    
    // Performance Service
    try {
      _sl.registerLazySingleton<core.IPerformanceRepository>(
        () => core.PerformanceService(),
      );
    } catch (e) {
      if (kDebugMode) print('IPerformanceRepository registration failed: $e');
    }
    
    // Validation Service from Core Package
    try {
      _sl.registerLazySingleton<core.ValidationService>(
        () => core.ValidationService(),
      );
    } catch (e) {
      if (kDebugMode) print('ValidationService registration failed: $e');
    }
    
    // Enhanced Image Service (replaces OptimizedImageService)
    try {
      _sl.registerLazySingleton<core.EnhancedImageService>(
        () => core.EnhancedImageService(),
      );
    } catch (e) {
      if (kDebugMode) print('EnhancedImageService registration failed: $e');
    }
  }

  /// Register network and connectivity services
  static Future<void> _registerNetworkAndConnectivity() async {
    // Enhanced Connectivity Service
    try {
      _sl.registerLazySingleton<core.EnhancedConnectivityService>(
        () => core.EnhancedConnectivityService(),
      );
    } catch (e) {
      if (kDebugMode) print('EnhancedConnectivityService registration failed: $e');
    }
    
    // Http Client Service (standardizes all network requests)
    try {
      _sl.registerLazySingleton<core.HttpClientService>(
        () => core.HttpClientService(),
      );
    } catch (e) {
      if (kDebugMode) print('HttpClientService registration failed: $e');
    }
  }

  /// Register cross-app services for monorepo consistency
  static Future<void> _registerCrossAppServices() async {
    // Monorepo Auth Cache (essential for cross-app authentication)
    try {
      _sl.registerLazySingleton<core.MonorepoAuthCache>(
        () => core.MonorepoAuthCache(),
      );
    } catch (e) {
      if (kDebugMode) print('MonorepoAuthCache registration failed: $e');
    }
    
    // File Manager Service
    try {
      _sl.registerLazySingleton<core.FileManagerService>(
        () => core.FileManagerService(),
      );
    } catch (e) {
      if (kDebugMode) print('FileManagerService registration failed: $e');
    }
  }

  /// Register sync and Firebase services
  static Future<void> _registerSyncAndFirebase() async {
    // Selective Sync Service from Core Package - may require parameters
    try {
      // SelectiveSyncService constructor may require parameters - commenting out for now
      // _sl.registerLazySingleton<core.SelectiveSyncService>(
      //   () => core.SelectiveSyncService(hiveStorage: storage), // Requires hiveStorage parameter
      // );
      if (kDebugMode) print('SelectiveSyncService registration disabled - constructor requires hiveStorage parameter');
    } catch (e) {
      if (kDebugMode) print('SelectiveSyncService registration failed: $e');
    }
    
    // Sync Firebase Service factory - uses getInstance pattern
    // Individual instances should be created as needed using:
    // core.SyncFirebaseService.getInstance(collectionName, fromMap, toMap)
  }

  /// Register development and debugging tools
  static Future<void> _registerDevelopmentTools() async {
    // Database Inspector Service - Only available in debug/development mode
    // Commented out as constructor may require parameters not available
    if (kDebugMode) {
      // try {
      //   _sl.registerLazySingleton<core.DatabaseInspectorService>(
      //     () => core.DatabaseInspectorService(), // Constructor may require parameters
      //   );
      // } catch (e) {
        if (kDebugMode) print('DatabaseInspectorService registration disabled - constructor may require parameters');
      // }
    }
  }

  /// Register ReceitaAgro-specific services that extend Core Package functionality
  static Future<void> _registerReceitaAgroSpecificServices() async {
    // ReceitaAgro Validation Service (extends Core Package ValidationService)
    _sl.registerLazySingleton<ReceitaAgroValidationService>(
      () => ReceitaAgroValidationService(),
    );
    
    // Initialize services that require Core Package dependencies
    await _initializeEnhancedServices();
  }

  /// Initialize services that require dependencies
  static Future<void> _initializeEnhancedServices() async {
    try {
      // Initialize ReceitaAgro Validation Service with Core Package ValidationService
      final validationService = _sl<ReceitaAgroValidationService>();
      if (_sl.isRegistered<core.ValidationService>()) {
        validationService.initialize(_sl<core.ValidationService>());
      } else {
        if (kDebugMode) print('Core ValidationService not available for ReceitaAgro Validation initialization');
      }
    } catch (e) {
      if (kDebugMode) print('ReceitaAgro Validation Service initialization failed: $e');
    }
  }

  /// Get Core Package service integration status
  static Map<String, bool> getIntegrationStatus() {
    final services = {
      'EnhancedLoggingService': _sl.isRegistered<core.EnhancedLoggingService>(),
      'EnhancedSecurityService': _sl.isRegistered<core.EnhancedSecurityService>(),
      'SecurityService': _sl.isRegistered<core.SecurityService>(),
      'PerformanceService': _sl.isRegistered<core.IPerformanceRepository>(),
      'ValidationService': _sl.isRegistered<core.ValidationService>(),
      'EnhancedConnectivityService': _sl.isRegistered<core.EnhancedConnectivityService>(),
      'HttpClientService': _sl.isRegistered<core.HttpClientService>(),
      'EnhancedImageService': _sl.isRegistered<core.EnhancedImageService>(),
      'MonorepoAuthCache': _sl.isRegistered<core.MonorepoAuthCache>(),
      'DatabaseInspectorService': false, // Constructor requires parameters
      'SelectiveSyncService': false, // Constructor requires hiveStorage parameter
      'SyncFirebaseService': false, // Uses factory pattern, not registered
      'EnhancedStorageService': _sl.isRegistered<core.EnhancedStorageService>(),
      'FileManagerService': _sl.isRegistered<core.FileManagerService>(),
      'ReceitaAgroValidationService': _sl.isRegistered<ReceitaAgroValidationService>(),
    };
    
    return services;
  }

  /// Get integration statistics
  static Map<String, dynamic> getIntegrationStats() {
    final status = getIntegrationStatus();
    final totalServices = status.length;
    final integratedServices = status.values.where((integrated) => integrated).length;
    final integrationPercentage = (integratedServices / totalServices * 100).round();
    
    return {
      'total_services': totalServices,
      'integrated_services': integratedServices,
      'integration_percentage': integrationPercentage,
      'missing_services': status.entries
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
      'EnhancedStorageService',
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
    buffer.writeln('Integration: ${stats['integration_percentage']}% (${stats['integrated_services']}/${stats['total_services']})');
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
    buffer.writeln('CRITICAL SERVICES STATUS: ${validateCriticalServicesIntegration() ? "PASSED" : "FAILED"}');
    
    return buffer.toString();
  }

  // ===== AUTH-SPECIFIC SERVICES (Sprint 1) =====

  /// Register only auth services from Core Package
  static Future<void> _registerAuthServices() async {
    // Hive Manager from Core Package (essential for Hive repositories)
    try {
      final hiveManager = core.HiveManager.instance;
      _sl.registerLazySingleton<core.IHiveManager>(() => hiveManager);
      
      // Initialize the HiveManager
      final initResult = await hiveManager.initialize('receituagro');
      if (!initResult.isError) {
        if (kDebugMode) print('✅ Core Package: Hive Manager registered and initialized');
      } else {
        if (kDebugMode) print('❌ Core Package: Hive Manager initialization failed - ${initResult.error}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Core Package: Hive Manager registration failed - $e');
    }
    
    // Firebase Auth Service
    try {
      _sl.registerLazySingleton<core.IAuthRepository>(
        () => core.FirebaseAuthService(),
      );
      if (kDebugMode) print('✅ Core Package: Firebase Auth Service registered');
    } catch (e) {
      if (kDebugMode) print('❌ Core Package: Firebase Auth Service registration failed - $e');
    }
  }

  /// Register analytics services from Core Package
  static Future<void> _registerAnalyticsServices() async {
    // Firebase Analytics Service
    try {
      _sl.registerLazySingleton<core.IAnalyticsRepository>(
        () => core.FirebaseAnalyticsService(),
      );
      if (kDebugMode) print('✅ Core Package: Firebase Analytics Service registered');
    } catch (e) {
      if (kDebugMode) print('❌ Core Package: Firebase Analytics Service registration failed - $e');
    }

    // Firebase Crashlytics Service
    try {
      _sl.registerLazySingleton<core.ICrashlyticsRepository>(
        () => core.FirebaseCrashlyticsService(),
      );
      if (kDebugMode) print('✅ Core Package: Firebase Crashlytics Service registered');
    } catch (e) {
      if (kDebugMode) print('❌ Core Package: Firebase Crashlytics Service registration failed - $e');
    }

    // ReceitaAgro Enhanced Analytics Provider will be registered in _registerReceitaAgroAuthServices
    // to avoid duplicate registration
  }

  /// Register ReceitaAgro-specific auth services
  static Future<void> _registerReceitaAgroAuthServices() async {
    // Register ReceitaAgro Enhanced Analytics Service first
    try {
      if (!_sl.isRegistered<ReceitaAgroEnhancedAnalyticsProvider>()) {
        _sl.registerLazySingleton<ReceitaAgroEnhancedAnalyticsProvider>(
          () => ReceitaAgroEnhancedAnalyticsProvider(
            analyticsRepository: _sl<core.IAnalyticsRepository>(),
            crashlyticsRepository: _sl<core.ICrashlyticsRepository>(),
          ),
        );
        if (kDebugMode) print('✅ ReceitaAgroEnhancedAnalyticsProvider registered successfully');
      } else {
        if (kDebugMode) print('⚠️ ReceitaAgroEnhancedAnalyticsProvider already registered');
      }
    } catch (e) {
      if (kDebugMode) print('❌ ReceitaAgroEnhancedAnalyticsProvider registration failed: $e');
      rethrow; // Re-throw to see the actual error
    }

    // Register the alias for backward compatibility
    try {
      if (!_sl.isRegistered<ReceitaAgroAnalyticsService>()) {
        _sl.registerLazySingleton<ReceitaAgroAnalyticsService>(
          () => _sl<ReceitaAgroEnhancedAnalyticsProvider>(),
        );
        if (kDebugMode) print('✅ ReceitaAgro: Analytics Service alias registered');
      }
    } catch (e) {
      if (kDebugMode) print('❌ ReceitaAgro: Analytics Service alias registration failed - $e');
    }

    // Register ReceitaAgro Auth Provider (using UnifiedSyncManager from core package)
    if (!_sl.isRegistered<ReceitaAgroAuthProvider>()) {
      _sl.registerLazySingleton<ReceitaAgroAuthProvider>(
        () => ReceitaAgroAuthProvider(
          authRepository: _sl<core.IAuthRepository>(),
          deviceService: _sl<DeviceIdentityService>(),
          analytics: _sl<ReceitaAgroAnalyticsService>(),
        ),
      );
    }

    if (kDebugMode) print('✅ ReceitaAgro: Auth services registered successfully');
  }
}