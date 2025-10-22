/// Exception thrown when cache operations fail
class CacheException implements Exception {
  final String? message;

  CacheException([this.message]);

  @override
  String toString() => message ?? 'CacheException';
}

/// Exception thrown when game logic validation fails
class GameLogicException implements Exception {
  final String message;

  GameLogicException(this.message);

  @override
  String toString() => 'GameLogicException: $message';
}
