/// Estatísticas de conflitos de sincronização
class ConflictStats {
  /// Número de conflitos não resolvidos
  final int unresolved;

  /// Número de conflitos resolvidos
  final int resolved;

  /// Número total de conflitos registrados
  final int total;

  /// Conflitos agrupados por tipo de modelo
  final Map<String, int> byModel;

  /// Taxa de resolução em porcentagem (0.0 - 100.0)
  final String resolutionRate;

  ConflictStats({
    required this.unresolved,
    required this.resolved,
    required this.total,
    required this.byModel,
    required this.resolutionRate,
  });

  /// Indica se há conflitos pendentes
  bool get hasPendingConflicts => unresolved > 0;

  /// Indica se todos os conflitos foram resolvidos
  bool get allResolved => unresolved == 0 && total > 0;

  /// Taxa de resolução como double (0.0 - 1.0)
  double get resolutionRateAsDouble {
    return double.tryParse(resolutionRate) ?? 0.0;
  }

  Map<String, dynamic> toMap() => {
    'unresolved': unresolved,
    'resolved': resolved,
    'total': total,
    'byModel': byModel,
    'resolutionRate': resolutionRate,
  };

  @override
  String toString() {
    return 'ConflictStats('
        'unresolved: $unresolved, '
        'resolved: $resolved, '
        'total: $total, '
        'resolutionRate: $resolutionRate%)';
  }
}
