library;

export 'src/domain/entities/auth_result.dart';
// ========== DOMAIN LAYER ==========
// Entities
export 'src/domain/entities/base_entity.dart';
export 'src/domain/entities/base_sync_entity.dart';
export 'src/domain/entities/box_sync_config.dart';
export 'src/domain/entities/custom_box_type.dart';
export 'src/domain/entities/database_record.dart';
export 'src/domain/entities/file_entity.dart';
export 'src/domain/entities/log_entry.dart';
export 'src/domain/entities/module_auth_config.dart';
export 'src/domain/entities/notification_entity.dart';
export 'src/domain/entities/performance_entity.dart';
export 'src/domain/entities/profile_image_result.dart';
export 'src/domain/entities/security_entity.dart';
export 'src/domain/entities/shared_preferences_record.dart';
export 'src/domain/entities/subscription_entity.dart';
export 'src/domain/entities/user_entity.dart';
export 'src/domain/entities/device_entity.dart';

// Data Migration Entities
export 'src/domain/entities/data_migration/anonymous_data.dart';
export 'src/domain/entities/data_migration/account_data.dart';
export 'src/domain/entities/data_migration/data_conflict_result.dart';
export 'src/domain/entities/data_migration/data_resolution_choice.dart';
export 'src/domain/repositories/i_analytics_repository.dart';
export 'src/domain/repositories/i_app_rating_repository.dart';
// Repository Interfaces
export 'src/domain/repositories/i_auth_repository.dart';
// Box Registry Service (NEW - Clean Architecture Pattern)
export 'src/domain/services/i_box_registry_service.dart';
export 'src/domain/repositories/i_crashlytics_repository.dart';
export 'src/domain/repositories/i_encrypted_storage_repository.dart';
export 'src/domain/repositories/i_file_repository.dart';
export 'src/domain/repositories/i_local_storage_repository.dart';
export 'src/domain/repositories/i_notification_repository.dart';
export 'src/domain/repositories/i_performance_repository.dart';
export 'src/domain/repositories/i_security_repository.dart';
export 'src/domain/repositories/i_storage_repository.dart';
export 'src/domain/repositories/i_subscription_repository.dart';
export 'src/domain/repositories/i_sync_repository.dart';
export 'src/domain/repositories/i_device_repository.dart';
export 'src/domain/usecases/auth/login_usecase.dart';
export 'src/domain/usecases/auth/logout_usecase.dart';
// Use Cases
export 'src/domain/usecases/base_usecase.dart';
export 'src/domain/usecases/get_user_devices_usecase.dart';
export 'src/domain/usecases/validate_device_usecase.dart';
export 'src/domain/usecases/revoke_device_usecase.dart';
// Helpers
export 'src/infrastructure/helpers/notification_helper.dart';
export 'src/infrastructure/services/app_rating_service.dart';
export 'src/infrastructure/services/connectivity_service.dart';
export 'src/infrastructure/services/database_inspector_service.dart';
export 'src/infrastructure/services/enhanced_connectivity_service.dart';
export 'src/infrastructure/services/enhanced_image_service.dart';
export 'src/infrastructure/services/enhanced_logging_service.dart';
export 'src/infrastructure/services/enhanced_security_service.dart';
export 'src/infrastructure/services/enhanced_storage_service.dart';
export 'src/infrastructure/services/file_manager_service.dart';
export 'src/infrastructure/services/firebase_analytics_service.dart';
// ========== INFRASTRUCTURE LAYER ==========
// Box Registry Models and Services (NEW - Clean Architecture)
export 'src/infrastructure/models/box_configuration.dart';
export 'src/infrastructure/services/box_registry_service.dart';
// Core Services (Existing)
export 'src/infrastructure/services/firebase_auth_service.dart';
export 'src/infrastructure/services/firebase_crashlytics_service.dart';
export 'src/infrastructure/services/firebase_storage_service.dart';
export 'src/infrastructure/services/hive_storage_service.dart';
// Enhanced Services (New)
export 'src/infrastructure/services/http_client_service.dart';
export 'src/infrastructure/services/image_service.dart';
export 'src/infrastructure/services/local_notification_service.dart';
export 'src/infrastructure/services/log_repository_service.dart';
export 'src/infrastructure/services/mock_analytics_service.dart';
export 'src/infrastructure/services/monorepo_auth_cache.dart';
export 'src/infrastructure/services/performance_service.dart';
export 'src/infrastructure/services/profile_image_service.dart';
export 'src/infrastructure/services/revenue_cat_service.dart';
export 'src/infrastructure/services/security_service.dart';
export 'src/infrastructure/services/selective_sync_service.dart';
export 'src/infrastructure/services/sync_firebase_service.dart';
export 'src/infrastructure/services/validation_service.dart';
export 'src/infrastructure/services/web_notification_service.dart';

