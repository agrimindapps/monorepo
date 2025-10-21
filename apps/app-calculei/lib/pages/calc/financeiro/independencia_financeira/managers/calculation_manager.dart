// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/constants/independencia_financeira_constants.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/managers/models/independencia_financeira_model.dart';
import 'package:app_calculei/services/calculadora_financeira_service.dart';
import 'package:app_calculei/services/validacao_service.dart';
import 'validation_manager.dart';

class CalculationManager extends ChangeNotifier {
  final _calculadoraService = CalculadoraFinanceiraService();
  
  bool _calculando = false;
  bool _calculoRealizado = false;
  IndependenciaFinanceiraModel? _modelo;

  // Getters
  bool get calculando => _calculando;
  bool get calculoRealizado => _calculoRealizado;
  IndependenciaFinanceiraModel? get modelo => _modelo;

  double _parseMoedaOuLancarErro(String valor, String campo, dynamic formatoMoeda) {
    try {
      if (valor.isEmpty) {
        throw CalculoError('Campo obrigatório', campo);
      }
      final result = formatoMoeda.getUnmaskedDouble(valor);
      if (result <= 0) {
        throw CalculoError('Valor deve ser maior que zero', campo);
      }
      if (result > 999999999999) {
        throw CalculoError('Valor muito grande', campo);
      }
      return result;
    } catch (e) {
      if (e is CalculoError) rethrow;
      throw CalculoError('Formato de moeda inválido', campo);
    }
  }

  double _parsePercentualOuLancarErro(String valor, String campo,
      {double min = 0, double max = 100}) {
    try {
      if (valor.isEmpty) {
        throw CalculoError('Campo obrigatório', campo);
      }
      final percentual = double.parse(valor.replaceAll(',', '.'));
      if (percentual < min || percentual > max) {
        throw CalculoError('Valor deve estar entre $min% e $max%', campo);
      }
      return percentual / 100;
    } catch (e) {
      if (e is CalculoError) rethrow;
      throw CalculoError('Formato de percentual inválido', campo);
    }
  }

  void calcular({
    required String patrimonioAtual,
    required String despesasMensais,
    required String aporteMensal,
    required String retornoInvestimentos,
    required String taxaRetirada,
    required dynamic formatoMoeda,
    required ValidationManager validationManager,
  }) {
    // Evita cálculos concorrentes
    if (_calculando || validationManager.validacaoEmAndamento) return;
    
    _calculando = true;
    
    if (validationManager.temErros) {
      _calculando = false;
      notifyListeners();
      return;
    }

    try {
      final patrimonioAtualValue = _parseMoedaOuLancarErro(
          patrimonioAtual,
          IndependenciaFinanceiraConstants.labelPatrimonioAtual,
          formatoMoeda);

      final despesasMensaisValue = _parseMoedaOuLancarErro(
          despesasMensais,
          IndependenciaFinanceiraConstants.labelDespesasMensais,
          formatoMoeda);

      final aporteMensalValue = _parseMoedaOuLancarErro(
          aporteMensal,
          IndependenciaFinanceiraConstants.labelAporteMensal,
          formatoMoeda);

      final retornoAnualValue = _parsePercentualOuLancarErro(
          retornoInvestimentos,
          IndependenciaFinanceiraConstants.labelRetornoAnual,
          min: 0.1,
          max: 50);

      final taxaRetiradaValue = _parsePercentualOuLancarErro(
          taxaRetirada,
          IndependenciaFinanceiraConstants.labelTaxaRetirada,
          min: 0.5,
          max: 10);

      // Usa o método centralizado para calcular tudo
      _modelo = _calculadoraService.calcularCompleto(
        patrimonioAtual: patrimonioAtualValue,
        despesasMensais: despesasMensaisValue,
        aporteMensal: aporteMensalValue,
        retornoAnual: retornoAnualValue,
        taxaRetirada: taxaRetiradaValue,
      );
      _calculoRealizado = true;
    } catch (e) {
      _calculoRealizado = false;
      _modelo = null;
      if (e is CalculoError) {
        validationManager.validacoes[e.field] = [
          ResultadoValidacao(
            mensagem: e.message,
            tipo: TipoValidacao.erro,
          )
        ];
      }
    }

    _calculando = false;
    notifyListeners();
  }

  void limpar() {
    _calculoRealizado = false;
    _modelo = null;
    _calculando = false;
    notifyListeners();
  }
}
