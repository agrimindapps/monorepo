import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_state.freezed.dart';

/// Estado imutável do analytics usando freezed (Plantis-specific)
@freezed
class PlantisAnalyticsState with _$PlantisAnalyticsState {
  const PlantisAnalyticsState._();

  const factory PlantisAnalyticsState({
    @Default(false) bool isInitialized,
    required bool isAnalyticsEnabled,
    String? errorMessage,
  }) = _PlantisAnalyticsState;

  /// Estado inicial padrão
  factory PlantisAnalyticsState.initial() {
    return PlantisAnalyticsState(
      isAnalyticsEnabled: EnvironmentConfig.enableAnalytics,
    );
  }

  /// Remove erro
  PlantisAnalyticsState clearError() {
    return copyWith(errorMessage: null);
  }
}
