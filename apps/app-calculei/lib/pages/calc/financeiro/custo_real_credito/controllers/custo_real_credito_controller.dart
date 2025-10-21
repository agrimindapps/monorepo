// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/controllers/enums/validation_error.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/controllers/models/custo_real_credito_model.dart';
import 'package:app_calculei/services/calculation_service.dart';
import 'package:app_calculei/services/enhanced_formatting_service.dart';
import 'package:app_calculei/services/enhanced_validation_service.dart';
import 'package:app_calculei/services/optimized_money_formatter.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/controllers/utils/debouncer.dart';

class CustoRealCreditoController extends ChangeNotifier {
  // Injeção de dependência dos services
  final formattingService = FormattingService();
  final validationService = ValidationService();
  final calculationService = CalculationService();

  // Estado e model
  CustoRealCreditoModel? model;
  final formKey = GlobalKey<FormState>();

  // Controllers dos campos
  final valorAVistaController = TextEditingController();
  final valorParcelaController = TextEditingController();
  final numeroParcelasController = TextEditingController();
  final taxaInvestimentoController = TextEditingController();

  // Formatter otimizado com cache e melhor performance
  final formatoMoeda = OptimizedMoneyFormatter();

  // Estado da interface
  bool resultadoVisivel = false;
  String? errorMessage;
  bool hasError = false;
  List<ValidationError> validationErrors = [];
  bool _isCalculating = false;

  // Validação com debounce
  late final Debouncer _validationDebouncer;

  // Getters
  bool get isCalculating => _isCalculating;

  // Streams de validação em tempo real
  Stream<ValidationError?> get currencyValidation =>
      validationService.currencyValidation;
  Stream<ValidationError?> get installmentsValidation =>
      validationService.installmentsValidation;
  Stream<ValidationError?> get rateValidation =>
      validationService.rateValidation;
  Stream<ValidationError?> get crossFieldValidation =>
      validationService.crossFieldValidation;

  CustoRealCreditoController() {
    _initializeControllers();
    _setupValidationListeners();
  }

  void _initializeControllers() {
    numeroParcelasController.text =
        CalculationConstants.DEFAULT_INSTALLMENTS.toString();
    taxaInvestimentoController.text = formattingService
        .formatPercentage(CalculationConstants.DEFAULT_INVESTMENT_RATE);

    // Inicializa o debouncer para validação
    _validationDebouncer = Debouncer(
      delay: const Duration(milliseconds: 300),
      onValue: () => _validateForm(),
    );
  }

  void _setupValidationListeners() {
    valorAVistaController.addListener(() {
      if (valorAVistaController.text.isNotEmpty) {
        _validationDebouncer.value = true;
      }
    });

    valorParcelaController.addListener(() {
      if (valorParcelaController.text.isNotEmpty) {
        _validationDebouncer.value = true;
      }
    });

    numeroParcelasController.addListener(() {
      if (numeroParcelasController.text.isNotEmpty) {
        _validationDebouncer.value = true;
      }
    });

    taxaInvestimentoController.addListener(() {
      if (taxaInvestimentoController.text.isNotEmpty) {
        _validationDebouncer.value = true;
      }
    });
  }

  void _validateForm() {
    if (valorAVistaController.text.isNotEmpty) {
      validationService.validateCurrency(
          valorAVistaController.text, 'valor à vista');
    }

    if (valorParcelaController.text.isNotEmpty) {
      validationService.validateCurrency(
          valorParcelaController.text, 'valor da parcela');
    }

    if (numeroParcelasController.text.isNotEmpty) {
      validationService.validateInstallments(numeroParcelasController.text);
    }

    if (taxaInvestimentoController.text.isNotEmpty) {
      validationService.validateInvestmentRate(taxaInvestimentoController.text);
    }

    // Cross-field validation
    if (formKey.currentState?.validate() ?? false) {
      _validateBusinessRules();
    }
  }

  void _validateBusinessRules() {
    try {
      final valorAVista =
          formatoMoeda.getUnmaskedDouble(valorAVistaController.text);
      final valorParcela =
          formatoMoeda.getUnmaskedDouble(valorParcelaController.text);
      final numeroParcelas = int.parse(numeroParcelasController.text);
      final taxaInvestimento =
          formattingService.parsePercentage(taxaInvestimentoController.text);

      validationService.validateBusinessRules(
        valorAVista: valorAVista,
        valorParcela: valorParcela,
        numeroParcelas: numeroParcelas,
        taxaInvestimento: taxaInvestimento,
      );
    } catch (e) {
      // Ignore parsing errors during live validation
    }
  }

  /// Limpa o estado de erro
  void clearError() {
    errorMessage = null;
    hasError = false;
    validationErrors.clear();
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void setError(String message) {
    errorMessage = message;
    hasError = true;
    notifyListeners();
  }

  Future<void> calcular() async {
    clearError();
    if (!formKey.currentState!.validate()) return;

    try {
      _isCalculating = true;
      notifyListeners();

      // Validação completa de todos os campos
      validationErrors = validationService.validateAll(
        valorAVista: valorAVistaController.text,
        valorParcela: valorParcelaController.text,
        numeroParcelas: numeroParcelasController.text,
        taxaInvestimento: taxaInvestimentoController.text,
      );

      if (validationErrors.isNotEmpty) {
        setError(validationErrors.map((e) => e.message).join('\n'));
        return;
      }

      // Simula um pequeno delay para feedback visual
      await Future.delayed(const Duration(milliseconds: 300));

      // Extrai valores dos controllers usando o serviço de formatação
      final valorAVista =
          formatoMoeda.getUnmaskedDouble(valorAVistaController.text);
      final valorParcela =
          formatoMoeda.getUnmaskedDouble(valorParcelaController.text);
      final numeroParcelas = int.parse(numeroParcelasController.text);
      final taxaInvestimento =
          formattingService.parsePercentage(taxaInvestimentoController.text);

      // Executa cálculo usando o serviço
      model = calculationService.calculate(
        valorAVista: valorAVista,
        valorParcela: valorParcela,
        numeroParcelas: numeroParcelas,
        taxaInvestimento: taxaInvestimento,
      );

      resultadoVisivel = true;
      notifyListeners();
    } catch (e) {
      setError('Erro ao realizar o cálculo: ${e.toString()}');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  void limparCampos() {
    clearError();
    valorAVistaController.clear();
    valorParcelaController.clear();
    numeroParcelasController.text =
        CalculationConstants.DEFAULT_INSTALLMENTS.toString();
    taxaInvestimentoController.text = formattingService
        .formatPercentage(CalculationConstants.DEFAULT_INVESTMENT_RATE);
    resultadoVisivel = false;
    model = null;
    notifyListeners();
  }

  @override
  void dispose() {
    valorAVistaController.dispose();
    valorParcelaController.dispose();
    numeroParcelasController.dispose();
    taxaInvestimentoController.dispose();
    validationService.dispose();
    formatoMoeda.dispose();
    _validationDebouncer.dispose();
    super.dispose();
  }
}
