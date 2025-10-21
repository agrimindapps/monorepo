// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/trabalhistas/seguro_desemprego/controllers/models/seguro_desemprego_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validation_service.dart';

class SeguroDesempregoController extends ChangeNotifier {
  // Services
  final CalculationService _calculationService = CalculationService();
  final ValidationService _validationService = ValidationService();
  final FormattingService _formattingService = FormattingService();
  
  // Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController salarioMedioController = TextEditingController();
  final TextEditingController tempoTrabalhoController = TextEditingController();
  final TextEditingController vezesRecebidasController = TextEditingController();
  final TextEditingController dataDemissaoController = TextEditingController();
  
  // State
  SeguroDesempregoModel? _model;
  bool _isCalculating = false;
  bool _showResult = false;
  String? _errorMessage;
  DateTime? _dataDemissao;
  
  // Getters
  SeguroDesempregoModel? get model => _model;
  bool get isCalculating => _isCalculating;
  bool get showResult => _showResult;
  String? get errorMessage => _errorMessage;
  DateTime? get dataDemissao => _dataDemissao;
  FormattingService get formattingService => _formattingService;
  
  // Constructor
  SeguroDesempregoController() {
    // Inicializa com data de demissão sendo hoje
    _dataDemissao = DateTime.now();
    dataDemissaoController.text = _formattingService.formatDate(_dataDemissao!);
    
    // Inicializa com 0 vezes recebidas
    vezesRecebidasController.text = '0';
  }
  
  // Validation methods
  String? validateSalarioMedio(String? value) => _validationService.validateSalarioMedio(value);
  String? validateTempoTrabalho(String? value) => _validationService.validateTempoTrabalho(value);
  String? validateVezesRecebidas(String? value) => _validationService.validateVezesRecebidas(value);
  
  String? validateDataDemissao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a data de demissão';
    }
    
    final data = _formattingService.parseDate(value);
    if (data == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }
    
    return _validationService.validateDataDemissao(data);
  }
  
  void onDataDemissaoChanged(String value) {
    _dataDemissao = _formattingService.parseDate(value);
    notifyListeners();
  }
  
  String getDicaCarencia() {
    final tempoTrabalho = int.tryParse(tempoTrabalhoController.text) ?? 0;
    final vezesRecebidas = int.tryParse(vezesRecebidasController.text) ?? 0;
    
    return _validationService.getDicaCarencia(tempoTrabalho, vezesRecebidas);
  }
  
  String getDicaVezesRecebidas() {
    final vezesRecebidas = int.tryParse(vezesRecebidasController.text) ?? 0;
    return _validationService.getDicaVezesRecebidas(vezesRecebidas);
  }
  
  String getDicaPrazo() {
    if (_dataDemissao == null) return '';
    return _validationService.getDicaPrazo(_dataDemissao!);
  }
  
  String getDicaSalario() {
    final salarioMedio = _formattingService.parseCurrency(salarioMedioController.text);
    if (salarioMedio == 0) return '';
    return _validationService.getDicaSalario(salarioMedio);
  }
  
  String getDicaTempo() {
    final tempoTrabalho = int.tryParse(tempoTrabalhoController.text) ?? 0;
    final vezesRecebidas = int.tryParse(vezesRecebidasController.text) ?? 0;
    
    if (tempoTrabalho == 0) return '';
    
    return _calculationService.obterDicaTempo(tempoTrabalho, vezesRecebidas);
  }
  
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
      final salarioMedio = _formattingService.parseCurrency(salarioMedioController.text);
      final tempoTrabalho = int.tryParse(tempoTrabalhoController.text) ?? 0;
      final vezesRecebidas = int.tryParse(vezesRecebidasController.text) ?? 0;
      
      // Calculate
      _model = _calculationService.calculate(
        salarioMedio: salarioMedio,
        tempoTrabalho: tempoTrabalho,
        vezesRecebidas: vezesRecebidas,
        dataDemissao: _dataDemissao!,
      );
      
      _showResult = true;
      
    } catch (e) {
      _setError('Erro ao calcular seguro-desemprego: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
  
  void limparCampos() {
    salarioMedioController.clear();
    tempoTrabalhoController.clear();
    
    // Reseta para valores padrão
    vezesRecebidasController.text = '0';
    _dataDemissao = DateTime.now();
    dataDemissaoController.text = _formattingService.formatDate(_dataDemissao!);
    
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
    salarioMedioController.dispose();
    tempoTrabalhoController.dispose();
    vezesRecebidasController.dispose();
    dataDemissaoController.dispose();
    super.dispose();
  }
}
