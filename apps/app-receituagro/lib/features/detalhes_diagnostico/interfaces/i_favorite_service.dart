/// Abstract interface for favorites management
/// Following Interface Segregation Principle (SOLID)
abstract class IFavoriteService {
  /// Check if an item is marked as favorite
  Future<bool> isFavorite(String itemId);
  
  /// Add item to favorites
  Future<void> addToFavorites(String itemId);
  
  /// Remove item from favorites
  Future<void> removeFromFavorites(String itemId);
  
  /// Toggle favorite status
  Future<bool> toggleFavorite(String itemId);
  
  /// Get all favorite items
  Future<List<String>> getAllFavorites();
  
  /// Get favorites count
  Future<int> getFavoritesCount();
  
  /// Clear all favorites
  Future<void> clearAllFavorites();
  
  /// Bulk add favorites
  Future<void> addMultipleToFavorites(List<String> itemIds);
  
  /// Bulk remove favorites
  Future<void> removeMultipleFromFavorites(List<String> itemIds);
  
  /// Check if favorites feature is enabled
  bool get isEnabled;
  
  /// Stream of favorite changes for reactive updates
  Stream<List<String>> get favoritesStream;
}