// Modelo de dados e lógica de cálculo de gordura corporal

// Dart imports:
import 'dart:math' as math;

class GorduraCorporeaModel {
  final int generoId;
  final String genero;
  final int idade;
  final double altura;
  final double peso;
  final double cintura;
  final double pescoco;
  final double? quadril;

  double? resultado;
  String classificacao = '';

  GorduraCorporeaModel({
    required this.generoId,
    required this.genero,
    required this.idade,
    required this.altura,
    required this.peso,
    required this.cintura,
    required this.pescoco,
    this.quadril,
    this.resultado,
    this.classificacao = '',
  });

  void calcular() {
    if (generoId == 1) {
      resultado = 86.010 * math.log(cintura - pescoco) / math.log(10) -
          70.041 * math.log(altura) / math.log(10) +
          36.76;
    } else {
      if (quadril == null) {
        throw Exception('Quadril é obrigatório para o cálculo feminino');
      }
      resultado =
          163.205 * math.log(cintura + quadril! - pescoco) / math.log(10) -
              97.684 * math.log(altura) / math.log(10) -
              78.387;
    }
    resultado = double.parse(resultado!.toStringAsFixed(2));
    classificacao = obterClassificacao(resultado!, generoId);
  }

  static String obterClassificacao(double percentual, int generoId) {
    if (generoId == 1) {
      if (percentual < 6) return 'Essencial';
      if (percentual < 14) return 'Atlético';
      if (percentual < 18) return 'Fitness';
      if (percentual < 25) return 'Aceitável';
      return 'Obesidade';
    } else {
      if (percentual < 14) return 'Essencial';
      if (percentual < 21) return 'Atlético';
      if (percentual < 25) return 'Fitness';
      if (percentual < 32) return 'Aceitável';
      return 'Obesidade';
    }
  }

  Map<String, String> get classificacaoRanges {
    if (generoId == 1) {
      return {
        'Essencial': '2-5%',
        'Atlético': '6-13%',
        'Fitness': '14-17%',
        'Aceitável': '18-24%',
        'Obesidade': '25% ou mais',
      };
    } else {
      return {
        'Essencial': '10-13%',
        'Atlético': '14-20%',
        'Fitness': '21-24%',
        'Aceitável': '25-31%',
        'Obesidade': '32% ou mais',
      };
    }
  }
}
