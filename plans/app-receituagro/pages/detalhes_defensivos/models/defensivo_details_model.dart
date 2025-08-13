class DefensivoDetailsModel {
  final Map<String, dynamic> caracteristicas;
  final List<dynamic> diagnosticos;
  final Map<String, dynamic> informacoes;

  const DefensivoDetailsModel({
    required this.caracteristicas,
    required this.diagnosticos,
    required this.informacoes,
  });

  factory DefensivoDetailsModel.empty() {
    return const DefensivoDetailsModel(
      caracteristicas: {},
      diagnosticos: [],
      informacoes: {},
    );
  }

  DefensivoDetailsModel copyWith({
    Map<String, dynamic>? caracteristicas,
    List<dynamic>? diagnosticos,
    Map<String, dynamic>? informacoes,
  }) {
    return DefensivoDetailsModel(
      caracteristicas: caracteristicas ?? this.caracteristicas,
      diagnosticos: diagnosticos ?? this.diagnosticos,
      informacoes: informacoes ?? this.informacoes,
    );
  }

  bool get isEmpty => 
      caracteristicas.isEmpty && 
      diagnosticos.isEmpty && 
      informacoes.isEmpty;

  bool get isNotEmpty => !isEmpty;
}