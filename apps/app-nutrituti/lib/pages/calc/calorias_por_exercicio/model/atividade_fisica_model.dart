class AtividadeFisicaModel {
  final int id;
  final String text;
  final double value;

  AtividadeFisicaModel({
    required this.id,
    required this.text,
    required this.value,
  });

  factory AtividadeFisicaModel.fromMap(Map<String, dynamic> map) {
    return AtividadeFisicaModel(
      id: map['id'] as int,
      text: map['text'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'value': value,
    };
  }
}
