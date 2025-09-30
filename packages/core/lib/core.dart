library;

// ========== DOMAIN LAYER ==========
// Contracts
export 'src/domain/contracts/i_app_data_cleaner.dart';

// Entities
export 'src/domain/entities/auth_result.dart';
export 'src/domain/entities/base_entity.dart';
export 'src/domain/entities/base_sync_entity.dart';
export 'src/domain/entities/box_sync_config.dart';
export 'src/domain/entities/custom_box_type.dart';
export 'src/domain/entities/database_record.dart';
export 'src/domain/entities/device_entity.dart';
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

// Data Migration Entities
export 'src/domain/entities/data_migration/account_data.dart';
export 'src/domain/entities/data_migration/anonymous_data.dart';
export 'src/domain/entities/data_migration/data_conflict_result.dart';
export 'src/domain/entities/data_migration/data_resolution_choice.dart';

// Repository Interfaces
export 'src/domain/repositories/i_analytics_repository.dart';
export 'src/domain/repositories/i_app_rating_repository.dart';
export 'src/domain/repositories/i_auth_repository.dart';
export 'src/domain/repositories/i_crashlytics_repository.dart';
export 'src/domain/repositories/i_device_repository.dart' hide DeviceValidationResult;
export 'src/domain/repositories/i_encrypted_storage_repository.dart';
export 'src/domain/repositories/i_enhanced_notification_repository.dart';
export 'src/domain/repositories/i_file_repository.dart';
export 'src/domain/repositories/i_local_storage_repository.dart' hide OfflineData;
export 'src/domain/repositories/i_notification_repository.dart';
export 'src/domain/repositories/i_performance_repository.dart';
export 'src/domain/repositories/i_security_repository.dart';
export 'src/domain/repositories/i_storage_repository.dart';
export 'src/domain/repositories/i_subscription_repository.dart';
export 'src/domain/repositories/i_sync_repository.dart';

// Services
export 'src/domain/services/i_box_registry_service.dart';

// Use Cases
export 'src/domain/usecases/base_usecase.dart';
export 'src/domain/usecases/get_user_devices_usecase.dart';
export 'src/domain/usecases/revoke_device_usecase.dart';
export 'src/domain/usecases/validate_device_usecase.dart';

// Auth Use Cases
export 'src/domain/usecases/auth/delete_account_usecase.dart';
export 'src/domain/usecases/auth/login_usecase.dart';
export 'src/domain/usecases/auth/logout_usecase.dart';

// ========== INFRASTRUCTURE LAYER ==========
// Helpers
export 'src/infrastructure/helpers/notification_helper.dart';
export 'src/infrastructure/helpers/notification_template_engine.dart';
export 'src/infrastructure/helpers/notification_analytics_helper.dart';
export 'src/infrastructure/helpers/notification_migration_helper.dart';

// Models
export 'src/infrastructure/models/box_configuration.dart';

// Services
export 'src/infrastructure/services/account_deletion_service.dart';
export 'src/infrastructure/services/anonymous_data_cleaner.dart';
export 'src/infrastructure/services/app_rating_service.dart';
export 'src/infrastructure/services/box_registry_service.dart';
export 'src/infrastructure/services/connectivity_service.dart';
export 'src/infrastructure/services/data_migration_service.dart';
export 'src/infrastructure/services/database_inspector_service.dart';
export 'src/infrastructure/services/device_management_service.dart';
export 'src/infrastructure/services/enhanced_analytics_service.dart';
export 'src/infrastructure/services/security_service.dart';
export 'src/infrastructure/services/enhanced_connectivity_service.dart';
export 'src/infrastructure/services/enhanced_image_service.dart';
export 'src/infrastructure/services/enhanced_logging_service.dart';
export 'src/infrastructure/services/enhanced_security_service.dart';
export 'src/infrastructure/services/enhanced_storage_service.dart';
export 'src/infrastructure/services/file_manager_service.dart';
export 'src/infrastructure/services/firebase_analytics_service.dart';
export 'src/infrastructure/services/firebase_auth_service.dart';
export 'src/infrastructure/services/enhanced_firebase_auth_service.dart';
export 'src/infrastructure/services/enhanced_secure_storage_service.dart';
export 'src/infrastructure/services/enhanced_encrypted_storage_service.dart';
export 'src/infrastructure/services/firebase_crashlytics_service.dart';
export 'src/infrastructure/services/firebase_device_service.dart';
export 'src/infrastructure/services/firebase_storage_service.dart';
export 'src/infrastructure/services/hive_storage_service.dart';
export 'src/infrastructure/services/http_client_service.dart' hide CacheItem;
export 'src/infrastructure/services/image_service.dart';
export 'src/infrastructure/services/local_notification_service.dart';
export 'src/infrastructure/services/enhanced_notification_service.dart';
export 'src/infrastructure/services/log_repository_service.dart';
export 'src/infrastructure/services/mock_analytics_service.dart';
export 'src/infrastructure/services/monorepo_auth_cache.dart';
export 'src/infrastructure/services/performance_service.dart';
export 'src/infrastructure/services/profile_image_service.dart';
export 'src/infrastructure/services/revenue_cat_service.dart';
export 'src/infrastructure/services/selective_sync_service.dart';
export 'src/infrastructure/services/sync_firebase_service.dart';
export 'src/infrastructure/services/validation_service.dart';
export 'src/infrastructure/services/web_notification_service.dart';

// Storage
export 'src/infrastructure/storage/hive/hive_storage.dart';

