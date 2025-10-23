// STUB - FASE 0.7
// TODO FASE 1: Implementar settings completos de premium

class PremiumSettings {
  final bool enableDebugInfo;
  final bool showRestoreButton;
  final bool autoSelectRecommendedPlan;

  const PremiumSettings({
    this.enableDebugInfo = false,
    this.showRestoreButton = true,
    this.autoSelectRecommendedPlan = false,
  });

  PremiumSettings copyWith({
    bool? enableDebugInfo,
    bool? showRestoreButton,
    bool? autoSelectRecommendedPlan,
  }) {
    return PremiumSettings(
      enableDebugInfo: enableDebugInfo ?? this.enableDebugInfo,
      showRestoreButton: showRestoreButton ?? this.showRestoreButton,
      autoSelectRecommendedPlan: autoSelectRecommendedPlan ?? this.autoSelectRecommendedPlan,
    );
  }
}
