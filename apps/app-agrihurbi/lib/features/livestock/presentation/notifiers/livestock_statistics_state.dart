import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_statistics_state.freezed.dart';

/// Immutable state for livestock statistics
@freezed
class LivestockStatisticsState with _$LivestockStatisticsState {
  const factory LivestockStatisticsState({
    @Default(false) bool isLoading,
    @Default(null) Map<String, dynamic>? statistics,
    @Default(null) String? errorMessage,
    @Default(null) DateTime? lastUpdate,
  }) = _LivestockStatisticsState;
}
