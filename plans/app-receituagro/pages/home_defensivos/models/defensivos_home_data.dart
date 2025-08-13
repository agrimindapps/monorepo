// Project imports:
import 'defensivo_item.dart';

class DefensivosHomeData {
  final int defensivos;
  final int fabricantes;
  final int actionMode;
  final int activeIngredient;
  final int agronomicClass;
  final List<DefensivoItem> recentlyAccessed;
  final List<DefensivoItem> newProducts;

  DefensivosHomeData({
    this.defensivos = 0,
    this.fabricantes = 0,
    this.actionMode = 0,
    this.activeIngredient = 0,
    this.agronomicClass = 0,
    this.recentlyAccessed = const [],
    this.newProducts = const [],
  });

  DefensivosHomeData copyWith({
    int? defensivos,
    int? fabricantes,
    int? actionMode,
    int? activeIngredient,
    int? agronomicClass,
    List<DefensivoItem>? recentlyAccessed,
    List<DefensivoItem>? newProducts,
  }) {
    return DefensivosHomeData(
      defensivos: defensivos ?? this.defensivos,
      fabricantes: fabricantes ?? this.fabricantes,
      actionMode: actionMode ?? this.actionMode,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      agronomicClass: agronomicClass ?? this.agronomicClass,
      recentlyAccessed: recentlyAccessed ?? this.recentlyAccessed,
      newProducts: newProducts ?? this.newProducts,
    );
  }
}
