/// GasometerSyncState - State para gerenciamento de sincronização de dados
///
/// Separado do AuthState para aplicar SRP
/// Renamed para evitar conflito com SyncState do core
class GasometerSyncState {
  const GasometerSyncState({
    this.isSyncing = false,
    this.hasError = false,
    this.syncMessage,
  });

  const GasometerSyncState.initial() : this();

  final bool isSyncing;
  final bool hasError;
  final String? syncMessage;

  GasometerSyncState copyWith({
    bool? isSyncing,
    bool? hasError,
    String? syncMessage,
    bool clearMessage = false,
  }) {
    return GasometerSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasError: hasError ?? this.hasError,
      syncMessage: clearMessage ? null : (syncMessage ?? this.syncMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GasometerSyncState &&
          runtimeType == other.runtimeType &&
          isSyncing == other.isSyncing &&
          hasError == other.hasError &&
          syncMessage == other.syncMessage;

  @override
  int get hashCode =>
      isSyncing.hashCode ^ hasError.hashCode ^ syncMessage.hashCode;

  @override
  String toString() =>
      'GasometerSyncState(isSyncing: $isSyncing, hasError: $hasError, syncMessage: $syncMessage)';
}
