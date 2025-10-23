
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
      id: (map['id'] as num).toInt(),
      nome: map['text'] as String,
      caloriasMinuto: (map['value'] as num).toDouble(),
      descricao: map['descricao'] as String? ?? '',
    );
  }
}
