
class IdadeAnimalModel {
  String? especieSelecionada;
  String? porteCanino;
  String? resultado;

  // Opções para os dropdowns
  final List<String> especies = ['Cão', 'Gato'];
  final List<String> portesCaes = [
    'Pequeno (até 9kg)',
    'Médio (10kg a 22kg)',
    'Grande (23kg a 40kg)',
    'Gigante (acima de 40kg)'
  ];

  void limpar() {
    especieSelecionada = null;
    porteCanino = null;
    resultado = null;
  }

  // Métodos para copiar o estado
  IdadeAnimalModel copyWith({
    String? especieSelecionada,
    String? porteCanino,
    String? resultado,
  }) {
    return IdadeAnimalModel()
      ..especieSelecionada = especieSelecionada ?? this.especieSelecionada
      ..porteCanino = porteCanino ?? this.porteCanino
      ..resultado = resultado ?? this.resultado;
  }
}
