import 'package:core/core.dart' hide Column;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_state.freezed.dart';

/// Estado imutável do analytics usando freezed (Plantis-specific)
@freezed
sealed class PlantisAnalyticsState with _$PlantisAnalyticsState {
  const factory PlantisAnalyticsState({
    @Default(false) bool isInitialized,
    required bool isAnalyticsEnabled,
    String? errorMessage,
  }) = _PlantisAnalyticsState;
}

/// Extension providing factory constructors and methods for PlantisAnalyticsState
extension PlantisAnalyticsStateX on PlantisAnalyticsState {
  /// Estado inicial padrão
  static PlantisAnalyticsState initial() {
    return PlantisAnalyticsState(
      isAnalyticsEnabled: EnvironmentConfig.enableAnalytics,
    );
  }

  /// Remove erro
  PlantisAnalyticsState clearError() {
    return copyWith(errorMessage: null);
  }
}
