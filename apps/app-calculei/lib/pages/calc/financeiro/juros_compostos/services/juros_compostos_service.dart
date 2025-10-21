// Dart imports:
import 'dart:math' as math;

/// Resultado dos cálculos de juros compostos
class JurosCompostosResult {
  final double montanteFinal;
  final double totalInvestido;
  final double totalJuros;
  final double rendimentoTotal;
  final bool isValid;
  final String? errorMessage;

  const JurosCompostosResult({
    required this.montanteFinal,
    required this.totalInvestido,
    required this.totalJuros,
    required this.rendimentoTotal,
    this.isValid = true,
    this.errorMessage,
  });

  factory JurosCompostosResult.error(String message) {
    return JurosCompostosResult(
      montanteFinal: 0,
      totalInvestido: 0,
      totalJuros: 0,
      rendimentoTotal: 0,
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Parâmetros para cálculo de juros compostos
class JurosCompostosParams {
  final double capitalInicial;
  final double taxaJuros; // Em decimal (ex: 0.01 para 1%)
  final int periodo; // Em meses
  final double aporteMensal;

  const JurosCompostosParams({
    required this.capitalInicial,
    required this.taxaJuros,
    required this.periodo,
    required this.aporteMensal,
  });
}

/// Service responsável pelos cálculos de juros compostos
class JurosCompostosService {
  /// Calcula juros compostos com validações robustas
  static JurosCompostosResult calcular(JurosCompostosParams params) {
    try {
      // Validações matemáticas básicas
      final validationResult = _validarParametros(params);
      if (!validationResult.isValid) {
        return validationResult;
      }

      // Extração de variáveis para cálculo
      final double p = params.capitalInicial;
      final double i = params.taxaJuros;
      final int n = params.periodo;
      final double pmt = params.aporteMensal;

      // Cálculo específico baseado na taxa
      if (i == 0) {
        return _calcularSemJuros(p, pmt, n);
      } else {
        return _calcularComJuros(p, i, n, pmt);
      }
    } catch (e) {
      return JurosCompostosResult.error('Erro no cálculo: ${e.toString()}');
    }
  }

  /// Valida os parâmetros de entrada
  static JurosCompostosResult _validarParametros(JurosCompostosParams params) {
    // Validação de valores básicos
    if (params.capitalInicial == 0 && params.aporteMensal == 0) {
      return JurosCompostosResult.error(
          'Capital inicial ou aporte mensal deve ser maior que zero');
    }

    // Verificação de overflow potencial para taxas altas
    if (params.taxaJuros > 0.5) {
      // Mais de 50% ao mês
      double testOverflow =
          math.pow(1 + params.taxaJuros, params.periodo).toDouble();
      if (testOverflow.isInfinite || testOverflow.isNaN) {
        return JurosCompostosResult.error(
            'Combinação de taxa e período resulta em overflow matemático');
      }
    }
    return const JurosCompostosResult(
      montanteFinal: 0,
      totalInvestido: 0,
      totalJuros: 0,
      rendimentoTotal: 0,
      isValid: true,
    );
  }

  /// Calcula juros compostos sem taxa de juros (cenário linear)
  static JurosCompostosResult _calcularSemJuros(double p, double pmt, int n) {
    final double montanteFinal = p + (pmt * n);
    final double totalInvestido = p + (pmt * n);
    const double totalJuros = 0;
    const double rendimentoTotal = 0;

    return JurosCompostosResult(
      montanteFinal: montanteFinal,
      totalInvestido: totalInvestido,
      totalJuros: totalJuros,
      rendimentoTotal: rendimentoTotal,
    );
  }

  /// Calcula juros compostos com taxa de juros
  static JurosCompostosResult _calcularComJuros(
      double p, double i, int n, double pmt) {
    // Fórmula: M = P(1+i)^n + PMT[((1+i)^n-1)/i]
    final double fatorJuros = math.pow(1 + i, n).toDouble();

    // Verificação de resultados válidos
    if (fatorJuros.isInfinite || fatorJuros.isNaN) {
      return JurosCompostosResult.error(
          'Resultado matemático inválido - verifique taxa e período');
    }

    final double montanteFinal = p * fatorJuros + pmt * (fatorJuros - 1) / i;

    // Verificação de resultado final
    if (montanteFinal.isInfinite || montanteFinal.isNaN || montanteFinal < 0) {
      return JurosCompostosResult.error(
          'Resultado inválido - verifique os valores inseridos');
    }

    final double totalInvestido = p + (pmt * n);
    final double totalJuros = montanteFinal - totalInvestido;
    final double rendimentoTotal =
        totalInvestido > 0 ? (totalJuros / totalInvestido) * 100 : 0;

    return JurosCompostosResult(
      montanteFinal: montanteFinal,
      totalInvestido: totalInvestido,
      totalJuros: totalJuros,
      rendimentoTotal: rendimentoTotal,
    );
  }

  /// Calcula valor presente dado um valor futuro
  static double calcularValorPresente({
    required double valorFuturo,
    required double taxaJuros,
    required int periodo,
  }) {
    if (taxaJuros == 0) return valorFuturo;
    return valorFuturo / math.pow(1 + taxaJuros, periodo);
  }

  /// Calcula taxa de juros necessária para atingir um objetivo
  static double calcularTaxaNecessaria({
    required double capitalInicial,
    required double valorFuturo,
    required int periodo,
  }) {
    if (periodo == 0 || capitalInicial == 0) return 0;
    return math.pow(valorFuturo / capitalInicial, 1 / periodo) - 1;
  }

  /// Calcula período necessário para atingir um objetivo
  static int calcularPeriodoNecessario({
    required double capitalInicial,
    required double valorFuturo,
    required double taxaJuros,
  }) {
    if (taxaJuros == 0 || capitalInicial == 0) return 0;
    return (math.log(valorFuturo / capitalInicial) / math.log(1 + taxaJuros))
        .ceil();
  }

  /// Simula evolução mensal do investimento
  static List<Map<String, double>> simularEvolucaoMensal(
      JurosCompostosParams params) {
    final List<Map<String, double>> evolucao = [];
    double saldoAtual = params.capitalInicial;
    double totalInvestido = params.capitalInicial;

    for (int mes = 1; mes <= params.periodo; mes++) {
      // Aplica juros ao saldo atual
      saldoAtual = saldoAtual * (1 + params.taxaJuros);

      // Adiciona aporte mensal
      saldoAtual += params.aporteMensal;
      totalInvestido += params.aporteMensal;

      evolucao.add({
        'mes': mes.toDouble(),
        'saldo': saldoAtual,
        'totalInvestido': totalInvestido,
        'jurosAcumulados': saldoAtual - totalInvestido,
      });
    }

    return evolucao;
  }
}
