// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/ferias/controllers/models/ferias_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/formatting_service.dart';
import 'package:app_calculei/services/validation_service.dart';

class FeriasController extends ChangeNotifier {
  // Services
  final CalculationService _calculationService = CalculationService();
  final ValidationService _validationService = ValidationService();
  final FormattingService _formattingService = FormattingService();
  
  // Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController salarioBrutoController = TextEditingController();
  final TextEditingController inicioAquisitivoController = TextEditingController();
  final TextEditingController fimAquisitivoController = TextEditingController();
  final TextEditingController diasFeriasController = TextEditingController();
  final TextEditingController faltasController = TextEditingController();
  final TextEditingController dependentesController = TextEditingController();
  
  // State
  FeriasModel? _model;
  bool _isCalculating = false;
  bool _showResult = false;
  bool _abonoPecuniario = false;
  String? _errorMessage;
  DateTime? _inicioAquisitivo;
  DateTime? _fimAquisitivo;
  int _diasDireito = 0;
  String _dicaFaltas = '';
  
  // Getters
  FeriasModel? get model => _model;
  bool get isCalculating => _isCalculating;
  bool get showResult => _showResult;
  bool get abonoPecuniario => _abonoPecuniario;
  String? get errorMessage => _errorMessage;
  DateTime? get inicioAquisitivo => _inicioAquisitivo;
  DateTime? get fimAquisitivo => _fimAquisitivo;
  int get diasDireito => _diasDireito;
  String get dicaFaltas => _dicaFaltas;
  FormattingService get formattingService => _formattingService;
  
  // Constructor
  FeriasController() {
    // Inicializa com período aquisitivo padrão (12 meses atrás até agora)
    final hoje = DateTime.now();
    _fimAquisitivo = hoje;
    _inicioAquisitivo = DateTime(hoje.year - 1, hoje.month, hoje.day);
    
    fimAquisitivoController.text = _formattingService.formatDate(_fimAquisitivo!);
    inicioAquisitivoController.text = _formattingService.formatDate(_inicioAquisitivo!);
    
    // Inicializa com 30 dias de férias
    diasFeriasController.text = '30';
    
    _updateDiasDireito();
  }
  
  // Validation methods
  String? validateSalario(String? value) => _validationService.validateSalario(value);
  String? validateDiasFerias(String? value) => _validationService.validateDiasFerias(value);
  String? validateFaltas(String? value) => _validationService.validateFaltas(value);
  String? validateDependentes(String? value) => _validationService.validateDependentes(value);
  
  String? validateDataInicio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o início do período aquisitivo';
    }
    
    final data = _formattingService.parseDate(value);
    if (data == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }
    
    return _validationService.validateDataInicio(data);
  }
  
  String? validateDataFim(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o fim do período aquisitivo';
    }
    
    final data = _formattingService.parseDate(value);
    if (data == null) {
      return 'Data inválida (use DD/MM/AAAA)';
    }
    
    return _validationService.validateDataFim(data);
  }
  
  void setAbonoPecuniario(bool value) {
    _abonoPecuniario = value;
    _updateDiasDireito();
    notifyListeners();
  }
  
  void onInicioAquisitivoChanged(String value) {
    _inicioAquisitivo = _formattingService.parseDate(value);
    _updateDiasDireito();
  }
  
  void onFimAquisitivoChanged(String value) {
    _fimAquisitivo = _formattingService.parseDate(value);
    _updateDiasDireito();
  }
  
  void onFaltasChanged(String value) {
    _updateDiasDireito();
  }
  
  void _updateDiasDireito() {
    if (_inicioAquisitivo == null || _fimAquisitivo == null) {
      _diasDireito = 0;
      _dicaFaltas = '';
      return;
    }
    
    final mesesAquisitivos = _calculationService.calcularMesesAquisitivos(
      _inicioAquisitivo!, 
      _fimAquisitivo!,
    );
    
    final faltas = int.tryParse(faltasController.text) ?? 0;
    _diasDireito = _calculationService.calcularDiasDireito(faltas, mesesAquisitivos);
    _dicaFaltas = _validationService.getDicaFaltas(faltas);
    
    notifyListeners();
  }
  
  String getDicaAbonoPecuniario() {
    if (_diasDireito == 0) {
      return 'Sem direito a abono pecuniário';
    }
    
    final diasMaximos = _calculationService.calcularDiasMaximosVenda(_diasDireito);
    if (diasMaximos == 0) {
      return 'Sem dias disponíveis para venda';
    }
    
    return 'Pode vender até $diasMaximos dias';
  }
  
  String getDicaDiasFerias() {
    if (_diasDireito == 0) {
      return 'Sem direito a férias';
    }
    
    final diasVendidos = _abonoPecuniario ? (_diasDireito / 3).floor() : 0;
    final diasDisponiveis = _diasDireito - diasVendidos;
    
    if (diasDisponiveis < CalculationConstants.diasMinimosFerias) {
      return 'Dias insuficientes para férias';
    }
    
    return 'Disponível para gozo: $diasDisponiveis dias';
  }
  
  Future<void> calcular() async {
    _clearError();
    
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Validação adicional do período
    final validacaoPeriodo = _validationService.validatePeriodoAquisitivo(
      _inicioAquisitivo, 
      _fimAquisitivo,
    );
    if (validacaoPeriodo != null) {
      _setError(validacaoPeriodo);
      return;
    }
    
    // Validação dos dias de férias com direito
    final diasFerias = int.tryParse(diasFeriasController.text) ?? 0;
    final validacaoDias = _validationService.validateDiasFeriasComDireito(
      diasFerias, 
      _diasDireito, 
      _abonoPecuniario,
    );
    if (validacaoDias != null) {
      _setError(validacaoDias);
      return;
    }
    
    try {
      _isCalculating = true;
      notifyListeners();
      
      // Simula delay para feedback visual
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Parse values
      final salarioBruto = _formattingService.parseCurrency(salarioBrutoController.text);
      final faltasNaoJustificadas = int.tryParse(faltasController.text) ?? 0;
      final dependentes = int.tryParse(dependentesController.text) ?? 0;
      
      // Calculate
      _model = _calculationService.calculate(
        salarioBruto: salarioBruto,
        inicioAquisitivo: _inicioAquisitivo!,
        fimAquisitivo: _fimAquisitivo!,
        diasFerias: diasFerias,
        faltasNaoJustificadas: faltasNaoJustificadas,
        abonoPecuniario: _abonoPecuniario,
        dependentes: dependentes,
      );
      
      _showResult = true;
      
    } catch (e) {
      _setError('Erro ao calcular férias: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
  
  void limparCampos() {
    salarioBrutoController.clear();
    faltasController.clear();
    dependentesController.clear();
    
    // Reseta datas para padrão
    final hoje = DateTime.now();
    _fimAquisitivo = hoje;
    _inicioAquisitivo = DateTime(hoje.year - 1, hoje.month, hoje.day);
    
    fimAquisitivoController.text = _formattingService.formatDate(_fimAquisitivo!);
    inicioAquisitivoController.text = _formattingService.formatDate(_inicioAquisitivo!);
    
    // Reseta dias de férias
    diasFeriasController.text = '30';
    
    _model = null;
    _showResult = false;
    _abonoPecuniario = false;
    _updateDiasDireito();
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
    inicioAquisitivoController.dispose();
    fimAquisitivoController.dispose();
    diasFeriasController.dispose();
    faltasController.dispose();
    dependentesController.dispose();
    super.dispose();
  }
}
