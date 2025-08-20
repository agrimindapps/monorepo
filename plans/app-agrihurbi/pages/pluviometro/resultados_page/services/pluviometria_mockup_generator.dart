// Dart imports:
import 'dart:math';

// Project imports:
import '../widgets/pluviometria_models.dart';

/// Gerador de dados mockup para testes e desenvolvimento
class PluviometriaMockupGenerator {
  static final Random _random = Random();

  /// Gera dados mockup para visualização anual
  static List<DadoPluviometrico> gerarDadosMockupAnual() {
    return List.generate(12, (index) {
      double valorBase;
      if (index < 3 || index > 9) {
        // Verão no hemisfério sul
        valorBase = 80 + _random.nextDouble() * 60;
      } else if (index >= 5 && index <= 7) {
        // Inverno
        valorBase = 10 + _random.nextDouble() * 30;
      } else {
        // Primavera e outono
        valorBase = 30 + _random.nextDouble() * 50;
      }

      return DadoPluviometrico(mesesAbreviados[index], valorBase);
    });
  }

  /// Gera dados mockup para visualização mensal
  static List<DadoPluviometrico> gerarDadosMockupMensal(int ano, int mes) {
    final diasNoMes = DateTime(ano, mes + 1, 0).day;

    // Simular padrões de chuva (chuvas consecutivas e períodos secos)
    bool estaChovendo = _random.nextBool();
    int diasConsecutivos = 1;

    return List.generate(diasNoMes, (index) {
      // A cada 3-5 dias, muda o padrão
      if (diasConsecutivos > 2 + _random.nextInt(3)) {
        estaChovendo = !estaChovendo;
        diasConsecutivos = 1;
      } else {
        diasConsecutivos++;
      }

      double valor;
      if (estaChovendo) {
        valor = 5 + _random.nextDouble() * 25; // Dia com chuva
      } else {
        valor = _random.nextDouble() < 0.2
            ? 0.1 + _random.nextDouble() * 3
            : 0; // Dia sem chuva ou com garoa
      }

      return DadoPluviometrico('${index + 1}', valor);
    });
  }

  /// Gera dados comparativos mockup
  static List<DadoComparativo> gerarDadosComparativosMockup(
      String tipoVisualizacao, int ano, int mesSelecionado) {
    // Determinar quais meses exibir
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

    return mesesIndices.map((mesIndex) {
      double valorBase = 30 + _random.nextDouble() * 100;

      // Adicionar variação sazonal
      if (mesIndex < 3 || mesIndex > 9) {
        // Verão no hemisfério sul
        valorBase += 40;
      } else if (mesIndex >= 5 && mesIndex <= 7) {
        // Inverno
        valorBase -= 20;
      }

      // Aplicar variações aleatórias para cada ano
      double valorAnterior = valorBase * (0.7 + _random.nextDouble() * 0.6);
      double valorAtual = valorBase * (0.7 + _random.nextDouble() * 0.6);

      return DadoComparativo(
          mesesAbreviados[mesIndex], valorAtual, valorAnterior);
    }).toList();
  }

  /// Gera estatísticas mockup baseadas nos dados gerados
  static EstatisticasPluviometria gerarEstatisticasMockup(
      String tipoVisualizacao, int ano, int mes) {
    final dados = tipoVisualizacao == 'Ano'
        ? gerarDadosMockupAnual()
        : gerarDadosMockupMensal(ano, mes);

    double total = dados.fold(0, (sum, item) => sum + item.valor);
    double media = total / dados.length;
    double maximo = dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
    int diasChuva = dados.where((d) => d.valor > 0).length;

    return EstatisticasPluviometria(
      total: total,
      media: media,
      maximo: maximo,
      diasComChuva: diasChuva,
    );
  }
}
