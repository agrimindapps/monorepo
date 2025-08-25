/// Exports para infraestrutura Hive do Core
/// 
/// Este arquivo centraliza todas as exportações relacionadas ao Hive,
/// facilitando o uso por apps que consomem o packages/core
library;

// Exceções
export 'exceptions/storage_exceptions.dart';
// Interfaces
export 'interfaces/i_hive_manager.dart';
export 'interfaces/i_hive_repository.dart';
export 'interfaces/i_storage_service.dart';
export 'repositories/base_hive_repository.dart';
export 'services/core_hive_storage_service.dart';
// Implementações
export 'services/hive_manager.dart';