import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user preferences like favorites and recent games
class UserPreferencesService {
  static const String _favoritesKey = 'favorite_games';
  static const String _recentsKey = 'recent_games';
  static const int _maxRecents = 10;

  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  // Favorites
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> addFavorite(String gameId) async {
    final favorites = getFavorites();
    if (!favorites.contains(gameId)) {
      favorites.add(gameId);
      return _prefs.setStringList(_favoritesKey, favorites);
    }
    return true;
  }

  Future<bool> removeFavorite(String gameId) async {
    final favorites = getFavorites();
    favorites.remove(gameId);
    return _prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> toggleFavorite(String gameId) async {
    if (isFavorite(gameId)) {
      return removeFavorite(gameId);
    } else {
      return addFavorite(gameId);
    }
  }

  bool isFavorite(String gameId) {
    return getFavorites().contains(gameId);
  }

  // Recents
  List<String> getRecents() {
    return _prefs.getStringList(_recentsKey) ?? [];
  }

  Future<bool> addRecent(String gameId) async {
    final recents = getRecents();

    // Remove if already exists to move to top
    recents.remove(gameId);

    // Add to beginning
    recents.insert(0, gameId);

    // Keep only max recents
    if (recents.length > _maxRecents) {
      recents.removeRange(_maxRecents, recents.length);
    }

    return _prefs.setStringList(_recentsKey, recents);
  }

  Future<bool> clearRecents() async {
    return _prefs.remove(_recentsKey);
  }
}
