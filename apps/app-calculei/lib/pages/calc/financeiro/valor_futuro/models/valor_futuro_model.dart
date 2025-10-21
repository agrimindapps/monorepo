// Dart imports:
import 'dart:math';

class ValorFuturoModel {
  double valorInicial = 0;
  double taxa = 0;
  int periodo = 0;
  double valorFuturo = 0;
  double lucro = 0;
  String classificacao = '';
  bool ehAnual = true;
  bool calculado = false;

  void calcular() {
    // Converte taxa anual para mensal se necessário
    double taxaMensal = ehAnual ? taxa / 12 : taxa;

    // Converte período anual para mensal se necessário
    int periodoMeses = ehAnual ? periodo * 12 : periodo;

    // Calcula o valor futuro usando juros compostos
    // VF = VP * (1 + i)^n
    // Onde: VF = Valor Futuro, VP = Valor Presente, i = taxa, n = período
    double taxaDecimal = taxaMensal / 100;
    valorFuturo = valorInicial * pow((1 + taxaDecimal), periodoMeses);
    valorFuturo = double.parse(valorFuturo.toStringAsFixed(2));

    // Calcula o lucro (diferença entre valor futuro e inicial)
    lucro = valorFuturo - valorInicial;

    // Define a classificação do investimento
    _classificarInvestimento();
  }

  void _classificarInvestimento() {
    // Taxa anual equivalente
    double taxaAnual = ehAnual ? taxa : taxa * 12;

    if (taxaAnual >= 15) {
      classificacao = 'Alto Rendimento';
    } else if (taxaAnual >= 10) {
      classificacao = 'Rendimento Moderado';
    } else if (taxaAnual >= 5) {
      classificacao = 'Rendimento Conservador';
    } else {
      classificacao = 'Baixo Rendimento';
    }
  }

  String get periodoFormatado {
    if (ehAnual) {
      return periodo == 1 ? '1 ano' : '$periodo anos';
    } else {
      return periodo == 1 ? '1 mês' : '$periodo meses';
    }
  }

  void limpar() {
    valorInicial = 0;
    taxa = 0;
    periodo = 0;
    valorFuturo = 0;
    lucro = 0;
    classificacao = '';
    ehAnual = true;
    calculado = false;
  }
}
