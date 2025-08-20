class Medicamento {
  final String nome;
  final String tipo;
  final String indicacao;

  const Medicamento({
    required this.nome,
    required this.tipo,
    required this.indicacao,
  });

  factory Medicamento.fromMap(Map<String, String> map) {
    return Medicamento(
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      indicacao: map['indicacao'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'indicacao': indicacao,
    };
  }

  bool matchesSearch(String searchText) {
    final search = searchText.toLowerCase();
    return nome.toLowerCase().contains(search) ||
           tipo.toLowerCase().contains(search) ||
           indicacao.toLowerCase().contains(search);
  }

  bool matchesType(String filterType) {
    return filterType == 'Todos' || tipo == filterType;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicamento &&
        other.nome == nome &&
        other.tipo == tipo &&
        other.indicacao == indicacao;
  }

  @override
  int get hashCode => nome.hashCode ^ tipo.hashCode ^ indicacao.hashCode;

  @override
  String toString() {
    return 'Medicamento(nome: $nome, tipo: $tipo, indicacao: $indicacao)';
  }
}

class MedicamentoRepository {
  static const List<Medicamento> _medicamentos = [
    Medicamento(
      nome: 'Amoxicilina',
      tipo: 'Antibiótico',
      indicacao: 'Infecções bacterianas',
    ),
    Medicamento(
      nome: 'Dipirona',
      tipo: 'Analgésico',
      indicacao: 'Dor e febre',
    ),
    Medicamento(
      nome: 'Drontal',
      tipo: 'Vermífugo',
      indicacao: 'Vermes intestinais',
    ),
    Medicamento(
      nome: 'Frontline',
      tipo: 'Antiparasitário',
      indicacao: 'Pulgas e carrapatos',
    ),
    Medicamento(
      nome: 'Meloxicam',
      tipo: 'Anti-inflamatório',
      indicacao: 'Inflamação e dor',
    ),
    Medicamento(
      nome: 'Prednisolona',
      tipo: 'Corticoide',
      indicacao: 'Alergias e inflamações',
    ),
    Medicamento(
      nome: 'Proxicam',
      tipo: 'Anti-inflamatório',
      indicacao: 'Dor articular',
    ),
    Medicamento(
      nome: 'Rimadyl',
      tipo: 'Anti-inflamatório',
      indicacao: 'Dor e inflamação',
    ),
    Medicamento(
      nome: 'Simparic',
      tipo: 'Antiparasitário',
      indicacao: 'Pulgas e carrapatos',
    ),
    Medicamento(
      nome: 'Vetnil',
      tipo: 'Suplemento',
      indicacao: 'Vitaminas e minerais',
    ),
  ];

  static List<Medicamento> getTodos() => List.unmodifiable(_medicamentos);

  static List<Medicamento> filter({
    String searchText = '',
    String filterType = 'Todos',
  }) {
    return _medicamentos.where((medicamento) {
      final matchesSearch = searchText.isEmpty || medicamento.matchesSearch(searchText);
      final matchesType = medicamento.matchesType(filterType);
      return matchesSearch && matchesType;
    }).toList();
  }

  static Map<String, List<Medicamento>> groupByType(List<Medicamento> medicamentos) {
    final result = <String, List<Medicamento>>{};
    
    for (final medicamento in medicamentos) {
      if (!result.containsKey(medicamento.tipo)) {
        result[medicamento.tipo] = [];
      }
      result[medicamento.tipo]!.add(medicamento);
    }
    
    return result;
  }
}