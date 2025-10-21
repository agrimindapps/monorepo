// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/trabalhistas/decimo_terceiro/controllers/models/decimo_terceiro_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validation_service.dart';

class DecimoTerceiroController extends ChangeNotifier {
  // Services
  final CalculationService _calculationService = CalculationService();
  final ValidationService _validationService = ValidationService();
  final FormattingService _formattingService = FormattingService();
  
  // Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController salarioBrutoController = TextEditingController();
  final TextEditingController mesesTrabalhadosController = TextEditingController();
  final TextEditingController dataAdmissaoController = TextEditingController();
  final TextEditingController dataCalculoController = TextEditingController();
  final TextEditingController faltasController = TextEditingController();
  final TextEditingController dependentesController = TextEditingController();
  
  // State
  DecimoTerceiroModel? _model;
  bool _isCalculating = false;
  bool _showResult = false;
  bool _antecipacao = false;
  String? _errorMessage;
  DateTime? _dataAdmissao;
  DateTime? _dataCalculo;
  
  // Getters
  DecimoTerceiroModel? get model => _model;
  bool get isCalculating => _isCalculating;
  bool get showResult => _showResult;
  bool get antecipacao => _antecipacao;
  String? get errorMessage => _errorMessage;
  DateTime? get dataAdmissao => _dataAdmissao;
  DateTime? get dataCalculo => _dataCalculo;
  FormattingService get formattingService => _formattingService;
  
  // Constructor
  DecimoTerceiroController() {
    // Inicializa com data atual
    _dataCalculo = DateTime.now();
    dataCalculoController.text = _formattingService.formatDate(_dataCalculo!);
    
    // Inicializa com data de admissão 12 meses atrás
    _dataAdmissao = DateTime(_dataCalculo!.year - 1, _dataCalculo!.month, _dataCalculo!.day);
    dataAdmissaoController.text = _formattingService.formatDate(_dataAdmissao!);
    
    // Calcula meses trabalhados automaticamente
    _updateMesesTrabalhados();
  }
  
  // Validation methods
  String? validateSalario(String? value) => _validationService.validateSalario(value);
  String? validateMeses(String? value) => _validationService.validateMeses(value);
  String? validateFaltas(String? value) => _validationService.validateFaltas(value);
  String? validateDependentes(String? value) => _validationService.validateDependentes(value);
  
  String? validateDataAdmissao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data de admissão';
    }
    
    final data = _formattingService.parseDate(value);
    if (data == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }
    
    return _validationService.validateDataAdmissao(data);
  }
  
  String? validateDataCalculo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data do cálculo';
    }
    
    final data = _formattingService.parseDate(value);
    if (data == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }
    
    return _validationService.validateDataCalculo(data);
  }
  
  void setAntecipacao(bool value) {
    _antecipacao = value;
    notifyListeners();
  }
  
  void onDataAdmissaoChanged(String value) {
    _dataAdmissao = _formattingService.parseDate(value);
    _updateMesesTrabalhados();
  }
  
  void onDataCalculoChanged(String value) {
    _dataCalculo = _formattingService.parseDate(value);
    _updateMesesTrabalhados();
  }
  
  void _updateMesesTrabalhados() {
    if (_dataAdmissao != null && _dataCalculo != null) {
      final meses = _calculationService.calcularMesesTrabalhados(_dataAdmissao!, _dataCalculo!);
      mesesTrabalhadosController.text = meses.toString();
    }
  }
  
  Future<void> calcular() async {
    _clearError();
    
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Validação adicional do período
    final validacaoPeriodo = _validationService.validatePeriodo(_dataAdmissao, _dataCalculo);
    if (validacaoPeriodo != null) {
      _setError(validacaoPeriodo);
      return;
    }
    
    try {
      _isCalculating = true;
      notifyListeners();
      
      // Simula delay para feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Parse values
      final salarioBruto = _formattingService.parseCurrency(salarioBrutoController.text);
      final mesesTrabalhados = int.tryParse(mesesTrabalhadosController.text) ?? 0;
      final faltasNaoJustificadas = int.tryParse(faltasController.text) ?? 0;
      final dependentes = int.tryParse(dependentesController.text) ?? 0;
      
      // Calculate
      _model = _calculationService.calculate(
        salarioBruto: salarioBruto,
        mesesTrabalhados: mesesTrabalhados,
        dataAdmissao: _dataAdmissao!,
        dataCalculo: _dataCalculo!,
        faltasNaoJustificadas: faltasNaoJustificadas,
        antecipacao: _antecipacao,
        dependentes: dependentes,
      );
      
      _showResult = true;
      
    } catch (e) {
      _setError('Erro ao calcular décimo terceiro: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
  
  void limparCampos() {
    salarioBrutoController.clear();
    mesesTrabalhadosController.clear();
    faltasController.clear();
    dependentesController.clear();
    
    // Reseta datas para padrão
    _dataCalculo = DateTime.now();
    dataCalculoController.text = _formattingService.formatDate(_dataCalculo!);
    
    _dataAdmissao = DateTime(_dataCalculo!.year - 1, _dataCalculo!.month, _dataCalculo!.day);
    dataAdmissaoController.text = _formattingService.formatDate(_dataAdmissao!);
    
    _updateMesesTrabalhados();
    
    _model = null;
    _showResult = false;
    _antecipacao = false;
    _clearError();
    
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    salarioBrutoController.dispose();
    mesesTrabalhadosController.dispose();
    dataAdmissaoController.dispose();
    dataCalculoController.dispose();
    faltasController.dispose();
    dependentesController.dispose();
    super.dispose();
  }
}
