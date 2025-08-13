/// Constantes para configuração de busca e performance
class SearchConstants {
  // Debounce
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration fastDebounceDelay = Duration(milliseconds: 150);
  static const Duration slowDebounceDelay = Duration(milliseconds: 500);

  // Thresholds de busca
  static const int minimumSearchLength = 1; // Removida limitação mínima
  static const int performanceThreshold =
      1000; // Número de itens para otimizações

  // Performance
  static const int maxSearchResults = 100;
  static const Duration searchTimeout = Duration(seconds: 5);

  // UX
  static const Duration loadingAnimationDuration = Duration(milliseconds: 200);
  static const Duration searchResultsAnimationDuration =
      Duration(milliseconds: 300);
}
