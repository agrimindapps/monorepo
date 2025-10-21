
class CinturaQuadrilModel {
  final double cintura;
  final double quadril;
  final double rcq;
  final int generoSelecionado;
  final String classificacao;
  final String comentario;

  CinturaQuadrilModel({
    required this.cintura,
    required this.quadril,
    required this.rcq,
    required this.generoSelecionado,
    required this.classificacao,
    required this.comentario,
  });

  // Método para gerar texto de compartilhamento
  String gerarTextoCompartilhamento() {
    final genero = generoSelecionado == 1 ? 'Masculino' : 'Feminino';

    return 'Resultado da Relação Cintura-Quadril (RCQ):\n\n'
        'Cintura: ${cintura.toStringAsFixed(1)} cm\n'
        'Quadril: ${quadril.toStringAsFixed(1)} cm\n'
        'Gênero: $genero\n'
        'RCQ: ${rcq.toStringAsFixed(2)}\n'
        'Classificação: $classificacao\n\n'
        'Observação: $comentario\n\n'
        'Calculado com o app NutriTuti';
  }
}
