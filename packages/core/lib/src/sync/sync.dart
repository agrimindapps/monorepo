/// Unified export for the new SOLID-compliant sync architecture
/// 
/// This file provides easy access to all the new sync interfaces and
/// implementations that replace the monolithic UnifiedSyncManager.
/// 
/// Apps should import this file to access the new sync architecture:
/// ```dart
/// import 'package:core/src/sync/sync.dart';
/// ```
library sync;

// Core Interfaces - Define contracts for sync components
export 'interfaces/i_cache_manager.dart';
export 'interfaces/i_network_monitor.dart';
export 'interfaces/i_sync_orchestrator.dart';
export 'interfaces/i_sync_service.dart';

// Implementations - SOLID-compliant implementations of the interfaces
export 'implementations/cache_manager_impl.dart';
export 'implementations/network_monitor_impl.dart';
export 'implementations/sync_orchestrator_impl.dart';

// Configuration - Feature flags for gradual migration
export 'config/sync_feature_flags.dart';

// App-Specific Sync Services - Replacements for UnifiedSyncManager
export 'services/gasometer_sync_service.dart';
export 'services/plantis_sync_service.dart';
export 'services/receituagro_sync_service.dart';
export 'services/petiveti_sync_service.dart';

// Examples - Reference implementations for apps
// export 'examples/example_sync_service.dart'; // Disabled until implementation is complete

// Factories - For dynamic service creation following OCP
export 'factories/sync_service_factory.dart';

// Legacy support - The original UnifiedSyncManager (being phased out)
export 'unified_sync_manager.dart';

// Migration Components - For gradual transition from UnifiedSyncManager
export 'migration/legacy_sync_bridge.dart';
export 'migration/app_migration_helper.dart';
export 'migration/migration_cli.dart';