// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/trabalhistas/salario_liquido/controllers/models/salario_liquido_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validation_service.dart';

class SalarioLiquidoController extends ChangeNotifier {
  // Services
  final CalculationService _calculationService = CalculationService();
  final ValidationService _validationService = ValidationService();
  final FormattingService _formattingService = FormattingService();
  
  // Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController salarioBrutoController = TextEditingController();
  final TextEditingController dependentesController = TextEditingController();
  final TextEditingController valeTransporteController = TextEditingController();
  final TextEditingController planoSaudeController = TextEditingController();
  final TextEditingController outrosDescontosController = TextEditingController();
  
  // State
  SalarioLiquidoModel? _model;
  bool _isCalculating = false;
  bool _showResult = false;
  String? _errorMessage;
  
  // Getters
  SalarioLiquidoModel? get model => _model;
  bool get isCalculating => _isCalculating;
  bool get showResult => _showResult;
  String? get errorMessage => _errorMessage;
  FormattingService get formattingService => _formattingService;
  
  // Validation methods
  String? validateSalario(String? value) => _validationService.validateSalario(value);
  String? validateDependentes(String? value) => _validationService.validateDependentes(value);
  String? validateValeTransporte(String? value) => _validationService.validateMoneyValue(value, 'Vale transporte');
  String? validatePlanoSaude(String? value) => _validationService.validateMoneyValue(value, 'Plano de saúde');
  String? validateOutrosDescontos(String? value) => _validationService.validateMoneyValue(value, 'Outros descontos');
  
  Future<void> calcular() async {
    _clearError();
    
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      _isCalculating = true;
      notifyListeners();
      
      // Simula delay para feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Parse values
      final salarioBruto = _formattingService.parseCurrency(salarioBrutoController.text);
      final dependentes = int.tryParse(dependentesController.text) ?? 0;
      final valeTransporte = _formattingService.parseCurrency(valeTransporteController.text);
      final planoSaude = _formattingService.parseCurrency(planoSaudeController.text);
      final outrosDescontos = _formattingService.parseCurrency(outrosDescontosController.text);
      
      // Calculate
      _model = _calculationService.calculate(
        salarioBruto: salarioBruto,
        dependentes: dependentes,
        valeTransporte: valeTransporte,
        planoSaude: planoSaude,
        outrosDescontos: outrosDescontos,
      );
      
      _showResult = true;
      
    } catch (e) {
      _setError('Erro ao calcular salário líquido: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
  
  void limparCampos() {
    salarioBrutoController.clear();
    dependentesController.clear();
    valeTransporteController.clear();
    planoSaudeController.clear();
    outrosDescontosController.clear();
    
    _model = null;
    _showResult = false;
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
    dependentesController.dispose();
    valeTransporteController.dispose();
    planoSaudeController.dispose();
    outrosDescontosController.dispose();
    super.dispose();
  }
}
