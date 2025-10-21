
class ExercicioModel {
  final int id;
  final String nome;
  final double caloriasMinuto;
  final String descricao;

  ExercicioModel({
    required this.id,
    required this.nome,
    required this.caloriasMinuto,
    this.descricao = '',
  });

  double calcularCalorias(int minutos) {
    return caloriasMinuto * minutos;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': nome,
      'value': caloriasMinuto,
      'descricao': descricao,
    };
  }

  static ExercicioModel fromMap(Map<String, dynamic> map) {
    return ExercicioModel(
      id: map['id'],
      nome: map['text'],
      caloriasMinuto: map['value'].toDouble(),
      descricao: map['descricao'] ?? '',
    );
  }
}
