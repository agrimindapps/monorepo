library;

export 'package:cached_network_image/cached_network_image.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:cloud_functions/cloud_functions.dart' hide Result;
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:dartz/dartz.dart' hide Order, State, id;
export 'package:device_info_plus/device_info_plus.dart';
export 'package:equatable/equatable.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_storage/firebase_storage.dart' hide Task;
export 'package:flutter/material.dart' show Column;
export 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:go_router/go_router.dart';
export 'package:google_sign_in/google_sign_in.dart';
export 'package:icons_plus/icons_plus.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:json_annotation/json_annotation.dart';
export 'package:logger/logger.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:purchases_flutter/purchases_flutter.dart' hide LogLevel, Store;
export 'package:riverpod/riverpod.dart' hide StreamProvider;
export 'package:share_plus/share_plus.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:shimmer/shimmer.dart';
export 'package:skeletonizer/skeletonizer.dart';
export 'package:sign_in_with_apple/sign_in_with_apple.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, AuthState, OAuthProvider, User;
export 'package:timezone/timezone.dart';
export 'package:url_launcher/url_launcher.dart';

export 'models/license_info.dart';
export 'repositories/license_repository.dart';
// ============================================================================
// DRIFT - Sistema de Persistência SQL (Padrão do Monorepo)
// ============================================================================
// Camada 1: Serviços Base (services/drift/)
export 'services/drift/base_drift_database.dart';
export 'services/drift/base_drift_repository.dart';
export 'services/drift/drift_database_config.dart';

// Camada 2: Infraestrutura Avançada (infrastructure/storage/drift/)
export 'src/infrastructure/storage/drift/drift_storage.dart';
export 'src/infrastructure/storage/drift/interfaces/i_drift_manager.dart';
export 'services/image_compression_service.dart';
export 'services/license_service.dart';
export 'services/shimmer_service.dart';
export 'src/data/repositories/base_supabase_repository.dart';
export 'src/domain/contracts/i_app_data_cleaner.dart';
export 'src/domain/entities/auth_result.dart';
export 'src/domain/entities/base_entity.dart';
export 'src/domain/entities/base_sync_entity.dart';
export 'src/domain/entities/box_sync_config.dart';
export 'src/domain/entities/custom_box_type.dart';
export 'src/domain/entities/data_migration/account_data.dart';
export 'src/domain/entities/data_migration/anonymous_data.dart';
export 'src/domain/entities/data_migration/data_conflict_result.dart';
export 'src/domain/entities/data_migration/data_resolution_choice.dart';
export 'src/domain/entities/database_record.dart';
export 'src/domain/entities/device_entity.dart';
export 'src/domain/entities/device_limit_config.dart';
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
// Auth Extensions
export 'features/auth/domain/extensions/user_entity_display_extension.dart';
export 'src/domain/repositories/i_analytics_repository.dart';
export 'src/domain/repositories/i_app_rating_repository.dart';
export 'src/domain/repositories/i_auth_repository.dart';
export 'src/domain/repositories/i_crashlytics_repository.dart';
export 'src/domain/repositories/i_device_repository.dart'
    hide DeviceValidationResult;
