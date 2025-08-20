// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/hidratacao_fluidoterapia_model.dart';

class HidratacaoFluidoterapiaController extends ChangeNotifier {
  HidratacaoFluidoterapiaModel? _resultado;
  bool _showInfoCard = true;

  bool get showInfoCard => _showInfoCard;
  HidratacaoFluidoterapiaModel? get resultado => _resultado;

  void toggleInfoCard() {
    _showInfoCard = !_showInfoCard;
    notifyListeners();
  }

  void limpar() {
    _resultado = null;
    notifyListeners();
  }

  void calcular({
    required double peso,
    required double percentualDesidratacao,
    required double perdaCorrente24h,
    required double temperaturaCorporal,
    required String especieSelecionada,
    required String tipoSolucaoSelecionado,
    required String viaAdministracaoSelecionada,
    required String condicaoClinicaSelecionada,
  }) {
    // Fator de correção por temperatura (hipertermia aumenta necessidades)
    double fatorTemperatura = 1.0;
    if (temperaturaCorporal > 39.0) {
      fatorTemperatura = 1.0 + ((temperaturaCorporal - 39.0) * 0.1);
    }

    // 1. Cálculo do déficit de hidratação (desidratação)
    final volumeDesidratacao = peso * (percentualDesidratacao / 100) * 1000;

    // 2. Cálculo da manutenção diária
    double manutencaoDiaria = 0.0;
    if (HidratacaoFluidoterapiaModel.fatoresManutencao
        .containsKey(especieSelecionada)) {
      final fatorBase =
          HidratacaoFluidoterapiaModel.fatoresManutencao[especieSelecionada]!;
      manutencaoDiaria = peso * fatorBase * fatorTemperatura;
    }

    // 3. Contabilizar perdas correntes
    final perdaCorrente = perdaCorrente24h;

    // 4. Cálculo do volume total diário
    var volumeTotalDia = volumeDesidratacao + manutencaoDiaria + perdaCorrente;

    // 5. Aplicar ajuste conforme condição clínica
    if (HidratacaoFluidoterapiaModel.correcaoCondicaoClinica
        .containsKey(condicaoClinicaSelecionada)) {
      volumeTotalDia *= HidratacaoFluidoterapiaModel
          .correcaoCondicaoClinica[condicaoClinicaSelecionada]!;
    }

    // Criar modelo inicial
    _resultado = HidratacaoFluidoterapiaModel(
      peso: peso,
      percentualDesidratacao: percentualDesidratacao,
      perdaCorrente24h: perdaCorrente24h,
      temperaturaCorporal: temperaturaCorporal,
      especieSelecionada: especieSelecionada,
      tipoSolucaoSelecionado: tipoSolucaoSelecionado,
      viaAdministracaoSelecionada: viaAdministracaoSelecionada,
      condicaoClinicaSelecionada: condicaoClinicaSelecionada,
      volumeDesidratacao: volumeDesidratacao,
      manutencaoDiaria: manutencaoDiaria,
      perdaCorrente: perdaCorrente,
      volumeTotalDia: volumeTotalDia,
    );

    // Calcular taxa de infusão e distribuição
    _calcularTaxaEDistribuicao();

    // Gerar recomendações
    _gerarRecomendacoes();

    notifyListeners();
  }

  void _calcularTaxaEDistribuicao() {
    if (_resultado == null) return;

    double? taxaInfusao;
    Map<String, double> distribuicaoHoraria = {};

    // Implementar lógica de cálculo de taxa e distribuição
    // ...

    _resultado = _resultado!.copyWith(
      taxaInfusao: taxaInfusao,
      distribuicaoHoraria: distribuicaoHoraria,
    );
  }

  void _gerarRecomendacoes() {
    if (_resultado == null) return;

    Map<String, String> recomendacoes = {};

    // Implementar lógica de geração de recomendações
    // ...

    _resultado = _resultado!.copyWith(
      recomendacoes: recomendacoes,
    );
  }

  // Validações
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value.replaceAll(',', '.')) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  String? validateDesidratacao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Digite um número válido';
    }
    final percent = double.parse(value.replaceAll(',', '.'));
    if (percent < 0 || percent > 15) {
      return 'O percentual deve estar entre 0 e 15';
    }
    return null;
  }
}
