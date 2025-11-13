/// Drift Storage - Core Package
/// 
/// Equivalente Drift da infraestrutura Hive Storage
/// Fornece abstrações e serviços para storage usando Drift

// Interfaces
export 'interfaces/i_drift_manager.dart';
export 'interfaces/i_drift_repository.dart';
export 'interfaces/i_drift_storage_service.dart';

// Services
export 'services/drift_manager.dart';
export 'services/core_drift_storage_service.dart';
export 'services/drift_storage_service.dart';

// Repositories
export 'repositories/drift_repository_base.dart';

// Exceptions
export 'exceptions/drift_exceptions.dart';

// Utils
export 'utils/drift_result_adapter.dart';
