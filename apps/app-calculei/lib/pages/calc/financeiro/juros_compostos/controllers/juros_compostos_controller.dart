// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/juros_compostos/controllers/models/juros_compostos_model.dart';
import 'package:app_calculei/services/juros_compostos_service.dart';

class JurosCompostosController extends ChangeNotifier {
  JurosCompostosModel _model = JurosCompostosModel();
  bool _isCalculating = false;
  String? _error;

  // Timer para debounce das notificações
  Timer? _debounceTimer;
  bool _hasPendingNotification = false;

  // Notifiers específicos para diferentes partes da UI
  final ValueNotifier<bool> _isCalculatingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier(null);
  final ValueNotifier<JurosCompostosModel> _modelNotifier =
      ValueNotifier(JurosCompostosModel());

  JurosCompostosModel get model => _model;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  // Getters para ValueNotifiers específicos
  ValueNotifier<bool> get isCalculatingNotifier => _isCalculatingNotifier;
  ValueNotifier<String?> get errorNotifier => _errorNotifier;
  ValueNotifier<JurosCompostosModel> get modelNotifier => _modelNotifier;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _isCalculatingNotifier.dispose();
    _errorNotifier.dispose();
    _modelNotifier.dispose();
    super.dispose();
  }

  /// Notifica mudanças com debounce para melhorar performance
  void _notifyWithDebounce() {
    _hasPendingNotification = true;
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_hasPendingNotification) {
        _updateNotifiers();
        notifyListeners();
        _hasPendingNotification = false;
      }
    });
  }

  /// Atualiza os ValueNotifiers específicos
  void _updateNotifiers() {
    _isCalculatingNotifier.value = _isCalculating;
    _errorNotifier.value = _error;
    _modelNotifier.value = _model;
  }

  /// Notificação imediata para mudanças críticas
  void _notifyImmediately() {
    _debounceTimer?.cancel();
    _hasPendingNotification = false;
    _updateNotifiers();
    notifyListeners();
  }

  void setCapitalInicial(String value) {
    if (value.isEmpty) {
      _model = _model.copyWith(capitalInicial: null);
      _error = null;
      _notifyWithDebounce();
      return;
    }

    try {
      // Remove formatação monetária
      String cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
      cleanValue = cleanValue.replaceAll(',', '.');
      double parsed = double.parse(cleanValue);

      // Validações específicas
      if (parsed < 0) {
        _error = 'Capital inicial não pode ser negativo';
        _notifyImmediately(); // Erro deve ser mostrado imediatamente
        return;
      }
      if (parsed > 999999999) {
        _error = 'Capital inicial muito alto (máx: R\$ 999.999.999)';
        _notifyImmediately(); // Erro deve ser mostrado imediatamente
        return;
      }

      _model = _model.copyWith(capitalInicial: parsed);
      _error = null;
      _notifyWithDebounce(); // Mudanças de valor usam debounce
    } catch (e) {
      _error = 'Valor inválido para capital inicial';
      _notifyImmediately(); // Erro deve ser mostrado imediatamente
    }
  }

  void setTaxaJuros(String value) {
    if (value.isEmpty) {
      _model = _model.copyWith(taxaJuros: null);
      _error = null;
      _notifyWithDebounce();
      return;
    }

    try {
      String normalizedValue = value.replaceAll(',', '.');
      double parsed = double.parse(normalizedValue);

      // Validações específicas
      if (parsed < 0) {
        _error = 'Taxa de juros não pode ser negativa';
        _notifyImmediately();
        return;
      }
      if (parsed > 100) {
        _error = 'Taxa de juros muito alta (máx: 100% ao mês)';
        _notifyImmediately();
        return;
      }

      _model = _model.copyWith(taxaJuros: parsed / 100);
      _error = null;
      _notifyWithDebounce();
    } catch (e) {
      _error = 'Valor inválido para taxa de juros';
      _notifyImmediately();
    }
  }

  void setPeriodo(String value) {
    if (value.isEmpty) {
      _model = _model.copyWith(periodo: null);
      _error = null;
      _notifyWithDebounce();
      return;
    }

    try {
      String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
      int parsed = int.parse(cleanValue);

      // Validações específicas
      if (parsed <= 0) {
        _error = 'Período deve ser maior que zero';
        _notifyImmediately();
        return;
      }
      if (parsed > 1200) {
        _error = 'Período muito longo (máx: 1200 meses / 100 anos)';
        _notifyImmediately();
        return;
      }

      _model = _model.copyWith(periodo: parsed);
      _error = null;
      _notifyWithDebounce();
    } catch (e) {
      _error = 'Valor inválido para período';
      _notifyImmediately();
    }
  }

  void setAporteMensal(String value) {
    if (value.isEmpty) {
      _model = _model.copyWith(aporteMensal: 0.0);
      _error = null;
      _notifyWithDebounce();
      return;
    }

    try {
      // Remove formatação monetária
      String cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
      cleanValue = cleanValue.replaceAll(',', '.');
      double parsed = double.parse(cleanValue);

      // Validações específicas
      if (parsed < 0) {
        _error = 'Aporte mensal não pode ser negativo';
        _notifyImmediately();
        return;
      }
      if (parsed > 999999999) {
        _error = 'Aporte mensal muito alto (máx: R\$ 999.999.999)';
        _notifyImmediately();
        return;
      }

      _model = _model.copyWith(aporteMensal: parsed);
      _error = null;
      _notifyWithDebounce();
    } catch (e) {
      _error = 'Valor inválido para aporte mensal';
      _notifyImmediately();
    }
  }

  Future<void> calcularJurosCompostos() async {
    // Validações de campos obrigatórios
    if (_model.capitalInicial == null) {
      _error = 'Capital inicial é obrigatório';
      _notifyImmediately();
      return;
    }
    if (_model.taxaJuros == null) {
      _error = 'Taxa de juros é obrigatória';
      _notifyImmediately();
      return;
    }
    if (_model.periodo == null) {
      _error = 'Período é obrigatório';
      _notifyImmediately();
      return;
    }
    if (_model.aporteMensal == null) {
      _error = 'Aporte mensal é obrigatório (use 0 se não houver)';
      _notifyImmediately();
      return;
    }

    _isCalculating = true;
    _notifyImmediately(); // Estado de carregamento deve ser imediato

    try {
      // Prepara parâmetros para o service
      final params = JurosCompostosParams(
        capitalInicial: _model.capitalInicial!,
        taxaJuros: _model.taxaJuros!,
        periodo: _model.periodo!,
        aporteMensal: _model.aporteMensal!,
      );

      // Delega o cálculo para o service
      final result = JurosCompostosService.calcular(params);
      if (!result.isValid) {
        _error = result.errorMessage;
        _isCalculating = false;
        _notifyImmediately();
        return;
      }

      // Atualiza o model com os resultados
      _model = _model.copyWith(
        montanteFinal: result.montanteFinal,
        totalInvestido: result.totalInvestido,
        totalJuros: result.totalJuros,
        rendimentoTotal: result.rendimentoTotal,
      );

      _error = null;
    } catch (e) {
      _error = 'Erro no cálculo: ${e.toString()}';
    } finally {
      _isCalculating = false;
      _notifyImmediately(); // Resultado deve ser mostrado imediatamente
    }
  }

  void limparCampos() {
    _debounceTimer?.cancel(); // Cancela debounce pendente
    _model = JurosCompostosModel();
    _error = null;
    _notifyImmediately(); // Limpeza deve ser imediata
  }

  /// Simula a evolução mensal do investimento
  List<Map<String, double>>? simularEvolucaoMensal() {
    if (_model.capitalInicial == null ||
        _model.taxaJuros == null ||
        _model.periodo == null ||
        _model.aporteMensal == null) {
      return null;
    }

    final params = JurosCompostosParams(
      capitalInicial: _model.capitalInicial!,
      taxaJuros: _model.taxaJuros!,
      periodo: _model.periodo!,
      aporteMensal: _model.aporteMensal!,
    );

    return JurosCompostosService.simularEvolucaoMensal(params);
  }

  /// Calcula qual taxa seria necessária para atingir um objetivo
  double? calcularTaxaNecessaria(double valorObjetivo) {
    if (_model.capitalInicial == null ||
        _model.periodo == null ||
        _model.capitalInicial! == 0) {
      return null;
    }

    return JurosCompostosService.calcularTaxaNecessaria(
      capitalInicial: _model.capitalInicial!,
      valorFuturo: valorObjetivo,
      periodo: _model.periodo!,
    );
  }

  /// Calcula qual período seria necessário para atingir um objetivo
  int? calcularPeriodoNecessario(double valorObjetivo) {
    if (_model.capitalInicial == null ||
        _model.taxaJuros == null ||
        _model.capitalInicial! == 0 ||
        _model.taxaJuros! == 0) {
      return null;
    }

    return JurosCompostosService.calcularPeriodoNecessario(
      capitalInicial: _model.capitalInicial!,
      valorFuturo: valorObjetivo,
      taxaJuros: _model.taxaJuros!,
    );
  }

  /// Calcula o valor presente de um valor futuro desejado
  double? calcularValorPresente(double valorFuturo) {
    if (_model.taxaJuros == null || _model.periodo == null) {
      return null;
    }

    return JurosCompostosService.calcularValorPresente(
      valorFuturo: valorFuturo,
      taxaJuros: _model.taxaJuros!,
      periodo: _model.periodo!,
    );
  }
}
