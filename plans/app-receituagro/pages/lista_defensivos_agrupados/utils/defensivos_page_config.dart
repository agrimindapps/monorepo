class DefensivosPageConfig {
  static const int itemsPerScroll = 50;
  static const int minSearchLength = 3;
  static const double scrollThreshold = 200.0;
  static const int maxDatabaseLoadAttempts = 50;
  static const Duration databaseLoadDelay = Duration(milliseconds: 100);
  static const Duration initialDataDelay = Duration(milliseconds: 100);
  static const Duration retryDelay = Duration(milliseconds: 500);
}