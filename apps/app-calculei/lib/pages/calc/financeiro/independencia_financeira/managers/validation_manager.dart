// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/constants/independencia_financeira_constants.dart';
import 'package:app_calculei/services/validacao_service.dart';

class CalculoError implements Exception {
  final String message;
  final String field;
  CalculoError(this.message, this.field);
}

class ValidationManager extends ChangeNotifier {
  final _validacaoService = ValidacaoService();
  
  Map<String, List<ResultadoValidacao>> _validacoes = {};
  bool _temErros = false;
  bool _validacaoEmAndamento = false;
  
  // Cache para otimização de performance
  final Map<String, String> _lastValues = {};
  final Map<String, List<ResultadoValidacao>> _cachedValidations = {};

  // Getters
  Map<String, List<ResultadoValidacao>> get validacoes => _validacoes;
  bool get temErros => _temErros;
  bool get validacaoEmAndamento => _validacaoEmAndamento;

  List<ResultadoValidacao> getValidacoesCampo(String campo) {
    return _validacoes[campo] ?? [];
  }


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

  void validarCampos({
    required String patrimonioAtual,
    required String despesasMensais,
    required String aporteMensal,
    required String retornoInvestimentos,
    required String taxaRetirada,
    required dynamic formatoMoeda,
  }) {
    // Evita validações concorrentes
    if (_validacaoEmAndamento) return;
    
    _validacaoEmAndamento = true;
    
    // Verifica se algum valor mudou para otimizar performance
    String currentHash = '$patrimonioAtual|$despesasMensais|$aporteMensal|$retornoInvestimentos|$taxaRetirada';
    if (_lastValues['all'] == currentHash) {
      _validacaoEmAndamento = false;
      return; // Usa cache se nada mudou
    }
    
    _validacoes.clear();
    _temErros = false;

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

      _validacoes = {
        'patrimonioAtual':
            _validacaoService.validarPatrimonioAtual(patrimonioAtualValue),
        'despesasMensais': _validacaoService.validarDespesasMensais(
            despesasMensaisValue, patrimonioAtualValue),
        'aporteMensal': _validacaoService.validarAporteMensal(
            aporteMensalValue, despesasMensaisValue),
        'retornoAnual': _validacaoService.validarRetornoAnual(retornoAnualValue),
        'taxaRetirada': _validacaoService.validarTaxaRetirada(taxaRetiradaValue),
        'combinacao': _validacaoService.validarCombinacaoParametros(
          patrimonioAtual: patrimonioAtualValue,
          despesasMensais: despesasMensaisValue,
          aporteMensal: aporteMensalValue,
          retornoAnual: retornoAnualValue,
          taxaRetirada: taxaRetiradaValue,
        ),
      };
    } catch (e) {
      if (e is CalculoError) {
        _validacoes[e.field] = [
          ResultadoValidacao(
            mensagem: e.message,
            tipo: TipoValidacao.erro,
          )
        ];
      }
      _temErros = true;
    }

    _temErros = _temErros ||
        _validacoes.values
            .any((list) => list.any((v) => v.tipo == TipoValidacao.erro));

    // Salva no cache para próxima validação
    _lastValues['all'] = currentHash;
    
    _validacaoEmAndamento = false;
    notifyListeners();
  }

  void limpar() {
    _validacoes.clear();
    _temErros = false;
    _validacaoEmAndamento = false;
    _lastValues.clear();
    _cachedValidations.clear();
    notifyListeners();
  }
}
