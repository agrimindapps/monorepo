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

  var games = GamesData.getByCategory(category);

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

/// New games
@riverpod
List<GameEntity> newGames(Ref ref) => GamesData.newGames;

/// Multiplayer games
@riverpod
List<GameEntity> multiplayerGames(Ref ref) => GamesData.multiplayerGames;

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
