// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/controllers/models/custo_efetivo_total_model.dart';

class CustoEfetivoTotalController extends ChangeNotifier {
  final model = CustoEfetivoTotalModel();
  bool resultadoVisivel = false;

  final valorEmprestimoController = TextEditingController();
  final numeroParcelasController = TextEditingController();
  final taxaJurosAnualController = TextEditingController();
  final taxaAdministrativaController = TextEditingController();
  final seguroController = TextEditingController();
  final iofController = TextEditingController();
  final outrasTaxasController = TextEditingController();

  final valorEmprestimoFocus = FocusNode();
  final numeroParcelasFocus = FocusNode();
  final taxaJurosAnualFocus = FocusNode();
  final taxaAdministrativaFocus = FocusNode();
  final seguroFocus = FocusNode();
  final iofFocus = FocusNode();
  final outrasTaxasFocus = FocusNode();

  final _formatadorMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final _formatadorPercentual = NumberFormat.percentPattern('pt_BR');

  CustoEfetivoTotalController() {
    _initializeControllers();
  }

  void _initializeControllers() {
    numeroParcelasController.text = '12';
    taxaJurosAnualController.text = '15,00';
    taxaAdministrativaController.text = '0,00';
    seguroController.text = '0,00';
    iofController.text = '0,38';
    outrasTaxasController.text = '0,00';
  }

  void calcular() {
    if (!_validarCamposObrigatorios()) return;

    _atualizarModeloComValoresDoFormulario();
    model.calcular();
    resultadoVisivel = true;
    notifyListeners();
  }

  bool _validarCamposObrigatorios() {
    if (valorEmprestimoController.text.isEmpty ||
        numeroParcelasController.text.isEmpty ||
        taxaJurosAnualController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _atualizarModeloComValoresDoFormulario() {
    model.valorEmprestimo =
        _converterMoedaParaDouble(valorEmprestimoController.text);
    model.numeroParcelas = int.tryParse(numeroParcelasController.text) ?? 12;
    model.taxaJurosAnual =
        _converterPercentualParaDouble(taxaJurosAnualController.text) / 100;
    model.taxaAdministrativa =
        _converterPercentualParaDouble(taxaAdministrativaController.text) / 100;
    model.seguro = _converterMoedaParaDouble(seguroController.text);
    model.iof = _converterPercentualParaDouble(iofController.text) / 100;
    model.outrasTaxas = _converterMoedaParaDouble(outrasTaxasController.text);
  }

  void limparCampos() {
    valorEmprestimoController.clear();
    _initializeControllers();
    resultadoVisivel = false;
    notifyListeners();
  }

  void compartilhar() {
    if (!resultadoVisivel) {
      calcular();
    }

    if (resultadoVisivel) {
      String textoCompartilhamento = _gerarTextoCompartilhamento();
      Share.share(textoCompartilhamento, subject: 'Simulação de CET');
    }
  }

  String _gerarTextoCompartilhamento() {
    return 'Simulação de Custo Efetivo Total (CET)\n\n'
        'Valor do empréstimo: ${valorEmprestimoController.text}\n'
        'Número de parcelas: ${numeroParcelasController.text}\n'
        'Taxa de juros anual nominal: ${taxaJurosAnualController.text}%\n\n'
        'Custos adicionais:\n'
        'Taxa administrativa: ${taxaAdministrativaController.text}%\n'
        'Seguro: ${seguroController.text}\n'
        'IOF: ${iofController.text}%\n'
        'Outras taxas: ${outrasTaxasController.text}\n\n'
        'Resultados:\n'
        'Valor da parcela: ${_formatadorMoeda.format(model.valorParcela)}\n'
        'Total pago: ${_formatadorMoeda.format(model.custoTotalEmprestimo)}\n'
        'Total de juros: ${_formatadorMoeda.format(model.totalJuros)}\n'
        'Total de taxas e encargos: ${_formatadorMoeda.format(model.totalTaxasEncargos)}\n\n'
        'Taxa de juros efetiva: ${_formatadorPercentual.format(model.taxaJurosEfetivaAnual)}/ano '
        '(${_formatadorPercentual.format(model.taxaJurosEfetivaMensal)}/mês)\n'
        'Custo Efetivo Total (CET): ${_formatadorPercentual.format(model.cetAnual)}/ano '
        '(${_formatadorPercentual.format(model.cetMensal)}/mês)';
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

  @override
  void dispose() {
    valorEmprestimoController.dispose();
    numeroParcelasController.dispose();
    taxaJurosAnualController.dispose();
    taxaAdministrativaController.dispose();
    seguroController.dispose();
    iofController.dispose();
    outrasTaxasController.dispose();
    valorEmprestimoFocus.dispose();
    numeroParcelasFocus.dispose();
    taxaJurosAnualFocus.dispose();
    taxaAdministrativaFocus.dispose();
    seguroFocus.dispose();
    iofFocus.dispose();
    outrasTaxasFocus.dispose();
    super.dispose();
  }

  NumberFormat get formatadorMoeda => _formatadorMoeda;
  NumberFormat get formatadorPercentual => _formatadorPercentual;
}
