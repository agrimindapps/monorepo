// Project imports:
import '../../../../models/medicoes_models.dart';
import '../widgets/pluviometria_models.dart';
import 'validation_utils.dart';

/// Processador de dados reais de pluviometria
class PluviometriaProcessor {
  /// Processa os dados para exibição anual
  static List<DadoPluviometrico> processarDadosAnuais(
      List<Medicoes> medicoes, int ano) {
    // Validar entrada
    final validationResult = ValidationUtils.validateAndSanitizeInput(
      medicoes: medicoes,
      ano: ano,
      mes: 1, // valor padrão para validação
    );

    if (!validationResult['isValid']) {
      throw InvalidInputException(
        'Dados de entrada inválidos para processamento anual',
        validationResult['errors'],
      );
    }

    final dadosPorMes = List<double>.filled(12, 0.0);

    // Agrupar medições por mês
    for (var medicao in medicoes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      if (data.year == ano) {
        dadosPorMes[data.month - 1] += medicao.quantidade;
      }
    }

    return List.generate(12, (index) {
      return DadoPluviometrico(
          mesesAbreviados[index], dadosPorMes[index].toDouble());
    });
  }

  /// Processa os dados para exibição mensal
  static List<DadoPluviometrico> processarDadosMensais(
      List<Medicoes> medicoes, int ano, int mes) {
    // Validar entrada
    final validationResult = ValidationUtils.validateAndSanitizeInput(
      medicoes: medicoes,
      ano: ano,
      mes: mes,
    );

    if (!validationResult['isValid']) {
      throw InvalidInputException(
        'Dados de entrada inválidos para processamento mensal',
        validationResult['errors'],
      );
    }

    final diasNoMes = DateTime(ano, mes + 1, 0).day;
    final dadosPorDia = List<double>.filled(diasNoMes, 0.0);

    // Agrupar medições por dia
    for (var medicao in medicoes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      if (data.year == ano && data.month == mes) {
        dadosPorDia[data.day - 1] += medicao.quantidade;
      }
    }

    return List.generate(diasNoMes, (index) {
      return DadoPluviometrico('${index + 1}', dadosPorDia[index].toDouble());
    });
  }

  /// Processa os dados comparativos entre o ano atual e o anterior
  static List<DadoComparativo> processarDadosComparativos(
      List<Medicoes> medicoes,
      int ano,
      String tipoVisualizacao,
      int mesSelecionado) {
    // Determinar quais meses exibir com base no tipo de visualização
    final List<int> mesesIndices;
    if (tipoVisualizacao == 'Ano') {
      mesesIndices = List.generate(12, (index) => index);
    } else {
      final mesCentral = mesSelecionado - 1; // Converter para índice base 0
      mesesIndices = [
        (mesCentral - 1 < 0) ? 11 : mesCentral - 1,
        mesCentral,
        (mesCentral + 1 > 11) ? 0 : mesCentral + 1,
      ];
    }

    // Preparar arrays para o ano atual e anterior
    final valoresAnoAtual = List<double>.filled(12, 0.0);
    final valoresAnoAnterior = List<double>.filled(12, 0.0);

    // Processar medições para o ano atual e anterior
    for (var medicao in medicoes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);

      if (data.year == ano) {
        valoresAnoAtual[data.month - 1] += medicao.quantidade;
      } else if (data.year == ano - 1) {
        valoresAnoAnterior[data.month - 1] += medicao.quantidade;
      }
    }

    return mesesIndices.map((mesIndex) {
      return DadoComparativo(
          mesesAbreviados[mesIndex],
          valoresAnoAtual[mesIndex].toDouble(),
          valoresAnoAnterior[mesIndex].toDouble());
    }).toList();
  }

  /// Agrupa medições por período (dia para dados reais)
  static Map<String, double> agruparMedicoesPorPeriodo(
      List<Medicoes> medicoes, int ano, int? mes) {
    final datasPorPeriodo = <String, double>{};

    for (var medicao in medicoes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);

      // Filtrar por ano e mês se especificado
      if (data.year == ano && (mes == null || data.month == mes)) {
        final chave = '${data.year}-${data.month}-${data.day}';
        datasPorPeriodo[chave] =
            (datasPorPeriodo[chave] ?? 0) + medicao.quantidade;
      }
    }

    return datasPorPeriodo;
  }
}
