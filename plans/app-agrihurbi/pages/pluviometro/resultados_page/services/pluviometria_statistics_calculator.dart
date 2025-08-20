// Project imports:
import '../../../../models/medicoes_models.dart';
import '../widgets/pluviometria_models.dart';
import 'pluviometria_processor.dart';

/// Calculadora de estatísticas para dados de pluviometria
class PluviometriaStatisticsCalculator {
  /// Calcula estatísticas com base nos dados reais
  static EstatisticasPluviometria calcularEstatisticas(
      List<Medicoes> medicoes, String tipoVisualizacao, int ano, int mes) {
    List<Medicoes> medicoesRelevantes = [];

    if (tipoVisualizacao == 'Ano') {
      medicoesRelevantes = medicoes.where((medicao) {
        final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
        return data.year == ano;
      }).toList();
    } else {
      medicoesRelevantes = medicoes.where((medicao) {
        final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
        return data.year == ano && data.month == mes;
      }).toList();
    }

    if (medicoesRelevantes.isEmpty) {
      return EstatisticasPluviometria();
    }

    // Calcular total
    double total =
        medicoesRelevantes.fold(0, (sum, medicao) => sum + medicao.quantidade);

    // Agrupar por período para calcular outras estatísticas
    final datasPorPeriodo = PluviometriaProcessor.agruparMedicoesPorPeriodo(
        medicoesRelevantes, ano, tipoVisualizacao == 'Ano' ? null : mes);

    // Calcular dias com chuva
    int diasComChuva =
        datasPorPeriodo.values.where((quantidade) => quantidade > 0).length;

    // Calcular máximo
    double maximo = datasPorPeriodo.values.isNotEmpty
        ? datasPorPeriodo.values.reduce((a, b) => a > b ? a : b)
        : 0;

    // Calcular média
    double media =
        _calcularMedia(total, datasPorPeriodo, tipoVisualizacao, ano, mes);

    return EstatisticasPluviometria(
      total: total,
      media: media,
      maximo: maximo,
      diasComChuva: diasComChuva,
    );
  }

  /// Calcula a média baseada no tipo de visualização
  static double _calcularMedia(
      double total,
      Map<String, double> datasPorPeriodo,
      String tipoVisualizacao,
      int ano,
      int mes) {
    if (tipoVisualizacao == 'Ano') {
      final mesesComDados = datasPorPeriodo.keys
          .map((key) => key.split('-').take(2).join('-'))
          .toSet()
          .length;
      return mesesComDados > 0 ? total / mesesComDados : 0;
    } else {
      final diasNoMes = DateTime(ano, mes + 1, 0).day;
      return total / diasNoMes;
    }
  }

  /// Calcula estatísticas comparativas entre dois períodos
  static Map<String, double> calcularEstatisticasComparativas(
      List<Medicoes> medicoes, int anoAtual, int anoAnterior) {
    final medicoesAnoAtual = medicoes.where((m) {
      final data = DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
      return data.year == anoAtual;
    }).toList();

    final medicoesAnoAnterior = medicoes.where((m) {
      final data = DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
      return data.year == anoAnterior;
    }).toList();

    final estatisticasAtual =
        calcularEstatisticas(medicoesAnoAtual, 'Ano', anoAtual, 0);
    final estatisticasAnterior =
        calcularEstatisticas(medicoesAnoAnterior, 'Ano', anoAnterior, 0);

    return {
      'variacao_total': _calcularVariacaoPercentual(
          estatisticasAnterior.total, estatisticasAtual.total),
      'variacao_media': _calcularVariacaoPercentual(
          estatisticasAnterior.media, estatisticasAtual.media),
      'variacao_maximo': _calcularVariacaoPercentual(
          estatisticasAnterior.maximo, estatisticasAtual.maximo),
      'variacao_dias_chuva': _calcularVariacaoPercentual(
          estatisticasAnterior.diasComChuva.toDouble(),
          estatisticasAtual.diasComChuva.toDouble()),
    };
  }

  /// Calcula variação percentual entre dois valores
  static double _calcularVariacaoPercentual(
      double valorAnterior, double valorAtual) {
    if (valorAnterior == 0) {
      return valorAtual > 0 ? 100.0 : 0.0;
    }
    return ((valorAtual - valorAnterior) / valorAnterior) * 100;
  }

  /// Calcula tendência baseada em dados históricos
  static Map<String, dynamic> calcularTendencia(
      List<Medicoes> medicoes, int anoBase) {
    final anosFiltrados = List.generate(3, (index) => anoBase - 2 + index);
    final estatisticasPorAno = <int, EstatisticasPluviometria>{};

    for (final ano in anosFiltrados) {
      final medicoesAno = medicoes.where((m) {
        final data = DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
        return data.year == ano;
      }).toList();

      estatisticasPorAno[ano] =
          calcularEstatisticas(medicoesAno, 'Ano', ano, 0);
    }

    // Calcular tendência linear simples
    final totais = estatisticasPorAno.values.map((e) => e.total).toList();
    final tendencia = _calcularTendenciaLinear(totais);

    return {
      'tendencia_total': tendencia,
      'anos_analisados': anosFiltrados,
      'estatisticas_por_ano': estatisticasPorAno,
    };
  }

  /// Calcula tendência linear simples
  static String _calcularTendenciaLinear(List<double> valores) {
    if (valores.length < 2) return 'insuficiente';

    final primeira = valores.first;
    final ultima = valores.last;

    if (ultima > primeira * 1.1) {
      return 'crescente';
    } else if (ultima < primeira * 0.9) {
      return 'decrescente';
    } else {
      return 'estável';
    }
  }
}
