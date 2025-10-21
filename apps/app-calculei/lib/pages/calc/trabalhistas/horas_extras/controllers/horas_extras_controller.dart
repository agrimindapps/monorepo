// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/horas_extras/controllers/models/horas_extras_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validation_service.dart';

class HorasExtrasController extends ChangeNotifier {
  // Services
  final CalculationService _calculationService = CalculationService();
  final ValidationService _validationService = ValidationService();
  final FormattingService _formattingService = FormattingService();
  
  // Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController salarioBrutoController = TextEditingController();
  final TextEditingController horasSemanaisController = TextEditingController();
  final TextEditingController horas50Controller = TextEditingController();
  final TextEditingController horas100Controller = TextEditingController();
  final TextEditingController horasNoturnasController = TextEditingController();
  final TextEditingController percentualNoturnoController = TextEditingController();
  final TextEditingController horasDomingoFeriadoController = TextEditingController();
  final TextEditingController diasUteisController = TextEditingController();
  final TextEditingController dependentesController = TextEditingController();
  
  // State
  HorasExtrasModel? _model;
  bool _isCalculating = false;
  bool _showResult = false;
  String? _errorMessage;
  
  // Getters
  HorasExtrasModel? get model => _model;
  bool get isCalculating => _isCalculating;
  bool get showResult => _showResult;
  String? get errorMessage => _errorMessage;
  FormattingService get formattingService => _formattingService;
  
  // Constructor
  HorasExtrasController() {
    // Inicializa com valores padrão
    horasSemanaisController.text = CalculationConstants.horasSemanaisPadrao.toString();
    diasUteisController.text = CalculationConstants.diasUteisPadrao.toString();
    percentualNoturnoController.text = (CalculationConstants.percentualAdicionalNoturnoMinimo * 100).toStringAsFixed(0);
  }
  
  // Validation methods
  String? validateSalario(String? value) => _validationService.validateSalario(value);
  String? validateHorasSemanais(String? value) => _validationService.validateHorasSemanais(value);
  String? validateHoras50(String? value) => _validationService.validateHorasExtras(value, 'Horas 50%');
  String? validateHoras100(String? value) => _validationService.validateHorasExtras(value, 'Horas 100%');
  String? validateHorasNoturnas(String? value) => _validationService.validateHorasExtras(value, 'Horas noturnas');
  String? validatePercentualNoturno(String? value) => _validationService.validatePercentualNoturno(value);
  String? validateHorasDomingoFeriado(String? value) => _validationService.validateHorasExtras(value, 'Horas domingo/feriado');
  String? validateDiasUteis(String? value) => _validationService.validateDiasUteis(value);
  String? validateDependentes(String? value) => _validationService.validateDependentes(value);
  
  String getDicaJornada() {
    final horas = int.tryParse(horasSemanaisController.text) ?? 0;
    return _validationService.getDicaJornada(horas);
  }
  
  String getAlertaHorasExtras() {
    final horas50 = _formattingService.parseHours(horas50Controller.text);
    final horas100 = _formattingService.parseHours(horas100Controller.text);
    final totalHoras = horas50 + horas100;
    
    return _validationService.getAlertaHorasExtras(totalHoras);
  }
  
  double getHorasTrabalhadasMes() {
    final horasSemanais = int.tryParse(horasSemanaisController.text) ?? 0;
    final diasUteis = int.tryParse(diasUteisController.text) ?? 0;
    
    if (horasSemanais == 0 || diasUteis == 0) return 0.0;
    
    return _calculationService.calcularHorasTrabalhadasMes(horasSemanais, diasUteis);
  }
  
  double getValorHoraNormal() {
    final salario = _formattingService.parseCurrency(salarioBrutoController.text);
    final horasTrabalhadasMes = getHorasTrabalhadasMes();
    
    if (salario == 0 || horasTrabalhadasMes == 0) return 0.0;
    
    return salario / horasTrabalhadasMes;
  }
  
  String getResumoHoras() {
    final horas50 = _formattingService.parseHours(horas50Controller.text);
    final horas100 = _formattingService.parseHours(horas100Controller.text);
    final horasNoturnas = _formattingService.parseHours(horasNoturnasController.text);
    final horasDomingo = _formattingService.parseHours(horasDomingoFeriadoController.text);
    
    return _formattingService.formatResumoHoras(horas50, horas100, horasNoturnas, horasDomingo);
  }
  
  Future<void> calcular() async {
    _clearError();
    
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Validação adicional para horas noturnas e percentual
    final horasNoturnas = _formattingService.parseHours(horasNoturnasController.text);
    final percentualNoturno = _formattingService.parsePercent(percentualNoturnoController.text);
    
    final validacaoNoturna = _validationService.validateHorasNoturnasComPercentual(
      horasNoturnas, 
      percentualNoturno,
    );
    if (validacaoNoturna != null) {
      _setError(validacaoNoturna);
      return;
    }
    
    try {
      _isCalculating = true;
      notifyListeners();
      
      // Simula delay para feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Parse values
      final salarioBruto = _formattingService.parseCurrency(salarioBrutoController.text);
      final horasSemanais = int.tryParse(horasSemanaisController.text) ?? 0;
      final horas50 = _formattingService.parseHours(horas50Controller.text);
      final horas100 = _formattingService.parseHours(horas100Controller.text);
      final horasNoturnas = _formattingService.parseHours(horasNoturnasController.text);
      final percentualNoturno = _formattingService.parsePercent(percentualNoturnoController.text);
      final horasDomingoFeriado = _formattingService.parseHours(horasDomingoFeriadoController.text);
      final diasUteis = int.tryParse(diasUteisController.text) ?? 0;
      final dependentes = int.tryParse(dependentesController.text) ?? 0;
      
      // Calculate
      _model = _calculationService.calculate(
        salarioBruto: salarioBruto,
        horasSemanais: horasSemanais,
        horas50: horas50,
        horas100: horas100,
        horasNoturnas: horasNoturnas,
        percentualNoturno: percentualNoturno,
        horasDomingoFeriado: horasDomingoFeriado,
        dependentes: dependentes,
        diasUteis: diasUteis,
      );
      
      _showResult = true;
      
    } catch (e) {
      _setError('Erro ao calcular horas extras: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
  
  void limparCampos() {
    salarioBrutoController.clear();
    horas50Controller.clear();
    horas100Controller.clear();
    horasNoturnasController.clear();
    horasDomingoFeriadoController.clear();
    dependentesController.clear();
    
    // Reseta para valores padrão
    horasSemanaisController.text = CalculationConstants.horasSemanaisPadrao.toString();
    diasUteisController.text = CalculationConstants.diasUteisPadrao.toString();
    percentualNoturnoController.text = (CalculationConstants.percentualAdicionalNoturnoMinimo * 100).toStringAsFixed(0);
    
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
    horasSemanaisController.dispose();
    horas50Controller.dispose();
    horas100Controller.dispose();
    horasNoturnasController.dispose();
    percentualNoturnoController.dispose();
    horasDomingoFeriadoController.dispose();
    diasUteisController.dispose();
    dependentesController.dispose();
    super.dispose();
  }
}
