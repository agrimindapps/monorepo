// Project imports:
import '../../../../models/medicoes_models.dart';
import '../widgets/pluviometria_models.dart';

/// Interface para estratégias de visualização
abstract class IVisualizationStrategy {
  /// Processa dados para o tipo de visualização específico
  List<DadoPluviometrico> processarDados(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  );

  /// Calcula estatísticas para o tipo de visualização
  EstatisticasPluviometria calcularEstatisticas(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  );

  /// Gera título para o tipo de visualização
  String gerarTitulo(int ano, int mes);

  /// Retorna o tipo de visualização
  String get tipoVisualizacao;
}

/// Estratégia para visualização anual
class AnualVisualizationStrategy implements IVisualizationStrategy {
  @override
  String get tipoVisualizacao => 'Ano';

  @override
  List<DadoPluviometrico> processarDados(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  ) {
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

  @override
  EstatisticasPluviometria calcularEstatisticas(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  ) {
    final medicoesRelevantes = medicoes.where((medicao) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      return data.year == ano;
    }).toList();

    if (medicoesRelevantes.isEmpty) {
      return EstatisticasPluviometria();
    }

    double total =
        medicoesRelevantes.fold(0, (sum, medicao) => sum + medicao.quantidade);

    final datasPorDia = <String, double>{};
    for (var medicao in medicoesRelevantes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      final chave = '${data.year}-${data.month}-${data.day}';
      datasPorDia[chave] = (datasPorDia[chave] ?? 0) + medicao.quantidade;
    }

    int diasComChuva =
        datasPorDia.values.where((quantidade) => quantidade > 0).length;
    double maximo = datasPorDia.values.isNotEmpty
        ? datasPorDia.values.reduce((a, b) => a > b ? a : b)
        : 0;

    final mesesComDados = datasPorDia.keys
        .map((key) => key.split('-').take(2).join('-'))
        .toSet()
        .length;
    double media = mesesComDados > 0 ? total / mesesComDados : 0;

    return EstatisticasPluviometria(
      total: total,
      media: media,
      maximo: maximo,
      diasComChuva: diasComChuva,
    );
  }

  @override
  String gerarTitulo(int ano, int mes) {
    return 'Análise Anual de $ano';
  }
}

/// Estratégia para visualização mensal
class MensalVisualizationStrategy implements IVisualizationStrategy {
  @override
  String get tipoVisualizacao => 'Mes';

  @override
  List<DadoPluviometrico> processarDados(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  ) {
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

  @override
  EstatisticasPluviometria calcularEstatisticas(
    List<Medicoes> medicoes,
    int ano,
    int mes,
  ) {
    final medicoesRelevantes = medicoes.where((medicao) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      return data.year == ano && data.month == mes;
    }).toList();

    if (medicoesRelevantes.isEmpty) {
      return EstatisticasPluviometria();
    }

    double total =
        medicoesRelevantes.fold(0, (sum, medicao) => sum + medicao.quantidade);

    final datasPorDia = <String, double>{};
    for (var medicao in medicoesRelevantes) {
      final data = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      final chave = '${data.year}-${data.month}-${data.day}';
      datasPorDia[chave] = (datasPorDia[chave] ?? 0) + medicao.quantidade;
    }

    int diasComChuva =
        datasPorDia.values.where((quantidade) => quantidade > 0).length;
    double maximo = datasPorDia.values.isNotEmpty
        ? datasPorDia.values.reduce((a, b) => a > b ? a : b)
        : 0;

    final diasNoMes = DateTime(ano, mes + 1, 0).day;
    double media = total / diasNoMes;

    return EstatisticasPluviometria(
      total: total,
      media: media,
      maximo: maximo,
      diasComChuva: diasComChuva,
    );
  }

  @override
  String gerarTitulo(int ano, int mes) {
    const mesesCompletos = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    final nomeMes =
        mes >= 1 && mes <= 12 ? mesesCompletos[mes - 1] : 'Mês $mes';
    return 'Análise de $nomeMes de $ano';
  }
}

/// Factory para estratégias de visualização
class VisualizationStrategyFactory {
  static IVisualizationStrategy createStrategy(String tipoVisualizacao) {
    switch (tipoVisualizacao) {
      case 'Ano':
        return AnualVisualizationStrategy();
      case 'Mes':
        return MensalVisualizationStrategy();
      default:
        return AnualVisualizationStrategy(); // Padrão
    }
  }
}
