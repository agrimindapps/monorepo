class MedicamentoDetalhes {
  final String nome;
  final String tipo;
  final String indicacao;

  const MedicamentoDetalhes({
    required this.nome,
    required this.tipo,
    required this.indicacao,
  });

  factory MedicamentoDetalhes.fromMap(Map<String, String> map) {
    return MedicamentoDetalhes(
      nome: map['nome'] ?? 'Medicamento',
      tipo: map['tipo'] ?? 'Não informado',
      indicacao: map['indicacao'] ?? 'Não informado',
    );
  }

  Map<String, String> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'indicacao': indicacao,
    };
  }

  bool get isAntibiotico => tipo == 'Antibiótico';
  bool get isAnalgesico => tipo == 'Analgésico';
  bool get isAntiInflamatorio => tipo == 'Anti-inflamatório';

  bool get temCalculadoraDosagem =>
      isAntibiotico || isAnalgesico || isAntiInflamatorio;

  String get administracaoTipica {
    switch (tipo) {
      case 'Antibiótico':
        return 'Antibióticos geralmente devem ser administrados até o fim do tratamento, mesmo se os sintomas desaparecerem antes.';
      case 'Analgésico':
        return 'Analgésicos devem ser administrados conforme necessidade e prescrição veterinária para controle da dor.';
      case 'Anti-inflamatório':
        return 'Anti-inflamatórios geralmente são administrados com alimento para reduzir irritação gástrica.';
      default:
        return '';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicamentoDetalhes &&
        other.nome == nome &&
        other.tipo == tipo &&
        other.indicacao == indicacao;
  }

  @override
  int get hashCode => nome.hashCode ^ tipo.hashCode ^ indicacao.hashCode;

  @override
  String toString() {
    return 'MedicamentoDetalhes(nome: $nome, tipo: $tipo, indicacao: $indicacao)';
  }
}