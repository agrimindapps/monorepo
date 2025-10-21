class ZNewIndiceAdiposidadeModel {
  int generoSelecionado = 1;
  double quadril = 0.0;
  double altura = 0.0;
  int idade = 0;
  double iac = 0.0;
  String classificacao = '';
  String comentario = '';

  ZNewIndiceAdiposidadeModel({
    required this.generoSelecionado,
    required this.quadril,
    required this.altura,
    required this.idade,
    this.iac = 0.0,
    this.classificacao = '',
    this.comentario = '',
  });

  ZNewIndiceAdiposidadeModel.empty() {
    generoSelecionado = 1;
    quadril = 0.0;
    altura = 0.0;
    idade = 0;
    iac = 0.0;
    classificacao = '';
    comentario = '';
  }
}
