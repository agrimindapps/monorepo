// Modelos de dados para densidade de nutrientes

class NutrienteModel {
  final int id;
  final String text;
  final String unidade;

  const NutrienteModel({
    required this.id,
    required this.text,
    required this.unidade,
  });

  String get nome => text.split(' ')[0];
}

class DensidadeNutrientesResultado {
  final double calorias;
  final double nutriente;
  final double densidadeNutrientes;
  final String avaliacao;
  final String comentario;
  final NutrienteModel nutrienteSelecionado;

  DensidadeNutrientesResultado({
    required this.calorias,
    required this.nutriente,
    required this.densidadeNutrientes,
    required this.avaliacao,
    required this.comentario,
    required this.nutrienteSelecionado,
  });
}
