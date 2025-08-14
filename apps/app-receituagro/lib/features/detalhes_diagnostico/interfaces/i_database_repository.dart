/// Abstract interface for database operations
/// Following Interface Segregation Principle (SOLID)
abstract class IDatabaseRepository {
  /// Get diagnostic details by ID
  Future<Map<String, dynamic>?> getDiagnosticById(String diagnosticId);
  
  /// Get multiple diagnostics with pagination
  Future<List<Map<String, dynamic>>> getDiagnostics({
    int? limit,
    int? offset,
    String? searchQuery,
    List<String>? filters,
  });
  
  /// Save diagnostic data
  Future<bool> saveDiagnostic(Map<String, dynamic> diagnosticData);
  
  /// Update diagnostic data
  Future<bool> updateDiagnostic(String diagnosticId, Map<String, dynamic> updates);
  
  /// Delete diagnostic
  Future<bool> deleteDiagnostic(String diagnosticId);
  
  /// Search diagnostics by text
  Future<List<Map<String, dynamic>>> searchDiagnostics(String query);
  
  /// Get diagnostics by category
  Future<List<Map<String, dynamic>>> getDiagnosticsByCategory(String category);
  
  /// Get recently accessed diagnostics
  Future<List<Map<String, dynamic>>> getRecentDiagnostics({int limit = 10});
  
  /// Update last accessed timestamp
  Future<void> updateLastAccessed(String diagnosticId);
  
  /// Get diagnostic statistics
  Future<Map<String, int>> getDiagnosticStats();
  
  /// Bulk insert diagnostics
  Future<bool> bulkInsertDiagnostics(List<Map<String, dynamic>> diagnostics);
  
  /// Check if diagnostic exists
  Future<bool> diagnosticExists(String diagnosticId);
  
  /// Get database connection status
  bool get isConnected;
  
  /// Initialize database connection
  Future<void> initialize();
  
  /// Close database connection
  Future<void> close();
}