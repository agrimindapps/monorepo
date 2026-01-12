import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/games_data.dart';
import '../../features/home/domain/entities/game_entity.dart';
import '../services/user_preferences_service.dart';

part 'user_preferences_providers.g.dart';

/// Provider for SharedPreferences instance
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Provider for UserPreferencesService
@Riverpod(keepAlive: true)
Future<UserPreferencesService> userPreferencesService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return UserPreferencesService(prefs);
}

/// Provider for favorite game IDs
@riverpod
class FavoriteGames extends _$FavoriteGames {
  @override
  Future<List<String>> build() async {
    final service = await ref.watch(userPreferencesServiceProvider.future);
    return service.getFavorites();
  }

  Future<void> toggle(String gameId) async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.toggleFavorite(gameId);
    state = AsyncValue.data(service.getFavorites());
  }

  bool isFavorite(String gameId) {
    return state.value?.contains(gameId) ?? false;
  }
}

/// Provider for favorite game entities (full game objects)
@riverpod
List<GameEntity> favoriteGameEntities(Ref ref) {
  final favoriteIdsAsync = ref.watch(favoriteGamesProvider);
  
  return favoriteIdsAsync.when(
    data: (favoriteIds) {
      return GamesData.allGames
          .where((game) => favoriteIds.contains(game.id))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for recent game IDs
@riverpod
class RecentGames extends _$RecentGames {
  @override
  Future<List<String>> build() async {
    final service = await ref.watch(userPreferencesServiceProvider.future);
    return service.getRecents();
  }

  Future<void> addRecent(String gameId) async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.addRecent(gameId);
    state = AsyncValue.data(service.getRecents());
  }

  Future<void> clear() async {
    final service = await ref.read(userPreferencesServiceProvider.future);
    await service.clearRecents();
    state = const AsyncValue.data([]);
  }
}

/// Provider for recent game entities (full game objects)
@riverpod
List<GameEntity> recentGameEntities(Ref ref) {
  final recentIdsAsync = ref.watch(recentGamesProvider);
  
  return recentIdsAsync.when(
    data: (recentIds) {
      final games = <GameEntity>[];
      for (final id in recentIds) {
        try {
          final game = GamesData.allGames.firstWhere((g) => g.id == id);
          games.add(game);
        } catch (_) {
          // Game not found, skip it
        }
      }
      return games;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
