import 'package:injectable/injectable.dart';

/// Service responsible for pragas_cultura-specific error messages
/// Centralizes error text for i18n readiness and consistency
/// Follows SRP by managing only error message logic
@lazySingleton
class PragasCulturaErrorMessageService {
  PragasCulturaErrorMessageService();

  /// Error messages registry
  static const Map<String, String> _errorMessages = {
    'load_culturas': 'Erro ao carregar culturas',
    'load_pragas': 'Erro ao carregar pragas',
    'load_defensivos': 'Erro ao carregar defensivos',
    'cache_pragas': 'Erro ao cachear pragas',
    'clear_cache': 'Erro ao limpar cache',
    'clear_all_cache': 'Erro ao limpar cache completo',
    'fetch_full_praga': 'Erro ao buscar praga completa',
    'get_cache_stats': 'Erro ao obter estatísticas de cache',
    'verify_cache': 'Erro ao verificar cache',
    'calculate_stats': 'Erro ao calcular estatísticas',
    'sort_pragas': 'Erro ao ordenar pragas',
    'filter_pragas': 'Erro ao filtrar pragas',
    'empty_cultura_id': 'ID da cultura não pode ser vazio',
    'empty_praga_id': 'ID da praga não pode ser vazio',
    'empty_pragas_list': 'Lista de pragas não pode estar vazia',
    'required_ids': 'pragaId e culturaId são obrigatórios',
    'validate_compatibility': 'Erro ao validar compatibilidade',
    'get_cache_stats_datasource': 'Erro ao obter estatísticas de cache',
    'unknown': 'Erro desconhecido',
  };

  /// Get error message for loading culturas
  String getLoadCulturasError([String? details]) {
    return _formatError('load_culturas', details);
  }

  /// Get error message for loading pragas
  String getLoadPragasError([String? details]) {
    return _formatError('load_pragas', details);
  }

  /// Get error message for loading defensivos
  String getLoadDefensivosError([String? details]) {
    return _formatError('load_defensivos', details);
  }

  /// Get error message for caching pragas
  String getCachePragasError([String? details]) {
    return _formatError('cache_pragas', details);
  }

  /// Get error message for clearing cache
  String getClearCacheError([String? details]) {
    return _formatError('clear_cache', details);
  }

  /// Get error message for clearing all cache
  String getClearAllCacheError([String? details]) {
    return _formatError('clear_all_cache', details);
  }

  /// Get error message for fetching full praga
  String getFetchFullPragaError([String? details]) {
    return _formatError('fetch_full_praga', details);
  }

  /// Get error message for getting cache stats
  String getGetCacheStatsError([String? details]) {
    return _formatError('get_cache_stats', details);
  }

  /// Get error message for verifying cache
  String getVerifyCacheError([String? details]) {
    return _formatError('verify_cache', details);
  }

  /// Get error message for calculating statistics
  String getCalculateStatsError([String? details]) {
    return _formatError('calculate_stats', details);
  }

  /// Get error message for sorting pragas
  String getSortPragasError([String? details]) {
    return _formatError('sort_pragas', details);
  }

  /// Get error message for filtering pragas
  String getFilterPragasError([String? details]) {
    return _formatError('filter_pragas', details);
  }

  /// Get validation error for empty cultura ID
  String getEmptyCulturaIdError() {
    return _errorMessages['empty_cultura_id']!;
  }

  /// Get validation error for empty praga ID
  String getEmptyPragaIdError() {
    return _errorMessages['empty_praga_id']!;
  }

  /// Get validation error for empty pragas list
  String getEmptyPragasListError() {
    return _errorMessages['empty_pragas_list']!;
  }

  /// Get validation error for required IDs
  String getRequiredIdsError() {
    return _errorMessages['required_ids']!;
  }

  /// Get error message for compatibility validation
  String getValidateCompatibilityError([String? details]) {
    return _formatError('validate_compatibility', details);
  }

  /// Get error message for datasource cache stats
  String getCacheStatsDatasourceError([String? details]) {
    return _formatError('get_cache_stats_datasource', details);
  }

  /// Get generic error message with optional details
  String getGenericError([String? details]) {
    return _formatError('unknown', details);
  }

  /// Format error message with optional details
  String _formatError(String errorType, String? details) {
    final baseMessage = _errorMessages[errorType] ?? _errorMessages['unknown']!;

    if (details != null && details.isNotEmpty) {
      return '$baseMessage: $details';
    }

    return baseMessage;
  }

  /// Check if an error type is registered
  bool hasErrorType(String errorType) {
    return _errorMessages.containsKey(errorType);
  }

  /// Get all registered error types
  List<String> getRegisteredErrorTypes() {
    return _errorMessages.keys.toList();
  }
}
