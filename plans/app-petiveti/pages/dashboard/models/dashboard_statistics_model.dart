// Project imports:
import 'dashboard_data_model.dart';

class DashboardStatistics {
  final int totalConsultas;
  final int diasProximaConsulta;
  final int vacinasPendentes;
  final int indiceSaude;
  final Map<String, double> saudeMetrics;

  const DashboardStatistics({
    required this.totalConsultas,
    required this.diasProximaConsulta,
    required this.vacinasPendentes,
    required this.indiceSaude,
    required this.saudeMetrics,
  });

  static DashboardStatistics fromData({
    required List<ConsultaData> consultas,
    required List<VacinaData> vacinas,
    required List<MedicamentoData> medicamentos,
  }) {
    // Calcular consultas do ano atual
    final anoAtual = DateTime.now().year;
    final consultasAnoAtual = consultas
        .where((c) => c.data.year == anoAtual)
        .length;

    // Calcular dias para próxima consulta (mockup)
    const diasProxConsulta = 12;

    // Calcular vacinas pendentes
    final vacinasPendentes = vacinas
        .where((v) => v.isPendente)
        .length;

    // Calcular métricas de saúde (mockup)
    const saudeMetrics = {
      'Alimentação': 90.0,
      'Atividade Física': 75.0,
      'Medicamentos': 100.0,
      'Vacinas': 70.0,
    };

    // Calcular índice geral de saúde
    final indiceSaude = saudeMetrics.values
        .reduce((a, b) => a + b) ~/ saudeMetrics.length;

    return DashboardStatistics(
      totalConsultas: consultasAnoAtual,
      diasProximaConsulta: diasProxConsulta,
      vacinasPendentes: vacinasPendentes,
      indiceSaude: indiceSaude,
      saudeMetrics: saudeMetrics,
    );
  }
}

class ExpensesByCategory {
  final Map<String, double> categorias;
  final double total;

  const ExpensesByCategory({
    required this.categorias,
    required this.total,
  });

  static ExpensesByCategory fromDespesas(List<DespesaData> despesas) {
    final Map<String, double> categorias = {};
    
    for (var despesa in despesas) {
      categorias[despesa.categoria] = 
          (categorias[despesa.categoria] ?? 0) + despesa.valor;
    }

    final total = categorias.values.fold(0.0, (a, b) => a + b);

    return ExpensesByCategory(
      categorias: categorias,
      total: total,
    );
  }

  int getPercentage(String categoria) {
    final valor = categorias[categoria] ?? 0;
    return total > 0 ? (valor / total * 100).round() : 0;
  }
}