export 'src/domain/repositories/i_enhanced_notification_repository.dart';
export 'src/domain/repositories/i_file_repository.dart';
export 'src/domain/repositories/i_local_storage_repository.dart';
export 'src/domain/repositories/i_notification_repository.dart';
export 'src/domain/repositories/i_performance_repository.dart';
export 'src/domain/repositories/i_security_repository.dart';
export 'src/domain/repositories/i_storage_repository.dart';
export 'src/domain/repositories/i_subscription_repository.dart';
export 'src/domain/repositories/i_sync_repository.dart';
export 'src/domain/services/i_subscription_sync_service.dart';
export 'src/domain/usecases/auth/delete_account_usecase.dart';
export 'src/domain/usecases/auth/login_usecase.dart';
export 'src/domain/usecases/auth/logout_usecase.dart';
export 'src/domain/usecases/base_usecase.dart';
export 'src/domain/usecases/get_user_devices_usecase.dart';
export 'src/domain/usecases/revoke_device_usecase.dart';
export 'src/domain/usecases/validate_device_usecase.dart';
export 'src/features/subscription/subscription_page.dart';
export 'src/infrastructure/helpers/notification_analytics_helper.dart';
export 'src/infrastructure/helpers/notification_helper.dart';
export 'src/infrastructure/helpers/notification_migration_helper.dart';
export 'src/infrastructure/helpers/notification_template_engine.dart';
export 'src/infrastructure/services/account_deletion_rate_limiter.dart';
export 'src/infrastructure/services/account_deletion_service.dart';
export 'src/infrastructure/services/anonymous_data_cleaner.dart';
export 'src/infrastructure/services/app_rating_service.dart';
export 'src/infrastructure/services/auth/auth_account_service.dart';
export 'src/infrastructure/services/auth/auth_mapper_service.dart';
export 'src/infrastructure/services/auth/auth_provider_linking_service.dart';
export 'src/infrastructure/services/auth/auth_sign_in_service.dart';
export 'src/infrastructure/services/connectivity_service.dart';
export 'src/infrastructure/services/data_migration_service.dart';
export 'src/infrastructure/services/device_management_service.dart';
// Device Management - Unified Implementation
export 'src/infrastructure/repositories/datasources/device_local_datasource.dart';
export 'src/infrastructure/repositories/device_repository_impl.dart';
export 'src/infrastructure/services/enhanced_account_deletion_service.dart';
export 'src/infrastructure/services/enhanced_analytics_service.dart';
export 'src/infrastructure/services/enhanced_connectivity_service.dart';
export 'src/infrastructure/services/enhanced_firebase_auth_service.dart';
export 'src/infrastructure/services/enhanced_image_service.dart';
export 'src/infrastructure/services/enhanced_logging_service.dart';
export 'src/infrastructure/services/enhanced_notification_service.dart';
export 'src/infrastructure/services/enhanced_secure_storage_service.dart';
export 'src/infrastructure/services/enhanced_security_service.dart';
export 'src/infrastructure/services/file/directory_manager_service.dart';
export 'src/infrastructure/services/file/file_compression_service.dart';
export 'src/infrastructure/services/file/file_metadata_service.dart';
export 'src/infrastructure/services/file/file_operations_service.dart';
export 'src/infrastructure/services/file/file_watcher_service.dart';
export 'src/infrastructure/services/file_manager_service.dart';
export 'src/infrastructure/services/firebase_analytics_service.dart';
export 'src/infrastructure/services/firebase_auth_service.dart';
export 'src/infrastructure/services/firebase_crashlytics_service.dart';
export 'src/infrastructure/services/firebase_device_service.dart';
export 'src/infrastructure/services/firebase_storage_service.dart';
export 'src/infrastructure/services/firestore_deletion_service.dart';
export 'src/infrastructure/services/http_client_service.dart' hide CacheItem;
export 'src/infrastructure/services/image_service.dart';
export 'src/infrastructure/services/local_notification_service.dart';
export 'src/infrastructure/services/log_repository_service.dart';
export 'src/infrastructure/services/monorepo_auth_cache.dart';
export 'src/infrastructure/services/performance_service.dart';
export 'src/infrastructure/services/profile_image_service.dart';
export 'src/infrastructure/services/revenue_cat_service.dart';
export 'src/infrastructure/services/revenuecat_cancellation_service.dart';
export 'src/infrastructure/services/security_service.dart';
export 'src/infrastructure/services/sync_firebase_service.dart';
export 'src/infrastructure/services/validation_service.dart';
export 'src/infrastructure/services/web_notification_service.dart';
// Drift Storage Service e Sync Infrastructure
export 'src/infrastructure/storage/drift/services/drift_storage_service.dart';
export 'src/infrastructure/storage/drift/sync/adapters/drift_sync_adapter_base.dart';
export 'src/infrastructure/storage/drift/sync/interfaces/i_drift_sync_adapter.dart';
export 'src/infrastructure/storage/drift/sync/models/sync_results.dart';
export 'src/presentation/theme/base/base_colors.dart';
export 'src/presentation/theme/base/base_theme.dart';
export 'src/presentation/theme/base/base_typography.dart';
export 'src/presentation/widgets/account_deletion/account_deletion_confirmation_dialog.dart';
export 'src/presentation/widgets/account_deletion/account_deletion_progress_dialog.dart';
export 'src/riverpod/common_notifiers.dart';
export 'src/riverpod/common_providers.dart'
    hide
        currentUserProvider,
        isConnectedProvider,
        syncStateProvider,
        lastSyncProvider,
        SyncState,
        ThemeNotifier,
        AuthStateNotifier;
