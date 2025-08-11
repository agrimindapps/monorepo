library core;

// ========== DOMAIN LAYER ==========
// Entities
export 'src/domain/entities/base_entity.dart';
export 'src/domain/entities/user_entity.dart';
export 'src/domain/entities/subscription_entity.dart';
export 'src/domain/entities/auth_result.dart';
export 'src/domain/entities/module_auth_config.dart';
export 'src/domain/entities/base_sync_entity.dart';
export 'src/domain/entities/log_entry.dart';
export 'src/domain/entities/database_record.dart';
export 'src/domain/entities/custom_box_type.dart';
export 'src/domain/entities/shared_preferences_record.dart';

// Repository Interfaces
export 'src/domain/repositories/i_auth_repository.dart';
export 'src/domain/repositories/i_analytics_repository.dart';
export 'src/domain/repositories/i_subscription_repository.dart';
export 'src/domain/repositories/i_storage_repository.dart';
export 'src/domain/repositories/i_crashlytics_repository.dart';
export 'src/domain/repositories/i_local_storage_repository.dart';
export 'src/domain/repositories/i_sync_repository.dart';

// Use Cases
export 'src/domain/usecases/base_usecase.dart';
export 'src/domain/usecases/auth/login_usecase.dart';
export 'src/domain/usecases/auth/logout_usecase.dart';

// ========== INFRASTRUCTURE LAYER ==========
// Services
export 'src/infrastructure/services/firebase_auth_service.dart';
export 'src/infrastructure/services/mock_analytics_service.dart';
export 'src/infrastructure/services/firebase_analytics_service.dart';
export 'src/infrastructure/services/firebase_crashlytics_service.dart';
export 'src/infrastructure/services/firebase_storage_service.dart';
export 'src/infrastructure/services/hive_storage_service.dart';
export 'src/infrastructure/services/monorepo_auth_cache.dart';
export 'src/infrastructure/services/revenue_cat_service.dart';
export 'src/infrastructure/services/connectivity_service.dart';
export 'src/infrastructure/services/sync_firebase_service.dart';
export 'src/infrastructure/services/log_repository_service.dart';
export 'src/infrastructure/services/database_inspector_service.dart';

// ========== PRESENTATION LAYER ==========
// Widgets
export 'src/presentation/widgets/loading_widget.dart';
export 'src/presentation/widgets/error_widget.dart';

// ========== SHARED LAYER ==========
// Config
export 'src/shared/config/environment_config.dart';

// Dependency Injection
export 'src/shared/di/injection_container.dart';

// Utils
export 'src/shared/utils/failure.dart';

// Enums
export 'src/shared/enums/log_level.dart';

// Extensions
export 'src/shared/extensions/log_level_extensions.dart';