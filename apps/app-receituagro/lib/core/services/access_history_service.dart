/// Stub for AccessHistoryService - removed service
/// This stub provides the same interface for compatibility
/// TODO: Remove references to this service or implement proper access tracking
class AccessHistoryService {
  // Instance methods (non-static versions)
  void recordAccess(String entityType, String entityId) {
    // Stub implementation - no-op
    // In a real implementation, this would track user access patterns
  }
  
  void recordView(String entityType, String entityId) {
    recordAccess(entityType, entityId);
  }
  
  void recordInteraction(String entityType, String entityId, String action) {
    recordAccess(entityType, entityId);
  }
  
  Future<void> recordDefensivoAccess({
    String? id,
    String? name,
    String? fabricante,
    String? ingrediente,
    String? classe,
  }) async {
    // Stub implementation - no-op
    await Future<void>.delayed(const Duration(milliseconds: 10));
    recordAccess('defensivo', id ?? 'unknown');
  }
  
  Future<List<dynamic>> getDefensivosHistory({int limit = 10}) async {
    // Stub implementation - return empty list
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return [];
  }
  
  Future<void> recordPragaAccess({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? tipoPraga,
  }) async {
    // Stub implementation - no-op  
    await Future<void>.delayed(const Duration(milliseconds: 10));
    recordAccess('praga', id ?? 'unknown');
  }
  
  Future<List<dynamic>> getPragasHistory({int limit = 10}) async {
    // Stub implementation - return empty list
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return [];
  }

  // Static methods for backward compatibility (where no conflicts)
  static List<String> getRecentAccess(String entityType, {int limit = 10}) {
    // Stub implementation - return empty list
    return [];
  }
  
  static Map<String, int> getAccessStats(String entityType) {
    // Stub implementation - return empty stats
    return {};
  }
}