// Flutter imports:
// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/orcamento_regra_3050/controllers/models/orcamento_model.dart';

class OrcamentoController extends ChangeNotifier {
  final OrcamentoModel _model = OrcamentoModel();
  bool _resultadoVisivel = false;
  String _situacaoGeral = '';
  Color _situacaoGeralColor = Colors.grey;

  final _formatadorMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final _formatadorPercentual = NumberFormat.percentPattern('pt_BR');

  // Getters
  bool get resultadoVisivel => _resultadoVisivel;
  String get situacaoGeral => _situacaoGeral;
  Color get situacaoGeralColor => _situacaoGeralColor;
  OrcamentoModel get model => _model;
  NumberFormat get formatadorMoeda => _formatadorMoeda;
  NumberFormat get formatadorPercentual => _formatadorPercentual;

  double get despesasEssenciaisPercentual => _model.percentEssenciais * 100;
  double get despesasNaoEssenciaisPercentual =>
      _model.percentNaoEssenciais * 100;
  double get investimentosPercentual => _model.percentInvestimentos * 100;

  List<PieChartSectionData> get graficoSections => [
        if (_model.percentEssenciais > 0)
          PieChartSectionData(
            value: _model.percentEssenciais * 100,
            title: '${(_model.percentEssenciais * 100).toStringAsFixed(1)}%',
            color: Colors.blue,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        if (_model.percentNaoEssenciais > 0)
          PieChartSectionData(
            value: _model.percentNaoEssenciais * 100,
            title: '${(_model.percentNaoEssenciais * 100).toStringAsFixed(1)}%',
            color: Colors.green,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        if (_model.percentInvestimentos > 0)
          PieChartSectionData(
            value: _model.percentInvestimentos * 100,
            title: '${(_model.percentInvestimentos * 100).toStringAsFixed(1)}%',
            color: Colors.orange,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      ];

  void calcular(String rendaTotal, String despesasEssenciais,
      String despesasNaoEssenciais, String investimentos) {
    if (rendaTotal.isEmpty) {
      throw Exception('Informe a renda total');
    }

    double rendaTotalValue = _converterMoedaParaDouble(rendaTotal);
    if (rendaTotalValue <= 0) {
      throw Exception('A renda total deve ser maior que zero');
    }

    _model.rendaTotal = rendaTotalValue;
    _model.despesasEssenciais = despesasEssenciais.isEmpty
        ? 0.0
        : _converterMoedaParaDouble(despesasEssenciais);
    _model.despesasNaoEssenciais = despesasNaoEssenciais.isEmpty
        ? 0.0
        : _converterMoedaParaDouble(despesasNaoEssenciais);
    _model.investimentos =
        investimentos.isEmpty ? 0.0 : _converterMoedaParaDouble(investimentos);

    var (mensagem, cor) = _model.avaliarSituacao();
    _situacaoGeral = mensagem;
    _situacaoGeralColor = cor;
    _resultadoVisivel = true;

    notifyListeners();
  }

  double _converterMoedaParaDouble(String valor) {
    String valorLimpo = valor
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(valorLimpo) ?? 0;
  }

  String gerarTextoCompartilhamento() {
    return 'Simulador de Orçamento Pessoal - Regra 50-30-20\n\n'
        'Renda total: ${_formatadorMoeda.format(_model.rendaTotal)}\n\n'
        'DISTRIBUIÇÃO IDEAL:\n'
        'Despesas Essenciais (50%): ${_formatadorMoeda.format(_model.despesasEssenciaisIdeal)}\n'
        'Despesas Não Essenciais (30%): ${_formatadorMoeda.format(_model.despesasNaoEssenciaisIdeal)}\n'
        'Investimentos (20%): ${_formatadorMoeda.format(_model.investimentosIdeal)}\n\n'
        'DISTRIBUIÇÃO REAL:\n'
        'Despesas Essenciais (${(_model.percentEssenciais * 100).toStringAsFixed(1)}%): '
        '${_formatadorMoeda.format(_model.despesasEssenciais)}\n'
        'Despesas Não Essenciais (${(_model.percentNaoEssenciais * 100).toStringAsFixed(1)}%): '
        '${_formatadorMoeda.format(_model.despesasNaoEssenciais)}\n'
        'Investimentos (${(_model.percentInvestimentos * 100).toStringAsFixed(1)}%): '
        '${_formatadorMoeda.format(_model.investimentos)}\n\n'
        'ANÁLISE: $_situacaoGeral';
  }

  void limpar() {
    _model.rendaTotal = 0.0;
    _model.despesasEssenciais = 0.0;
    _model.despesasNaoEssenciais = 0.0;
    _model.investimentos = 0.0;
    _resultadoVisivel = false;
    _situacaoGeral = '';
    _situacaoGeralColor = Colors.grey;
    notifyListeners();
  }
}
