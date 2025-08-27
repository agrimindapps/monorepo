/// Entity que representa um diagnóstico relacionado a um defensivo
/// Segue os princípios Clean Architecture - sem dependências externas
class DiagnosticoEntity {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String dosagem;
  final String cultura;
  final String grupo;

  const DiagnosticoEntity({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    required this.dosagem,
    required this.cultura,
    required this.grupo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticoEntity &&
        other.id == id &&
        other.nome == nome &&
        other.ingredienteAtivo == ingredienteAtivo &&
        other.dosagem == dosagem &&
        other.cultura == cultura &&
        other.grupo == grupo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        ingredienteAtivo.hashCode ^
        dosagem.hashCode ^
        cultura.hashCode ^
        grupo.hashCode;
  }

  @override
  String toString() {
    return 'DiagnosticoEntity(id: $id, nome: $nome, ingredienteAtivo: $ingredienteAtivo, dosagem: $dosagem, cultura: $cultura, grupo: $grupo)';
  }

  /// Cria uma cópia com alguns campos alterados
  DiagnosticoEntity copyWith({
    String? id,
    String? nome,
    String? ingredienteAtivo,
    String? dosagem,
    String? cultura,
    String? grupo,
  }) {
    return DiagnosticoEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      dosagem: dosagem ?? this.dosagem,
      cultura: cultura ?? this.cultura,
      grupo: grupo ?? this.grupo,
    );
  }
}