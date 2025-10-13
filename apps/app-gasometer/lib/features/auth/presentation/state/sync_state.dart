import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

/// GasometerSyncState - State para gerenciamento de sincronização de dados
///
/// Separado do AuthState para aplicar SRP
/// Renamed para evitar conflito com SyncState do core
@freezed
class GasometerSyncState with _$GasometerSyncState {
  const factory GasometerSyncState({
    @Default(false) bool isSyncing,
    @Default(false) bool hasError,
    String? syncMessage,
  }) = _GasometerSyncState;

  const factory GasometerSyncState.initial() = _GasometerSyncStateInitial;
}

/// Extension para facilitar copyWith com clear flags
extension GasometerSyncStateX on GasometerSyncState {
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
}
