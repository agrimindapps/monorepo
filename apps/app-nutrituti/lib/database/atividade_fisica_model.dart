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
      id: map['id'] as int,
      valorCalorico: (map['value'] as num).toDouble(),
      nome: map['text'] as String,
      categoria: map['categoria'] as String? ?? 'Outro',
    );
  }
}
