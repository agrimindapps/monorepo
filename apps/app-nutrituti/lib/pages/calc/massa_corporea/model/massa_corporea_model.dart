class MassaCorporeaModel {
  double altura = 0;
  double peso = 0;
  double resultado = 0;
  String textIMC = '';
  bool calculado = false;
  int generoSelecionado = 1;

  final List<Map<String, dynamic>> generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];

  void limpar() {
    generoSelecionado = 1;
    peso = 0;
    altura = 0;
    resultado = 0;
    textIMC = '';
    calculado = false;
  }
}
