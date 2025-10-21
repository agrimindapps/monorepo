// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/vista_vs_parcelado/controllers/models/vista_vs_parcelado_model.dart';

class VistaVsParceladoController extends ChangeNotifier {
  final model = VistaVsParceladoModel();
  final valorVistaController = TextEditingController();
  final valorParceladoController = TextEditingController();
  final numeroParcelasController = TextEditingController();
  final taxaJurosController = TextEditingController();

  final valorVistaFocus = FocusNode();
  final valorParceladoFocus = FocusNode();
  final numeroParcelasFocus = FocusNode();
  final taxaJurosFocus = FocusNode();

  VistaVsParceladoController() {
    _inicializarControllers();
  }

  void _inicializarControllers() {
    numeroParcelasController.text = '12';
    taxaJurosController.text = '0,8';
  }

  @override
  void dispose() {
    valorVistaController.dispose();
    valorParceladoController.dispose();
    numeroParcelasController.dispose();
    taxaJurosController.dispose();
    valorVistaFocus.dispose();
    valorParceladoFocus.dispose();
    numeroParcelasFocus.dispose();
    taxaJurosFocus.dispose();
  }

  double _converterMoedaParaDouble(String valor) {
    String valorLimpo = valor
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(valorLimpo) ?? 0;
  }

  double _converterPercentualParaDouble(String valor) {
    String valorLimpo = valor
        .replaceAll('%', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(valorLimpo) ?? 0;
  }

  String? calcular(BuildContext context) {
    model.valorVista = _converterMoedaParaDouble(valorVistaController.text);
    model.valorParcelado =
        _converterMoedaParaDouble(valorParceladoController.text);
    model.numeroParcelas = int.tryParse(numeroParcelasController.text) ?? 0;
    model.taxaJuros = _converterPercentualParaDouble(taxaJurosController.text);

    if (!model.validarCampos()) {
      return 'Verifique os valores informados';
    }

    try {
      _realizarCalculos();
      model.resultadoVisivel = true;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro no cálculo. Verifique os valores informados.';
    }
  }

  void _realizarCalculos() {
    double valorTotalParcelado = model.valorParcelado! * model.numeroParcelas;
    _calcularTaxaImplicita(valorTotalParcelado);
    _calcularValorPresente(valorTotalParcelado);
  }

  void _calcularTaxaImplicita(double valorTotalParcelado) {
    try {
      if (valorTotalParcelado > model.valorVista!) {
        model.taxaImplicita = math.pow(valorTotalParcelado / model.valorVista!,
                1 / model.numeroParcelas) -
            1;

        if (model.taxaImplicita.isNaN ||
            model.taxaImplicita.isInfinite ||
            model.taxaImplicita > 1) {
          model.taxaImplicita = math.min(
              1.0,
              math.max(0.0,
                  (model.taxaImplicita.isFinite ? model.taxaImplicita : 0)));
        }
      } else {
        model.taxaImplicita = math.pow(valorTotalParcelado / model.valorVista!,
                1 / model.numeroParcelas) -
            1;

        if (model.taxaImplicita.isNaN ||
            model.taxaImplicita.isInfinite ||
            model.taxaImplicita < -1) {
          model.taxaImplicita = math.max(
              -0.5,
              math.min(0.0,
                  (model.taxaImplicita.isFinite ? model.taxaImplicita : 0)));
        }
      }
    } catch (e) {
      model.taxaImplicita = 0;
    }
  }

  void _calcularValorPresente(double valorTotalParcelado) {
    double valorPresenteParcelas = 0;
    double valorParcela = model.valorParcelado!;
    double taxaJuros = model.taxaJuros / 100;

    if (taxaJuros == 0) {
      valorPresenteParcelas = valorTotalParcelado;
    } else {
      for (int i = 1; i <= model.numeroParcelas; i++) {
        double fatorDesconto = math.pow(1 + taxaJuros, i) as double;
        if (fatorDesconto.isFinite && fatorDesconto > 0) {
          valorPresenteParcelas += valorParcela / fatorDesconto;
        } else {
          valorPresenteParcelas += valorParcela;
        }
      }
    }

    if (valorPresenteParcelas < model.valorVista!) {
      model.melhorOpcao = 'Parcelado';
      model.economiaOuCustoAdicional =
          model.valorVista! - valorPresenteParcelas;
    } else {
      model.melhorOpcao = 'À Vista';
      model.economiaOuCustoAdicional =
          valorPresenteParcelas - model.valorVista!;
    }

    model.detalhesCalculo =
        _gerarDetalhesCalculo(valorTotalParcelado, valorPresenteParcelas);
  }

  String _gerarDetalhesCalculo(
      double valorTotalParcelado, double valorPresenteParcelas) {
    return 'Valor total parcelado: ${VistaVsParceladoModel.formatadorMoeda.format(valorTotalParcelado)}\n'
        'Valor presente das parcelas: ${VistaVsParceladoModel.formatadorMoeda.format(valorPresenteParcelas)}\n'
        "Taxa implícita do parcelamento: ${VistaVsParceladoModel.formatadorPercentual.format(model.taxaImplicita.abs())}${model.taxaImplicita < 0 ? ' (desconto)' : ''}/mês";
  }

  void limparCampos() {
    valorVistaController.clear();
    valorParceladoController.clear();
    numeroParcelasController.text = '12';
    taxaJurosController.text = '0,8';
    model.resultadoVisivel = false;
    notifyListeners();
  }

  Future<void> compartilhar() async {
    if (!model.resultadoVisivel) {
      String? erro = calcular(null as BuildContext);
      if (erro != null) return;
    }

    final valores = model.getValoresFormatados();

    String textoCompartilhamento = '''
📊 COMPARAÇÃO: COMPRA À VISTA vs PARCELADO 📊

💰 Valor à vista: ${valores['valorVista']}
💳 Valor da parcela: ${valores['valorParcelado']}
🔢 Número de parcelas: ${valores['numeroParcelas']}
💲 Valor total parcelado: ${VistaVsParceladoModel.formatadorMoeda.format(model.valorParcelado! * model.numeroParcelas)}
📈 Taxa de juros mensal: ${valores['taxaJuros']}

✅ RESULTADO:
👉 Melhor opção: ${model.melhorOpcao}
💵 Economia: ${valores['economiaOuCustoAdicional']}
🔄 Taxa implícita do parcelamento: ${valores['taxaImplicita']}

📝 DETALHES DO CÁLCULO:
${model.detalhesCalculo}

📱 Calculado com app FinCalc''';

    await Share.share(textoCompartilhamento,
        subject: 'Comparação: Compra à Vista vs Parcelado');
  }
}
