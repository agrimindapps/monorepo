class AdipososidadeModel {
  final int generoSelecionado;
  final double quadril;
  final double altura;
  final int idade;
  final double iac;
  final String classificacao;
  final String comentario;

  const AdipososidadeModel({
    required this.generoSelecionado,
    required this.quadril,
    required this.altura,
    required this.idade,
    required this.iac,
    required this.classificacao,
    required this.comentario,
  });

  // Factory para criar um modelo vazio
  factory AdipososidadeModel.empty() {
    return const AdipososidadeModel(
      generoSelecionado: 1,
      quadril: 0,
      altura: 0,
      idade: 0,
      iac: 0,
      classificacao: '',
      comentario: '',
    );
  }

  // Método para criar uma cópia com alguns valores alterados
  AdipososidadeModel copyWith({
    int? generoSelecionado,
    double? quadril,
    double? altura,
    int? idade,
    double? iac,
    String? classificacao,
    String? comentario,
  }) {
    return AdipososidadeModel(
      generoSelecionado: generoSelecionado ?? this.generoSelecionado,
      quadril: quadril ?? this.quadril,
      altura: altura ?? this.altura,
      idade: idade ?? this.idade,
      iac: iac ?? this.iac,
      classificacao: classificacao ?? this.classificacao,
      comentario: comentario ?? this.comentario,
    );
  }
}
