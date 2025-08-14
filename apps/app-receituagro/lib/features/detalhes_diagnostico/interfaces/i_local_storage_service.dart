/// Abstract interface for local storage operations
/// Following Interface Segregation Principle (SOLID)
abstract class ILocalStorageService {
  /// Store string value
  Future<bool> setString(String key, String value);
  
  /// Get string value
  Future<String?> getString(String key);
  
  /// Store integer value
  Future<bool> setInt(String key, int value);
  
  /// Get integer value
  Future<int?> getInt(String key);
  
  /// Store boolean value
  Future<bool> setBool(String key, bool value);
  
  /// Get boolean value
  Future<bool?> getBool(String key);
  
  /// Store double value
  Future<bool> setDouble(String key, double value);
  
  /// Get double value
  Future<double?> getDouble(String key);
  
  /// Store list of strings
  Future<bool> setStringList(String key, List<String> value);
  
  /// Get list of strings
  Future<List<String>?> getStringList(String key);
  
  /// Store JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value);
  
  /// Get JSON object
  Future<Map<String, dynamic>?> getJson(String key);
  
  /// Check if key exists
  Future<bool> containsKey(String key);
  
  /// Remove value by key
  Future<bool> remove(String key);
  
  /// Get all keys
  Future<Set<String>> getKeys();
  
  /// Clear all data
  Future<bool> clear();
  
  /// Get storage size in bytes (approximate)
  Future<int> getStorageSize();
  
  /// Check if storage is available
  bool get isAvailable;
  
  /// Bulk set operations
  Future<bool> setBulk(Map<String, dynamic> data);
  
  /// Bulk get operations
  Future<Map<String, dynamic>> getBulk(List<String> keys);
}