export 'src/riverpod/domain/analytics/analytics_providers.dart';
export 'src/riverpod/domain/auth/auth_domain_providers.dart';
export 'src/riverpod/domain/device/device_management_providers.dart';
export 'src/riverpod/domain/premium/subscription_providers.dart';
export 'src/riverpod/domain/premium/subscription_sync_providers.dart';
export 'src/riverpod/domain/sync/sync_providers.dart' hide OfflineData;
export 'src/riverpod/riverpod_utils.dart';
export 'src/services/cache/cache_service.dart';
export 'src/services/simple_subscription_sync_service.dart';
export 'src/services/subscription/advanced_subscription_services.dart'
    hide CacheStatistics, ConflictResolutionStrategy;
export 'src/services/supabase/supabase_config_service.dart';
export 'src/shared/config/environment_config.dart';
export 'src/shared/contracts/i_asset_loader.dart';
export 'src/shared/contracts/i_version_manager.dart';
export 'src/shared/enums/log_level.dart';
export 'src/shared/extensions/log_level_extensions.dart';
export 'src/shared/extensions/supabase_query_extensions.dart';
export 'src/shared/interfaces/i_navigation_extension.dart';
export 'src/shared/models/navigation_state.dart';
export 'src/shared/services/asset_loader_service.dart';
export 'src/shared/services/cache_management_service.dart' hide CacheConfig;
export 'src/shared/services/dio_service.dart';
export 'src/shared/services/enhanced_navigation_service.dart';
export 'src/shared/services/firebase_id_service.dart';
export 'src/shared/services/navigation_analytics_service.dart';
export 'src/shared/services/navigation_configuration_service.dart';
export 'src/shared/services/navigation_service.dart';
export 'src/shared/services/optimized_image_service.dart';
export 'src/shared/services/platform_capabilities_service.dart';
export 'src/shared/utils/app_error.dart';
export 'src/shared/utils/error_adapter.dart' hide ErrorHandlingMixin;
export 'src/shared/utils/failure.dart';
export 'src/shared/utils/result.dart';
export 'src/shared/utils/secure_logger.dart';
export 'src/shared/utils/subscription_failures.dart';
export 'src/shared/utils/supabase_failure.dart';
export 'src/sync/app_sync_config.dart';
export 'src/sync/config/sync_app_config.dart';
export 'src/sync/conflict_resolution/conflict_resolver_factory.dart'
    hide SyncFailure;
export 'src/sync/entity_sync_registration.dart'
    hide IConflictResolver, SyncPriority;
export 'src/sync/interfaces/i_sync_service.dart';
export 'src/sync/services/sync_logger.dart' hide LogLevel;
export 'src/sync/specialized/offline_sync_handler.dart';
export 'src/sync/specialized/sync_coordinator.dart';
export 'src/sync/specialized/sync_error_handler.dart';
export 'src/sync/specialized/sync_state_machine.dart'
    hide AppSyncEvent, SyncAction;
export 'src/sync/sync.dart'
    hide NetworkInfo, ConnectionQuality, MigrationResult, LogLevel;
export 'src/sync/unified_sync_manager.dart';
export 'utils/core_icons.dart';
export 'utils/random_selection_service.dart';
export 'widgets/core_carousel_widget.dart';
