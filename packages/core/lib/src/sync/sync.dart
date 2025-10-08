/// Unified export for the new SOLID-compliant sync architecture
///
/// This file provides easy access to all the new sync interfaces and
/// implementations that replace the monolithic UnifiedSyncManager.
///
/// Apps should import this file to access the new sync architecture:
/// ```dart
/// import 'package:core/src/sync/sync.dart';
/// ```
library;
export 'background/background_sync_manager.dart';
export 'config/sync_feature_flags.dart';
export 'factories/sync_service_factory.dart';
export 'implementations/cache_manager_impl.dart';
export 'implementations/network_monitor_impl.dart';
export 'implementations/sync_orchestrator_impl.dart';
export 'interfaces/i_cache_manager.dart';
export 'interfaces/i_network_monitor.dart';
export 'interfaces/i_sync_orchestrator.dart';
export 'interfaces/i_sync_service.dart';
export 'migration/app_migration_helper.dart';
export 'migration/legacy_sync_bridge.dart';
export 'migration/migration_cli.dart';
export 'services/sync_logger.dart';
export 'throttling/sync_queue.dart';
export 'throttling/sync_throttler.dart';
export 'unified_sync_manager.dart';
