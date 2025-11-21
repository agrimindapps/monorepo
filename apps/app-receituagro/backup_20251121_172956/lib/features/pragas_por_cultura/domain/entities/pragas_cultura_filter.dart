/// Filter parameters for pragas por cultura
class PragasCulturaFilter {
  final bool onlyCriticas;
  final bool onlyNormais;
  final String? tipoPraga; // '1' = Insetos, '2' = Doenças, '3' = Plantas Daninhas
  final String sortBy; // 'ameaca', 'nome', 'diagnosticos'

  const PragasCulturaFilter({
    this.onlyCriticas = false,
    this.onlyNormais = false,
    this.tipoPraga,
    this.sortBy = 'ameaca',
  });

  /// Create a copy with optional field updates
  PragasCulturaFilter copyWith({
    bool? onlyCriticas,
    bool? onlyNormais,
    String? tipoPraga,
    String? sortBy,
  }) {
    return PragasCulturaFilter(
      onlyCriticas: onlyCriticas ?? this.onlyCriticas,
      onlyNormais: onlyNormais ?? this.onlyNormais,
      tipoPraga: tipoPraga ?? this.tipoPraga,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PragasCulturaFilter &&
          runtimeType == other.runtimeType &&
          onlyCriticas == other.onlyCriticas &&
          onlyNormais == other.onlyNormais &&
          tipoPraga == other.tipoPraga &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      onlyCriticas.hashCode ^
      onlyNormais.hashCode ^
      tipoPraga.hashCode ^
      sortBy.hashCode;

  @override
  String toString() =>
      'PragasCulturaFilter(onlyCriticas: $onlyCriticas, onlyNormais: $onlyNormais, tipoPraga: $tipoPraga, sortBy: $sortBy)';
}
