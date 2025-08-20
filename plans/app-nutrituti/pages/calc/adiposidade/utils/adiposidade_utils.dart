// Dart imports:
import 'dart:math';

// Project imports:
import '../model/index.dart';

class AdipososidadeUtils {
  // Calcula o Índice de Adiposidade Corporal (IAC)
  static double calcularIAC(double quadril, double alturaCm) {
    // Conversão de cm para m para altura
    final alturaM = alturaCm / 100;

    // Fórmula: IAC = (circunferência quadril / altura^1.5) - 18
    final iac = (quadril / (pow(alturaM, 1.5))) - 18;

    // Arredondar para uma casa decimal usando formatação consistente
    return _roundToDecimal(iac, 1);
  }

  // Obtém a classificação baseada no IAC e gênero
  static String obterClassificacao(double iac, int genero) {
    final bool isMale = genero == 1;

    if (isMale) {
      // Classificação para homens
      if (iac < 8) {
        return 'Adiposidade essencial';
      } else if (iac >= 8 && iac < 21) {
        return 'Adiposidade saudável';
      } else if (iac >= 21 && iac < 26) {
        return 'Sobrepeso';
      } else {
        return 'Obesidade';
      }
    } else {
      // Classificação para mulheres
      if (iac < 21) {
        return 'Adiposidade essencial';
      } else if (iac >= 21 && iac < 33) {
        return 'Adiposidade saudável';
      } else if (iac >= 33 && iac < 39) {
        return 'Sobrepeso';
      } else {
        return 'Obesidade';
      }
    }
  }

  // Obtém comentário baseado na classificação
  static String obterComentario(String classificacao) {
    switch (classificacao) {
      case 'Adiposidade essencial':
        return 'Seu nível de gordura corporal está muito baixo. A gordura essencial é necessária para funções corporais básicas e saúde hormonal. Considere consultar um profissional de saúde.';
      case 'Adiposidade saudável':
        return 'Parabéns! Seu nível de adiposidade está dentro da faixa considerada saudável para seu gênero e idade.';
      case 'Sobrepeso':
        return 'Seu índice indica um nível de gordura corporal acima do recomendado. Considere ajustes na alimentação e prática regular de atividade física.';
      case 'Obesidade':
        return 'Seu índice indica níveis elevados de gordura corporal, o que pode aumentar riscos à saúde. Recomenda-se consultar um profissional de saúde para orientações específicas.';
      default:
        return '';
    }
  }

  // Gera uma string formatada para compartilhamento
  static String gerarTextoCompartilhamento(AdipososidadeModel modelo) {
    StringBuffer t = StringBuffer();
    t.writeln('Índice de Adiposidade Corporal (IAC)');
    t.writeln();
    t.writeln('Dados Pessoais');
    t.writeln(
        'Gênero: ${modelo.generoSelecionado == 1 ? 'Masculino' : 'Feminino'}');
    t.writeln('Altura: ${modelo.altura} cm');
    t.writeln('Circunferência do quadril: ${modelo.quadril} cm');
    t.writeln('Idade: ${modelo.idade} anos');
    t.writeln();
    t.writeln('Resultados');
    t.writeln('Índice de Adiposidade Corporal (IAC): ${modelo.iac}');
    t.writeln('Classificação: ${modelo.classificacao}');
    t.writeln();
    t.writeln('Comentário');
    t.writeln(modelo.comentario);
    t.writeln();
    t.writeln(
        'Observação: O IAC é uma alternativa ao IMC para estimar a porcentagem de gordura corporal, especialmente útil quando não é possível medir o peso corporal.');

    return t.toString();
  }

  // Função helper para arredondar decimais de forma consistente
  static double _roundToDecimal(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }
}
