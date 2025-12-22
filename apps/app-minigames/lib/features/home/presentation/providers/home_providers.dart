import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/games_data.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/enums/game_category.dart';

part 'home_providers.g.dart';

/// Selected category filter
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  GameCategory build() => GameCategory.all;

  void select(GameCategory category) => state = category;
}

/// Search query
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

/// Filtered games based on category and search
@riverpod
List<GameEntity> filteredGames(Ref ref) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final featuredGamesList = ref.watch(featuredGamesProvider);

  var games = GamesData.getByCategory(category);

  // Remove featured games from the main list to avoid duplicate Hero tags
  final featuredIds = featuredGamesList.map((g) => g.id).toSet();
  games = games.where((g) => !featuredIds.contains(g.id)).toList();

  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    games = games
        .where((g) =>
            g.name.toLowerCase().contains(lowerQuery) ||
            g.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  return games;
}

/// Featured games
@riverpod
List<GameEntity> featuredGames(Ref ref) => GamesData.featuredGames;

/// New games (excluding featured to avoid duplicate Heroes)
@riverpod
List<GameEntity> newGames(Ref ref) {
  final featuredGamesList = ref.watch(featuredGamesProvider);
  final featuredIds = featuredGamesList.map((g) => g.id).toSet();
  return GamesData.newGames.where((g) => !featuredIds.contains(g.id)).toList();
}

/// Multiplayer games (excluding featured to avoid duplicate Heroes)
@riverpod
List<GameEntity> multiplayerGames(Ref ref) {
  final featuredGamesList = ref.watch(featuredGamesProvider);
  final featuredIds = featuredGamesList.map((g) => g.id).toSet();
  return GamesData.multiplayerGames.where((g) => !featuredIds.contains(g.id)).toList();
}

/// All games
@riverpod
List<GameEntity> allGames(Ref ref) => GamesData.allGames;

/// Category counts
@riverpod
Map<GameCategory, int> categoryCounts(Ref ref) {
  final counts = <GameCategory, int>{};
  for (final category in GameCategory.values) {
    counts[category] = GamesData.getByCategory(category).length;
  }
  return counts;
}