// Device Management Services
export 'src/infrastructure/services/device_management_service.dart';
export 'src/infrastructure/services/firebase_device_service.dart';

// Data Migration Services
export 'src/infrastructure/services/data_migration_service.dart';
export 'src/infrastructure/services/anonymous_data_cleaner.dart';

// ========== UNIFIED SYNC SYSTEM ==========
// Unified Sync Manager and Components
export 'src/sync/app_sync_config.dart';
export 'src/sync/conflict_resolution/conflict_resolver_factory.dart' hide SyncFailure;
export 'src/sync/entity_sync_registration.dart' hide IConflictResolver;
export 'src/sync/providers/unified_sync_provider.dart';
export 'src/sync/unified_sync_manager.dart';

// Hive Storage Infrastructure
export 'src/infrastructure/storage/hive/hive_storage.dart';
// Theme System (temporarily disabled - files were removed)
// export 'src/presentation/theme/base/base_colors.dart';
// export 'src/presentation/theme/base/base_theme.dart';
// export 'src/presentation/theme/base/base_typography.dart';
export 'src/presentation/theme/providers/theme_provider.dart';
// export 'src/presentation/widgets/error_widget.dart';
// export 'src/presentation/widgets/image_widgets.dart';
// ========== PRESENTATION LAYER ==========
// Widgets (temporarily disabled - files were removed)
// export 'src/presentation/widgets/loading_widget.dart';
// export 'src/presentation/widgets/profile_avatar.dart';
// export 'src/presentation/widgets/profile_image_picker.dart';

// Data Migration Widgets (temporarily disabled - files were removed)
// export 'src/presentation/widgets/data_migration/data_conflict_dialog.dart';
// export 'src/presentation/widgets/data_migration/migration_progress_dialog.dart';

// ========== DATA INSPECTOR ==========
// Unified Data Inspector for all monorepo apps (temporarily disabled - files were removed)
// export 'src/presentation/data_inspector.dart';

// ========== SHARED LAYER ==========
// Config
export 'src/shared/config/environment_config.dart';
// Dependency Injection
export 'src/shared/di/injection_container.dart';
// Enums
export 'src/shared/enums/log_level.dart';
// Extensions
export 'src/shared/extensions/log_level_extensions.dart';
// Contracts for shared services
export 'src/shared/contracts/i_asset_loader.dart';
export 'src/shared/contracts/i_version_manager.dart';
// Services (Moved from app-receituagro)
export 'src/shared/services/asset_loader_service.dart';
export 'src/shared/services/cache_management_service.dart' hide CacheConfig;
export 'src/shared/services/navigation_service.dart';
export 'src/shared/services/optimized_image_service.dart';
export 'src/shared/services/preferences_service.dart';
export 'src/shared/services/version_manager_service.dart';
// Features
export 'src/features/subscription/subscription_page.dart';
export 'src/shared/utils/app_error.dart';
export 'src/shared/utils/error_adapter.dart';
// Utils
export 'src/shared/utils/failure.dart';
export 'src/shared/utils/result.dart';

// ========== UNIFIED SUBSCRIPTION SYSTEM ==========
// Unified Subscription Services (Simplified Implementation)
export 'src/services/simple_subscription_sync_service.dart';