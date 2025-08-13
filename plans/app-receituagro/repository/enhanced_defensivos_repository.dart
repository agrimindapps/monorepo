// Enhanced defensivos repository with proper error handling using Result pattern
// Replaces try-catch with print() pattern with proper error propagation

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/logging_service.dart';
import '../core/error/error_recovery_service.dart';
import '../core/error/result.dart';
import 'database_repository.dart';

/// Enhanced defensivos repository with Result pattern
class EnhancedDefensivosRepository extends GetxService {
  final DatabaseRepository _databaseRepository;
  final ErrorRecoveryService _errorRecovery;

  EnhancedDefensivosRepository({
    DatabaseRepository? databaseRepository,
    ErrorRecoveryService? errorRecovery,
  })  : _databaseRepository = databaseRepository ?? Get.find<DatabaseRepository>(),
        _errorRecovery = errorRecovery ?? ErrorRecoveryService.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeErrorRecovery();
  }

  void _initializeErrorRecovery() {
    // Configure error recovery for this repository
    _errorRecovery.registerRetryConfig('getDefensivos', const RetryConfig(
      maxAttempts: 2,
      initialDelay: Duration(milliseconds: 200),
    ));

    _errorRecovery.setFallback<List<Map<String, dynamic>>>('getDefensivos', []);
    _errorRecovery.setFallback<int>('getDefensivosCount', 0);
  }

  /// Get all defensivos with proper error handling
  Future<Result<List<Map<String, dynamic>>>> getDefensivos() async {
    return _errorRecovery.executeWithRecovery(
      'getDefensivos',
      () => _getDefensivosInternal(),
      strategy: RecoveryStrategy.hybrid,
    );
  }

  Future<Result<List<Map<String, dynamic>>>> _getDefensivosInternal() async {
    return Result.tryAsync(() async {
      LoggingService.debug('Fetching defensivos from database', tag: 'DefensivosRepository');
      
      if (!_databaseRepository.isLoaded.value) {
        throw RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getDefensivos',
          message: 'Database not loaded',
          code: 'DATABASE_NOT_LOADED',
        );
      }

      final fitossanitarios = _databaseRepository.gFitossanitarios;
      if (fitossanitarios.isEmpty) {
        LoggingService.warning(
          'No fitossanitarios found in database', 
          tag: 'DefensivosRepository'
        );
        return <Map<String, dynamic>>[];
      }

      final defensivos = fitossanitarios
          .map((item) => item.toJson())
          .toList();

      LoggingService.debug(
        'Successfully fetched ${defensivos.length} defensivos',
        tag: 'DefensivosRepository',
      );

      return defensivos;
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getDefensivos',
      message: 'Failed to fetch defensivos: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Get defensivos count with error handling
  Future<Result<int>> getDefensivosCount() async {
    return _errorRecovery.executeWithFallback(
      'getDefensivosCount',
      () => _getDefensivosCountInternal(),
      0, // fallback to 0
    );
  }

  Future<Result<int>> _getDefensivosCountInternal() async {
    return Result.tryAsync(() async {
      LoggingService.debug('Getting defensivos count', tag: 'DefensivosRepository');
      
      final defensivosResult = await getDefensivos();
      
      return defensivosResult.fold(
        (defensivos) {
          final count = defensivos.length;
          LoggingService.debug('Defensivos count: $count', tag: 'DefensivosRepository');
          return count;
        },
        (error) => throw error,
      );
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getDefensivosCount',
      message: 'Failed to get defensivos count: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Get defensivo by ID with validation
  Future<Result<Map<String, dynamic>?>> getDefensivoById(String id) async {
    return _errorRecovery.executeWithRetry(
      'getDefensivoById',
      () => _getDefensivoByIdInternal(id),
      maxAttempts: 2,
    );
  }

  Future<Result<Map<String, dynamic>?>> _getDefensivoByIdInternal(String id) async {
    return Result.tryAsync(() async {
      // Input validation
      if (id.trim().isEmpty) {
        throw ValidationError(
          field: 'id',
          value: id,
          message: 'ID cannot be empty',
          code: 'INVALID_ID',
        );
      }

      LoggingService.debug('Fetching defensivo by ID: $id', tag: 'DefensivosRepository');

      final defensivosResult = await getDefensivos();
      
      return defensivosResult.fold(
        (defensivos) {
          final defensivo = defensivos
              .where((item) => item['idReg']?.toString() == id)
              .firstOrNull;

          if (defensivo == null) {
            LoggingService.warning(
              'Defensivo not found with ID: $id',
              tag: 'DefensivosRepository',
            );
          } else {
            LoggingService.debug(
              'Found defensivo with ID: $id',
              tag: 'DefensivosRepository',
            );
          }

          return defensivo;
        },
        (error) => throw error,
      );
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getDefensivoById',
      message: 'Failed to get defensivo by ID $id: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Get manufacturers with error handling
  Future<Result<List<Map<String, dynamic>>>> getFabricantes() async {
    return _errorRecovery.executeWithRecovery(
      'getFabricantes',
      () => _getFabricantesInternal(),
      strategy: RecoveryStrategy.fallback,
      fallbackValue: <Map<String, dynamic>>[],
    );
  }

  Future<Result<List<Map<String, dynamic>>>> _getFabricantesInternal() async {
    return Result.tryAsync(() async {
      LoggingService.debug('Fetching fabricantes', tag: 'DefensivosRepository');

      final defensivosResult = await getDefensivos();
      
      return defensivosResult.fold(
        (defensivos) {
          final fabricantesSet = <String>{};
          final fabricantesList = <Map<String, dynamic>>[];

          for (final defensivo in defensivos) {
            final fabricante = defensivo['fabricante']?.toString();
            if (fabricante != null && 
                fabricante.isNotEmpty && 
                !fabricantesSet.contains(fabricante)) {
              fabricantesSet.add(fabricante);
              
              // Count products for this manufacturer
              final count = defensivos
                  .where((d) => d['fabricante']?.toString() == fabricante)
                  .length;

              fabricantesList.add({
                'name': fabricante,
                'count': count,
                'id': fabricante.toLowerCase().replaceAll(' ', '_'),
              });
            }
          }

          // Sort by name
          fabricantesList.sort((a, b) => 
            (a['name'] as String).compareTo(b['name'] as String));

          LoggingService.debug(
            'Found ${fabricantesList.length} unique fabricantes',
            tag: 'DefensivosRepository',
          );

          return fabricantesList;
        },
        (error) => throw error,
      );
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getFabricantes',
      message: 'Failed to get fabricantes: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Get recently accessed defensivos with error recovery
  Future<Result<List<Map<String, dynamic>>>> getDefensivosAcessados() async {
    return _errorRecovery.executeWithRecovery(
      'getDefensivosAcessados',
      () => _getDefensivosAcessadosInternal(),
      strategy: RecoveryStrategy.fallback,
      fallbackValue: <Map<String, dynamic>>[],
    );
  }

  Future<Result<List<Map<String, dynamic>>>> _getDefensivosAcessadosInternal() async {
    return Result.tryAsync(() async {
      LoggingService.debug('Fetching recently accessed defensivos', tag: 'DefensivosRepository');

      // This would typically involve getting data from cache/storage
      // For now, returning empty list as example
      return <Map<String, dynamic>>[];
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getDefensivosAcessados',
      message: 'Failed to get accessed defensivos: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Search defensivos with filters and error handling
  Future<Result<List<Map<String, dynamic>>>> searchDefensivos({
    String? query,
    String? fabricante,
    String? classe,
  }) async {
    return _errorRecovery.executeWithRetry(
      'searchDefensivos',
      () => _searchDefensivosInternal(
        query: query,
        fabricante: fabricante,
        classe: classe,
      ),
    );
  }

  Future<Result<List<Map<String, dynamic>>>> _searchDefensivosInternal({
    String? query,
    String? fabricante,
    String? classe,
  }) async {
    return Result.tryAsync(() async {
      LoggingService.debug(
        'Searching defensivos with filters: query=$query, fabricante=$fabricante, classe=$classe',
        tag: 'DefensivosRepository',
      );

      final defensivosResult = await getDefensivos();
      
      return defensivosResult.fold(
        (defensivos) {
          var filtered = defensivos;

          // Apply query filter
          if (query != null && query.trim().isNotEmpty) {
            final queryLower = query.toLowerCase();
            filtered = filtered.where((item) {
              final nomeComercial = item['nomeComercial']?.toString().toLowerCase() ?? '';
              final ingredienteAtivo = item['ingredienteAtivo']?.toString().toLowerCase() ?? '';
              return nomeComercial.contains(queryLower) || 
                     ingredienteAtivo.contains(queryLower);
            }).toList();
          }

          // Apply fabricante filter
          if (fabricante != null && fabricante.trim().isNotEmpty) {
            filtered = filtered.where((item) => 
              item['fabricante']?.toString() == fabricante).toList();
          }

          // Apply classe filter
          if (classe != null && classe.trim().isNotEmpty) {
            filtered = filtered.where((item) => 
              item['classeAgronomica']?.toString() == classe).toList();
          }

          LoggingService.debug(
            'Search returned ${filtered.length} results',
            tag: 'DefensivosRepository',
          );

          return filtered;
        },
        (error) => throw error,
      );
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'searchDefensivos',
      message: 'Failed to search defensivos: ${error.toString()}',
      originalError: error,
    ));
  }

  /// Get repository health status
  Future<Result<Map<String, dynamic>>> getHealthStatus() async {
    return Result.tryAsync(() async {
      final countResult = await getDefensivosCount();
      final fabricantesResult = await getFabricantes();

      return {
        'isHealthy': countResult.isSuccess && fabricantesResult.isSuccess,
        'defensivosCount': countResult.getOrElse(0),
        'fabricantesCount': fabricantesResult.getOrElse([]).length,
        'lastCheck': DateTime.now().toIso8601String(),
        'errorRecoveryStats': _errorRecovery.getStats(),
      };
    }, (error) => RepositoryError(
      repositoryName: 'DefensivosRepository',
      operation: 'getHealthStatus',
      message: 'Failed to get health status: ${error.toString()}',
      originalError: error,
    ));
  }

  @override
  void onClose() {
    LoggingService.debug('DefensivosRepository disposed', tag: 'DefensivosRepository');
    super.onClose();
  }
}