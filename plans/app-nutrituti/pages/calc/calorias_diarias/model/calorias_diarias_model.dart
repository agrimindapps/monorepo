
class CaloriasDiariasModel {
  int generoSelecionado;
  String generoText;
  Map<String, dynamic> generoData;
  int atividadeSelecionada;
  String atividadeText;
  double atividadeFator;
  int idade;
  double altura;
  double peso;
  int resultado;

  CaloriasDiariasModel({
    required this.generoSelecionado,
    required this.generoText,
    required this.generoData,
    required this.atividadeSelecionada,
    required this.atividadeText,
    required this.atividadeFator,
    required this.idade,
    required this.altura,
    required this.peso,
    required this.resultado,
  });

  factory CaloriasDiariasModel.empty() {
    return CaloriasDiariasModel(
      generoSelecionado: 1,
      generoText: 'Masculino',
      generoData: {
        'id': 1,
        'text': 'Masculino',
        'fator': 66,
        'KQuilos': 13.7,
        'KIdade': 5.0,
        'KAltura': 6.8
      },
      atividadeSelecionada: 1,
      atividadeText: 'Sedentario',
      atividadeFator: 1.25,
      idade: 0,
      altura: 0,
      peso: 0,
      resultado: 0,
    );
  }

  void limpar() {
    generoSelecionado = 1;
    generoText = 'Masculino';
    generoData = {
      'id': 1,
      'text': 'Masculino',
      'fator': 66,
      'KQuilos': 13.7,
      'KIdade': 5.0,
      'KAltura': 6.8
    };
    atividadeSelecionada = 1;
    atividadeText = 'Sedentario';
    atividadeFator = 1.25;
    idade = 0;
    altura = 0;
    peso = 0;
    resultado = 0;
  }
}
