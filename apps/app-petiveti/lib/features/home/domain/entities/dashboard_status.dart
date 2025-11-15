/// Entity representing dashboard status
class DashboardStatus {
  final bool isLoading;
  final bool isOnline;
  final String? errorMessage;
  final DateTime lastUpdated;

  const DashboardStatus({
    this.isLoading = false,
    this.isOnline = true,
    this.errorMessage,
    required this.lastUpdated,
  });

  /// Whether dashboard is in error state
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Time since last update
  Duration get timeSinceUpdate => DateTime.now().difference(lastUpdated);

  /// Whether update is stale (older than 5 minutes)
  bool get isStale => timeSinceUpdate.inMinutes > 5;

  /// Copy with pattern
  DashboardStatus copyWith({
    bool? isLoading,
    bool? isOnline,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return DashboardStatus(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
