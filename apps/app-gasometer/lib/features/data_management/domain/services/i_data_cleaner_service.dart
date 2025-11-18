/// Interface comum para DataCleanerService
/// 
/// Permite ter implementações diferentes para mobile/desktop (Drift) e web (Firestore)
abstract class IDataCleanerService {
  Future<Map<String, dynamic>> clearAllData();
  Future<Map<String, dynamic>> clearAppSharedPreferences();
  Future<bool> hasDataToClear();
}
