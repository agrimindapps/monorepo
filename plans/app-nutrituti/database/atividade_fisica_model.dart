class AtividadeFisicaModel {
  final int id;
  final double valorCalorico;
  final String nome;
  final String categoria;

  AtividadeFisicaModel({
    required this.id,
    required this.valorCalorico,
    required this.nome,
    required this.categoria,
  });

  // Converter para Map para usar em dropdowns e outros componentes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': valorCalorico,
      'text': nome,
      'categoria': categoria,
    };
  }

  // Criar a partir de um Map
  factory AtividadeFisicaModel.fromMap(Map<String, dynamic> map) {
    return AtividadeFisicaModel(
      id: map['id'],
      valorCalorico: map['value'],
      nome: map['text'],
      categoria: map['categoria'] ?? 'Outro',
    );
  }
}
