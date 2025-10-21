// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/helpers/sugestoes_helper.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/managers/calculation_manager.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/managers/form_state_manager.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/managers/performance_manager.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/managers/validation_manager.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/models/independencia_financeira_model.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validacao_service.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/controllers/utils/debouncer.dart';

class IndependenciaFinanceiraController extends ChangeNotifier {
  bool _calculoAutomatico = true;
  final _debouncer = Debouncer();

  // Managers
  final _formStateManager = FormStateManager();
  final _validationManager = ValidationManager();
  final _calculationManager = CalculationManager();
  final _performanceManager = PerformanceManager();

  // Services and helpers
  final _formattingService = FormattingService();
  final _sugestoesHelper = SugestoesHelper();

  IndependenciaFinanceiraController() {
    _setupListeners();
  }

  // Getters - Delegando para os managers
  TextEditingController get patrimonioAtualController =>
      _formStateManager.patrimonioAtualController;
  TextEditingController get despesasMensaisController =>
      _formStateManager.despesasMensaisController;
  TextEditingController get aporteMensalController => _formStateManager.aporteMensalController;
  TextEditingController get retornoInvestimentosController =>
      _formStateManager.retornoInvestimentosController;
  TextEditingController get taxaRetiradaController => _formStateManager.taxaRetiradaController;
  get formatoMoeda => _formStateManager.formatoMoeda;
  get formatoNumerico => _formStateManager.formatoNumerico;
  bool get calculoRealizado => _calculationManager.calculoRealizado;
  bool get calculando => _calculationManager.calculando;
  bool get calculoAutomatico => _calculoAutomatico;
  IndependenciaFinanceiraModel? get modelo => _calculationManager.modelo;
  Map<String, List<ResultadoValidacao>> get validacoes => _validationManager.validacoes;
  bool get temErros => _validationManager.temErros;

  void _validarCampos() {
    _validationManager.validarCampos(
      patrimonioAtual: _formStateManager.patrimonioAtualController.text,
      despesasMensais: _formStateManager.despesasMensaisController.text,
      aporteMensal: _formStateManager.aporteMensalController.text,
      retornoInvestimentos: _formStateManager.retornoInvestimentosController.text,
      taxaRetirada: _formStateManager.taxaRetiradaController.text,
      formatoMoeda: _formStateManager.formatoMoeda,
    );
  }

  void calcular() {
    _validarCampos();
    
    _calculationManager.calcular(
      patrimonioAtual: _formStateManager.patrimonioAtualController.text,
      despesasMensais: _formStateManager.despesasMensaisController.text,
      aporteMensal: _formStateManager.aporteMensalController.text,
      retornoInvestimentos: _formStateManager.retornoInvestimentosController.text,
      taxaRetirada: _formStateManager.taxaRetiradaController.text,
      formatoMoeda: _formStateManager.formatoMoeda,
      validationManager: _validationManager,
    );
  }

  String formatarNumero(double valor) =>
      _formattingService.formatarMoedaCompacta(valor);
  String formatarPercentual(double valor) =>
      _formattingService.formatarPercentual(valor);
  String formatarAnos(double anos) => _formattingService.formatarAnos(anos);
  String getSugestaoTexto() => _calculationManager.modelo != null
      ? _sugestoesHelper.getSugestao(_calculationManager.modelo!.anosParaIndependencia)
      : '';

  List<ResultadoValidacao> getValidacoesCampo(String campo) {
    return _validationManager.getValidacoesCampo(campo);
  }

  void toggleCalculoAutomatico() {
    _calculoAutomatico = !_calculoAutomatico;
    notifyListeners();
  }

  late final VoidCallback _listener;

  void _setupListeners() {
    _listener = () {
      if (_calculoAutomatico && !_calculationManager.calculando && !_validationManager.validacaoEmAndamento) {
        // Usa o performance manager para otimizar o debouncing
        _performanceManager.scheduleValidation(() {
          if (!_calculationManager.calculando && !_validationManager.validacaoEmAndamento) {
            _validarCampos();
            if (!_validationManager.temErros) {
              _performanceManager.scheduleCalculation(() {
                calcular();
              });
            }
          }
        });
      }
    };

    _formStateManager.addFormListener(_listener);
    
    // Configura listeners para os managers notificarem mudanças
    _validationManager.addListener(() => notifyListeners());
    _calculationManager.addListener(() => notifyListeners());
  }

  void limpar() {
    _performanceManager.cancelAll();
    _formStateManager.limpar();
    _validationManager.limpar();
    _calculationManager.limpar();
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancela operações pendentes e dispõe do debouncer
    _debouncer.dispose();
    _performanceManager.dispose();
    
    // Remove listeners dos managers
    _formStateManager.removeFormListener(_listener);
    _validationManager.removeListener(() => notifyListeners());
    _calculationManager.removeListener(() => notifyListeners());
    
    // Dispõe dos managers
    _formStateManager.dispose();
    _validationManager.dispose();
    _calculationManager.dispose();
    
    super.dispose();
  }
}
