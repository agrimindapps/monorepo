/// Interface for version management services
abstract class IVersionManager {
  /// Get current application version
  String getCurrentVersion();
  
  /// Check if data needs to be updated based on version comparison
  bool needsUpdate(String storedVersion, String currentVersion);
  
  /// Mark data as updated for specific version and box name
  Future<void> markAsUpdated(String version, String boxName);
}