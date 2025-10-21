class AlcoolSangueModel {
  final double alcoolPerc;
  final double volume;
  final double tempo;
  final double peso;
  final double tas;
  final String condicao;

  AlcoolSangueModel({
    required this.alcoolPerc,
    required this.volume,
    required this.tempo,
    required this.peso,
    required this.tas,
    required this.condicao,
  });

  factory AlcoolSangueModel.empty() {
    return AlcoolSangueModel(
      alcoolPerc: 0,
      volume: 0,
      tempo: 0,
      peso: 0,
      tas: 0,
      condicao: '',
    );
  }
}
