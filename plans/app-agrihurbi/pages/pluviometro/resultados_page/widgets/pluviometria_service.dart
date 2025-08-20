// Project imports:
import '../../../../models/medicoes_models.dart';
import '../services/pluviometria_mockup_generator.dart';
import '../services/pluviometria_processor.dart';
import '../services/pluviometria_statistics_calculator.dart';
import 'pluviometria_models.dart';

/// Serviço facade para processar dados de pluviometria
/// Mantém compatibilidade com o código existente enquanto delega para classes especializadas
class PluviometriaService {
  /// Processa os dados para exibição anual
  static List<DadoPluviometrico> processarDadosAnuais(
      List<Medicoes> medicoes, int ano) {
    if (medicoes.isEmpty) {
      return PluviometriaMockupGenerator.gerarDadosMockupAnual();
    }

    return PluviometriaProcessor.processarDadosAnuais(medicoes, ano);
  }

  /// Processa os dados para exibição mensal
  static List<DadoPluviometrico> processarDadosMensais(
      List<Medicoes> medicoes, int ano, int mes) {
    if (medicoes.isEmpty) {
      return PluviometriaMockupGenerator.gerarDadosMockupMensal(ano, mes);
    }

    return PluviometriaProcessor.processarDadosMensais(medicoes, ano, mes);
  }

  /// Processa os dados comparativos entre o ano atual e o anterior
  static List<DadoComparativo> processarDadosComparativos(
      List<Medicoes> medicoes,
      int ano,
      String tipoVisualizacao,
      int mesSelecionado) {
    if (medicoes.isEmpty) {
      return PluviometriaMockupGenerator.gerarDadosComparativosMockup(
          tipoVisualizacao, ano, mesSelecionado);
    }

    return PluviometriaProcessor.processarDadosComparativos(
        medicoes, ano, tipoVisualizacao, mesSelecionado);
  }

  /// Calcula estatísticas com base nos dados reais
  static EstatisticasPluviometria calcularEstatisticas(
      List<Medicoes> medicoes, String tipoVisualizacao, int ano, int mes) {
    if (medicoes.isEmpty) {
      return PluviometriaMockupGenerator.gerarEstatisticasMockup(
          tipoVisualizacao, ano, mes);
    }

    return PluviometriaStatisticsCalculator.calcularEstatisticas(
        medicoes, tipoVisualizacao, ano, mes);
  }

  // MÉTODOS AUXILIARES PARA DADOS MOCKUP (mantidos para compatibilidade)

  /// Gera dados mockup para visualização anual
  @Deprecated('Use PluviometriaMockupGenerator.gerarDadosMockupAnual() instead')
  static List<DadoPluviometrico> gerarDadosMockupAnual() {
    return PluviometriaMockupGenerator.gerarDadosMockupAnual();
  }

  /// Gera dados mockup para visualização mensal
  @Deprecated(
      'Use PluviometriaMockupGenerator.gerarDadosMockupMensal() instead')
  static List<DadoPluviometrico> gerarDadosMockupMensal(int ano, int mes) {
    return PluviometriaMockupGenerator.gerarDadosMockupMensal(ano, mes);
  }

  /// Gera dados comparativos mockup
  @Deprecated(
      'Use PluviometriaMockupGenerator.gerarDadosComparativosMockup() instead')
  static List<DadoComparativo> gerarDadosComparativosMockup(
      String tipoVisualizacao, int ano, int mesSelecionado) {
    return PluviometriaMockupGenerator.gerarDadosComparativosMockup(
        tipoVisualizacao, ano, mesSelecionado);
  }
}
