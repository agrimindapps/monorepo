/// Interface for praga error message service
/// Centralizes error text for i18n readiness and consistency
abstract class IPragasErrorMessageService {
  /// Get error message for fetching all pragas
  String getFetchAllError([String? details]);

  /// Get error message for fetching praga by ID
  String getFetchByIdError([String? details]);

  /// Get error message for fetching pragas by type
  String getFetchByTipoError([String? details]);

  /// Get error message for fetching pragas by name
  String getFetchByNameError([String? details]);

  /// Get error message for fetching pragas by family
  String getFetchByFamiliaError([String? details]);

  /// Get error message for fetching pragas by culture
  String getFetchByCulturaError([String? details]);

  /// Get error message for counting pragas by type
  String getCountByTipoError([String? details]);

  /// Get error message for counting total pragas
  String getCountTotalError([String? details]);

  /// Get error message for empty ID validation
  String getEmptyIdError();

  /// Get error message for initial data loading
  String getLoadInitialError([String? details]);

  /// Get error message for initialization failures
  String getInitializeError([String? details]);

  /// Get error message for recent pragas loading
  String getFetchRecentError([String? details]);

  /// Get error message for stats calculation
  String getFetchStatsError([String? details]);

  /// Get error message for type fetching
  String getFetchTiposError([String? details]);

  /// Get error message for families fetching
  String getFetchFamiliasError([String? details]);

  /// Get error message for marking as accessed
  String getMarkAccessedError([String? details]);

  /// Get error message for suggested pragas
  String getFetchSuggestedError([String? details]);

  /// Get error message for loading recent pragas
  String getLoadRecentError([String? details]);

  /// Get generic error message with optional details
  String getGenericError([String? details]);

  /// Check if an error type is registered
  bool hasErrorType(String errorType);

  /// Get all registered error types
  List<String> getRegisteredErrorTypes();
}
