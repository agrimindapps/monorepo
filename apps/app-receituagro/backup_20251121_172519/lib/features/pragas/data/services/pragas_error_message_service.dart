import 'package:injectable/injectable.dart';

import '../../domain/services/i_pragas_error_message_service.dart';

/// Service responsible for pragas-specific error messages
/// Centralizes error text for i18n readiness and consistency
/// Follows SRP by managing only error message logic
@LazySingleton(as: IPragasErrorMessageService)
class PragasErrorMessageService implements IPragasErrorMessageService {
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
  @override
  String getFetchAllError([String? details]) {
    return _formatError('fetch_all', details);
  }

  /// Get error message for fetching praga by ID
  @override
  String getFetchByIdError([String? details]) {
    return _formatError('fetch_by_id', details);
  }

  /// Get error message for fetching pragas by type
  @override
  String getFetchByTipoError([String? details]) {
    return _formatError('fetch_by_tipo', details);
  }

  /// Get error message for fetching pragas by name
  @override
  String getFetchByNameError([String? details]) {
    return _formatError('fetch_by_name', details);
  }

  /// Get error message for fetching pragas by family
  @override
  String getFetchByFamiliaError([String? details]) {
    return _formatError('fetch_by_familia', details);
  }

  /// Get error message for fetching pragas by culture
  @override
  String getFetchByCulturaError([String? details]) {
    return _formatError('fetch_by_cultura', details);
  }

  /// Get error message for counting pragas by type
  @override
  String getCountByTipoError([String? details]) {
    return _formatError('count_by_tipo', details);
  }

  /// Get error message for counting total pragas
  @override
  String getCountTotalError([String? details]) {
    return _formatError('count_total', details);
  }

  /// Get error message for empty ID validation
  @override
  String getEmptyIdError() {
    return _errorMessages['empty_id']!;
  }

  /// Get error message for initial data loading
  @override
  String getLoadInitialError([String? details]) {
    return _formatError('load_initial', details);
  }

  /// Get error message for initialization failures
  @override
  String getInitializeError([String? details]) {
    return _formatError('initialize', details);
  }

  /// Get error message for recent pragas loading
  @override
  String getFetchRecentError([String? details]) {
    return 'Erro ao buscar pragas recentes${details != null ? ': $details' : ''}';
  }

  /// Get error message for stats calculation
  @override
  String getFetchStatsError([String? details]) {
    return 'Erro ao buscar estatísticas das pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for type fetching
  @override
  String getFetchTiposError([String? details]) {
    return 'Erro ao buscar tipos de pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for families fetching
  @override
  String getFetchFamiliasError([String? details]) {
    return 'Erro ao buscar famílias de pragas${details != null ? ': $details' : ''}';
  }

  /// Get error message for marking as accessed
  @override
  String getMarkAccessedError([String? details]) {
    return 'Erro ao marcar praga como acessada${details != null ? ': $details' : ''}';
  }

  /// Get error message for suggested pragas
  @override
  String getFetchSuggestedError([String? details]) {
    return 'Erro ao buscar pragas sugeridas${details != null ? ': $details' : ''}';
  }

  /// Get error message for loading recent pragas
  @override
  String getLoadRecentError([String? details]) {
    return 'Erro ao carregar pragas recentes${details != null ? ': $details' : ''}';
  }

  /// Get generic error message with optional details
  /// Fallback for unexpected errors
  @override
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
  @override
  bool hasErrorType(String errorType) {
    return _errorMessages.containsKey(errorType);
  }

  /// Get all registered error types
  /// Useful for testing or documentation
  @override
  List<String> getRegisteredErrorTypes() {
    return _errorMessages.keys.toList();
  }
}
