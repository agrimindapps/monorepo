import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user preferences like favorites and recent calculators
class UserPreferencesService {
  static const String _favoritesKey = 'favorite_calculators';
  static const String _recentsKey = 'recent_calculators';
  static const int _maxRecents = 5;

  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  // Favorites
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> addFavorite(String route) async {
    final favorites = getFavorites();
    if (!favorites.contains(route)) {
      favorites.add(route);
      return _prefs.setStringList(_favoritesKey, favorites);
    }
    return true;
  }

  Future<bool> removeFavorite(String route) async {
    final favorites = getFavorites();
    favorites.remove(route);
    return _prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> toggleFavorite(String route) async {
    if (isFavorite(route)) {
      return removeFavorite(route);
    } else {
      return addFavorite(route);
    }
  }

  bool isFavorite(String route) {
    return getFavorites().contains(route);
  }

  // Recents
  List<String> getRecents() {
    return _prefs.getStringList(_recentsKey) ?? [];
  }

  Future<bool> addRecent(String route) async {
    final recents = getRecents();

    // Remove if already exists to move to top
    recents.remove(route);

    // Add to beginning
    recents.insert(0, route);

    // Keep only max recents
    if (recents.length > _maxRecents) {
      recents.removeRange(_maxRecents, recents.length);
    }

    return _prefs.setStringList(_recentsKey, recents);
  }

  Future<bool> clearRecents() async {
    return _prefs.remove(_recentsKey);
  }

  // View preference
  static const String _viewModeKey = 'view_mode';

  String getViewMode() {
    return _prefs.getString(_viewModeKey) ?? 'grid';
  }

  Future<bool> setViewMode(String mode) async {
    return _prefs.setString(_viewModeKey, mode);
  }

  bool isGridView() {
    return getViewMode() == 'grid';
  }

  bool isListView() {
    return getViewMode() == 'list';
  }
}
