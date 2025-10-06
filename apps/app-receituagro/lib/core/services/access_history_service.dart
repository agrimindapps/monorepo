/// Stub for AccessHistoryService - removed service
/// This stub provides the same interface for compatibility
/// TODO: Remove references to this service or implement proper access tracking
class AccessHistoryService {
  void recordAccess(String entityType, String entityId) {
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
    await Future<void>.delayed(const Duration(milliseconds: 10));
    recordAccess('defensivo', id ?? 'unknown');
  }
  
  Future<List<dynamic>> getDefensivosHistory({int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return [];
  }
  
  Future<void> recordPragaAccess({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? tipoPraga,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    recordAccess('praga', id ?? 'unknown');
  }
  
  Future<List<dynamic>> getPragasHistory({int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return [];
  }
  static List<String> getRecentAccess(String entityType, {int limit = 10}) {
    return [];
  }
  
  static Map<String, int> getAccessStats(String entityType) {
    return {};
  }
}