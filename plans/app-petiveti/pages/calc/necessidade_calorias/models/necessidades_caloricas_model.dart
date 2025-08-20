class NecessidadesCaloricas {
  final double peso;
  final String especie;
  final String estadoFisiologico;
  final String nivelAtividade;
  final double resultado;
  final String recomendacao;

  NecessidadesCaloricas({
    required this.peso,
    required this.especie,
    required this.estadoFisiologico,
    required this.nivelAtividade,
    required this.resultado,
    required this.recomendacao,
  });

  // Método para criar uma cópia do objeto com alterações
  NecessidadesCaloricas copyWith({
    double? peso,
    String? especie,
    String? estadoFisiologico,
    String? nivelAtividade,
    double? resultado,
    String? recomendacao,
  }) {
    return NecessidadesCaloricas(
      peso: peso ?? this.peso,
      especie: especie ?? this.especie,
      estadoFisiologico: estadoFisiologico ?? this.estadoFisiologico,
      nivelAtividade: nivelAtividade ?? this.nivelAtividade,
      resultado: resultado ?? this.resultado,
      recomendacao: recomendacao ?? this.recomendacao,
    );
  }
}
