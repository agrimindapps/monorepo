abstract class RendimentoModel {
  String titulo;
  String descricao;
  double resultado;

  RendimentoModel({
    required this.titulo,
    required this.descricao,
    this.resultado = 0.0,
  });

  double calcularRendimento();
}
