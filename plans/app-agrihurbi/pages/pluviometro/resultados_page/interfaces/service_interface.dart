// Project imports:
import '../../../../models/medicoes_models.dart';
import '../widgets/pluviometria_models.dart';

/// Interface para processamento de dados
abstract class IPluviometriaProcessor {
  /// Processa dados para exibição anual
  List<DadoPluviometrico> processarDadosAnuais(
      List<Medicoes> medicoes, int ano);

  /// Processa dados para exibição mensal
  List<DadoPluviometrico> processarDadosMensais(
      List<Medicoes> medicoes, int ano, int mes);

  /// Processa dados comparativos
  List<DadoComparativo> processarDadosComparativos(
    List<Medicoes> medicoes,
    int ano,
    String tipoVisualizacao,
    int mesSelecionado,
  );

  /// Agrupa medições por período
  Map<String, double> agruparMedicoesPorPeriodo(
      List<Medicoes> medicoes, int ano, int? mes);
}

/// Interface para geração de dados mockup
abstract class IMockupGenerator {
  /// Gera dados mockup anuais
  List<DadoPluviometrico> gerarDadosMockupAnual();

  /// Gera dados mockup mensais
  List<DadoPluviometrico> gerarDadosMockupMensal(int ano, int mes);

  /// Gera dados comparativos mockup
  List<DadoComparativo> gerarDadosComparativosMockup(
    String tipoVisualizacao,
    int ano,
    int mesSelecionado,
  );

  /// Gera estatísticas mockup
  EstatisticasPluviometria gerarEstatisticasMockup(
      String tipoVisualizacao, int ano, int mes);
}

/// Interface para cálculo de estatísticas
abstract class IStatisticsCalculator {
  /// Calcula estatísticas básicas
  EstatisticasPluviometria calcularEstatisticas(
    List<Medicoes> medicoes,
    String tipoVisualizacao,
    int ano,
    int mes,
  );

  /// Calcula estatísticas comparativas
  Map<String, double> calcularEstatisticasComparativas(
    List<Medicoes> medicoes,
    int anoAtual,
    int anoAnterior,
  );

  /// Calcula tendência
  Map<String, dynamic> calcularTendencia(List<Medicoes> medicoes, int anoBase);
}

/// Interface para validação de dados
abstract class IValidationService {
  /// Valida entrada de dados
  Map<String, dynamic> validateAndSanitizeInput({
    required List<Medicoes> medicoes,
    required int ano,
    required int mes,
    String? tipoVisualizacao,
  });

  /// Valida medição individual
  bool validateMedicao(Medicoes medicao);

  /// Sanitiza string
  String sanitizeString(String input);
}
