/// Statistics calculated from pragas por cultura
class PragasCulturaStatistics {
  final int totalPragas;
  final int pragasCriticas;
  final int pragasAltoRisco;
  final int totalDiagnosticos;
  final int defensivosUnicos;

  const PragasCulturaStatistics({
    required this.totalPragas,
    required this.pragasCriticas,
    required this.pragasAltoRisco,
    required this.totalDiagnosticos,
    required this.defensivosUnicos,
  });

  /// Create a copy with optional field updates
  PragasCulturaStatistics copyWith({
    int? totalPragas,
    int? pragasCriticas,
    int? pragasAltoRisco,
    int? totalDiagnosticos,
    int? defensivosUnicos,
  }) {
    return PragasCulturaStatistics(
      totalPragas: totalPragas ?? this.totalPragas,
      pragasCriticas: pragasCriticas ?? this.pragasCriticas,
      pragasAltoRisco: pragasAltoRisco ?? this.pragasAltoRisco,
      totalDiagnosticos: totalDiagnosticos ?? this.totalDiagnosticos,
      defensivosUnicos: defensivosUnicos ?? this.defensivosUnicos,
    );
  }

  /// Calculate percentage of criticas pragas
  double get percentualCriticas {
    if (totalPragas == 0) return 0.0;
    return (pragasCriticas / totalPragas * 100).clamp(0.0, 100.0);
  }

  /// Calculate average diagnosticos per praga
  double get mediadiagnosticosPorPraga {
    if (totalPragas == 0) return 0.0;
    return totalDiagnosticos / totalPragas;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PragasCulturaStatistics &&
          runtimeType == other.runtimeType &&
          totalPragas == other.totalPragas &&
          pragasCriticas == other.pragasCriticas &&
          pragasAltoRisco == other.pragasAltoRisco &&
          totalDiagnosticos == other.totalDiagnosticos &&
          defensivosUnicos == other.defensivosUnicos;

  @override
  int get hashCode =>
      totalPragas.hashCode ^
      pragasCriticas.hashCode ^
      pragasAltoRisco.hashCode ^
      totalDiagnosticos.hashCode ^
      defensivosUnicos.hashCode;

  @override
  String toString() =>
      'PragasCulturaStatistics(totalPragas: $totalPragas, pragasCriticas: $pragasCriticas, pragasAltoRisco: $pragasAltoRisco, totalDiagnosticos: $totalDiagnosticos, defensivosUnicos: $defensivosUnicos)';
}
