import 'package:injectable/injectable.dart';

/// Service responsible for pragas-specific error messages
/// Centralizes error text for i18n readiness and consistency
/// Follows SRP by managing only error message logic
@lazySingleton
class PragasErrorMessageService {
  PragasErrorMessageService();

  /// Error messages registry
  /// Maps error types to user-friendly messages
  static const Map<String, String> _errorMessages = {
    'fetch_all': 'Erro ao buscar pragas',
    'fetch_by_id': 'Erro ao buscar praga por ID',
    'fetch_by_tipo': 'Erro ao buscar pragas por tipo',
    'fetch_by_name': 'Erro ao buscar pragas por nome',
    'fetch_by_familia': 'Erro ao buscar pragas por família',
    'fetch_by_cultura': 'Erro ao buscar pragas por cultura',
    'count_by_tipo': 'Erro ao contar pragas por tipo',
    'count_total': 'Erro ao contar total de pragas',
    'empty_id': 'ID não pode ser vazio',
    'load_initial': 'Erro ao carregar dados das pragas',
    'initialize': 'Erro ao inicializar dados das pragas',
    'unknown': 'Erro desconhecido ao processar pragas',
  };

  /// Get error message for fetching all pragas
  String getFetchAllError([String? details]) {
    return _formatError('fetch_all', details);
  }

  /// Get error message for fetching praga by ID
  String getFetchByIdError([String? details]) {
    return _formatError('fetch_by_id', details);
  }

  /// Get error message for fetching pragas by type
  String getFetchByTipoError([String? details]) {
    return _formatError('fetch_by_tipo', details);
  }

  /// Get error message for fetching pragas by name
  String getFetchByNameError([String? details]) {
    return _formatError('fetch_by_name', details);
  }

  /// Get error message for fetching pragas by family
  String getFetchByFamiliaError([String? details]) {
    return _formatError('fetch_by_familia', details);
  }

  /// Get error message for fetching pragas by culture
  String getFetchByCulturaError([String? details]) {
    return _formatError('fetch_by_cultura', details);
  }

  /// Get error message for counting pragas by type
  String getCountByTipoError([String? details]) {
    return _formatError('count_by_tipo', details);
  }

  /// Get error message for counting total pragas
  String getCountTotalError([String? details]) {
    return _formatError('count_total', details);
  }

  /// Get error message for empty ID validation
  String getEmptyIdError() {
    return _errorMessages['empty_id']!;
  }

  /// Get error message for initial data loading
  String getLoadInitialError([String? details]) {
    return _formatError('load_initial', details);
  }

  /// Get error message for initialization failures
  String getInitializeError([String? details]) {
    return _formatError('initialize', details);
  }

  /// Get error message for recent pragas loading
  String getFetchRecentError([String? details]) {
    return 'Erro ao buscar pragas recentes${details != null ? ': $details' : ''}';
  }

  /// Get error message for stats calculation
  String getFetchStatsError([String? details]) {
    return 'Erro ao buscar estatísticas das pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for type fetching
  String getFetchTiposError([String? details]) {
    return 'Erro ao buscar tipos de pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for families fetching
  String getFetchFamiliasError([String? details]) {
    return 'Erro ao buscar famílias de pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for marking as accessed
  String getMarkAccessedError([String? details]) {
    return 'Erro ao marcar praga como acessada${details != null ? ': $details' : ''}';
  }

  /// Get error message for suggested pragas
  String getFetchSuggestedError([String? details]) {
    return 'Erro ao buscar pragas sugeridas${details != null ? ': $details' : ''}';
  }

  /// Get error message for loading recent pragas
  String getLoadRecentError([String? details]) {
    return 'Erro ao carregar pragas recentes' +
        (details != null ? ': $details' : '');
  }

  /// Get generic error message with optional details
  /// Fallback for unexpected errors
  String getGenericError([String? details]) {
    return _formatError('unknown', details);
  }

  /// Format error message with optional details
  /// Appends details if provided
  String _formatError(String errorType, String? details) {
    final baseMessage = _errorMessages[errorType] ?? _errorMessages['unknown']!;

    if (details != null && details.isNotEmpty) {
      return '$baseMessage: $details';
    }

    return baseMessage;
  }

  /// Check if an error type is registered
  /// Useful for validation
  bool hasErrorType(String errorType) {
    return _errorMessages.containsKey(errorType);
  }

  /// Get all registered error types
  /// Useful for testing or documentation
  List<String> getRegisteredErrorTypes() {
    return _errorMessages.keys.toList();
  }
}