// ========== PRESENTATION LAYER ==========
// Theme System
export 'src/presentation/theme/base/base_colors.dart';
export 'src/presentation/theme/base/base_theme.dart';
export 'src/presentation/theme/base/base_typography.dart';
// export 'src/presentation/widgets/error_widget.dart';
// export 'src/presentation/widgets/image_widgets.dart';
// export 'src/presentation/widgets/loading_widget.dart';
// export 'src/presentation/widgets/profile_avatar.dart';
// export 'src/presentation/widgets/profile_image_picker.dart';

// Data Migration Widgets (commented out - files not found)
// export 'src/presentation/widgets/data_migration/data_conflict_dialog.dart';
// export 'src/presentation/widgets/data_migration/migration_progress_dialog.dart';

// Data Inspector (commented out - files not found)
// export 'src/presentation/data_inspector.dart';

// ========== SHARED LAYER ==========
// Config
export 'src/shared/config/environment_config.dart';

// Contracts
export 'src/shared/contracts/i_asset_loader.dart';
export 'src/shared/contracts/i_version_manager.dart';

// Dependency Injection
export 'src/shared/di/injection_container.dart';

// Enums
export 'src/shared/enums/log_level.dart';

// Extensions
export 'src/shared/extensions/log_level_extensions.dart';

// Services
export 'src/shared/services/asset_loader_service.dart';
export 'src/shared/services/cache_management_service.dart' hide CacheConfig;
export 'src/shared/services/navigation_service.dart';
export 'src/shared/services/enhanced_navigation_service.dart';
export 'src/shared/services/navigation_configuration_service.dart';
export 'src/shared/services/navigation_analytics_service.dart';

// Navigation models and interfaces
export 'src/shared/models/navigation_state.dart';
export 'src/shared/interfaces/i_navigation_extension.dart';
export 'src/shared/services/optimized_image_service.dart';
export 'src/shared/services/preferences_service.dart';
export 'src/shared/services/version_manager_service.dart';

// Utils
export 'src/shared/utils/app_error.dart';
export 'src/shared/utils/error_adapter.dart' hide ErrorHandlingMixin;
export 'src/shared/utils/failure.dart';
export 'src/shared/utils/subscription_failures.dart';
export 'src/shared/utils/result.dart';

// ========== SYNC SYSTEM ==========
export 'src/sync/app_sync_config.dart';
export 'src/sync/conflict_resolution/conflict_resolver_factory.dart' hide SyncFailure;
export 'src/sync/entity_sync_registration.dart' hide IConflictResolver;
export 'src/sync/unified_sync_manager.dart';

// ========== FEATURES ==========
export 'src/features/subscription/subscription_page.dart';

// ========== SERVICES ==========
export 'src/services/simple_subscription_sync_service.dart';

// ========== LICENSE SYSTEM ==========
// Models
export 'models/license_model.dart';

// Repositories
export 'repositories/license_repository.dart';
export 'repositories/license_local_storage.dart';

// ========== EXTERNAL PACKAGES ==========
// Riverpod State Management (Provider REMOVIDO - migração para Riverpod completa)
export 'package:riverpod/riverpod.dart' hide Locator, AsyncValueX, StreamProvider;
export 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation
export 'package:go_router/go_router.dart';

// Image Cache Management
export 'package:cached_network_image/cached_network_image.dart';

// Shimmer Loading Effects
export 'package:shimmer/shimmer.dart';

// Social Authentication
export 'package:google_sign_in/google_sign_in.dart';
export 'package:sign_in_with_apple/sign_in_with_apple.dart';
export 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// Services
export 'services/license_service.dart';
export 'services/image_compression_service.dart';
export 'services/shimmer_service.dart';

// ========== RIVERPOD UTILITIES ==========
export 'src/riverpod/common_providers.dart' hide currentUserProvider, isConnectedProvider, syncStateProvider, lastSyncProvider, SyncState;
export 'src/riverpod/riverpod_utils.dart';
export 'src/riverpod/common_notifiers.dart';

// ========== DOMAIN-SPECIFIC PROVIDERS ==========
// Auth Domain Providers
export 'src/riverpod/domain/auth/auth_domain_providers.dart';

// Premium/Subscription Domain Providers  
export 'src/riverpod/domain/premium/subscription_providers.dart';

// Device Management Domain Providers
export 'src/riverpod/domain/device/device_management_providers.dart';

// Sync/Offline Domain Providers
export 'src/riverpod/domain/sync/sync_providers.dart';

// Analytics Domain Providers
export 'src/riverpod/domain/analytics/analytics_providers.dart';

// ========== ADDITIONAL EXTERNAL PACKAGES ==========
// Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_storage/firebase_storage.dart' hide Task;
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:cloud_functions/cloud_functions.dart' hide Result;

// Storage and Preferences
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:shared_preferences/shared_preferences.dart';

// Dependency Injection
export 'package:get_it/get_it.dart';
export 'package:injectable/injectable.dart' hide Environment, order;

// Functional Programming
export 'package:dartz/dartz.dart' hide Order, State, id;
export 'package:equatable/equatable.dart';

// Connectivity and Network
export 'package:connectivity_plus/connectivity_plus.dart';

// Notifications and Timing
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:timezone/timezone.dart';

// URL Launcher
export 'package:url_launcher/url_launcher.dart';

// Package Info
export 'package:package_info_plus/package_info_plus.dart';

// Internationalization
export 'package:intl/intl.dart';

// JSON Serialization
export 'package:json_annotation/json_annotation.dart';

// Icons and Sharing
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:share_plus/share_plus.dart';

// Subscriptions
export 'package:purchases_flutter/purchases_flutter.dart' hide LogLevel, Store;