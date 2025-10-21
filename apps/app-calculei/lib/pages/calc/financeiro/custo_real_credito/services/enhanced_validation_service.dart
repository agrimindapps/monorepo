// Dart imports:
import 'dart:async';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/services/enums/validation_error.dart';

/// Serviço responsável por todas as validações do módulo de custo real de crédito
///
/// Implementa validações individuais, cross-field e validação em tempo real
class ValidationService {
  // Singleton
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Stream controllers para validação em tempo real
  final _currencyValidationController =
      StreamController<ValidationError?>.broadcast();
  final _installmentsValidationController =
      StreamController<ValidationError?>.broadcast();
  final _rateValidationController =
      StreamController<ValidationError?>.broadcast();
  final _crossFieldValidationController =
      StreamController<ValidationError?>.broadcast();

  // Getters para os streams
  Stream<ValidationError?> get currencyValidation =>
      _currencyValidationController.stream;
  Stream<ValidationError?> get installmentsValidation =>
      _installmentsValidationController.stream;
  Stream<ValidationError?> get rateValidation =>
      _rateValidationController.stream;
  Stream<ValidationError?> get crossFieldValidation =>
      _crossFieldValidationController.stream;

  /// Validação de valores monetários com debounce integrado
  String? validateCurrency(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      _currencyValidationController.add(ValidationError.requiredField);
      return ValidationError.requiredField.message;
    }

    // Remove formatação para validação numérica
    String cleanValue = value.replaceAll(RegExp(r'[R$\s.]'), '');
    cleanValue = cleanValue.replaceAll(',', '.');

    final numValue = double.tryParse(cleanValue);
    if (numValue == null) {
      _currencyValidationController.add(ValidationError.invalidCurrency);
      return ValidationError.invalidCurrency.message;
    }

    if (numValue < CalculationConstants.MIN_CURRENCY_VALUE) {
      _currencyValidationController.add(ValidationError.valueTooLow);
      return ValidationError.valueTooLow.message;
    }

    if (numValue > CalculationConstants.MAX_CURRENCY_VALUE) {
      _currencyValidationController.add(ValidationError.valueTooHigh);
      return ValidationError.valueTooHigh.message;
    }

    _currencyValidationController.add(null);
    return null;
  }

  /// Validação de número de parcelas
  String? validateInstallments(String? value) {
    if (value == null || value.isEmpty) {
      _installmentsValidationController.add(ValidationError.requiredField);
      return ValidationError.requiredField.message;
    }

    final numValue = int.tryParse(value);
    if (numValue == null) {
      _installmentsValidationController
          .add(ValidationError.invalidInstallments);
      return ValidationError.invalidInstallments.message;
    }

    if (numValue < CalculationConstants.MIN_INSTALLMENTS) {
      _installmentsValidationController.add(ValidationError.tooFewInstallments);
      return ValidationError.tooFewInstallments.message;
    }

    if (numValue > CalculationConstants.MAX_INSTALLMENTS) {
      _installmentsValidationController
          .add(ValidationError.tooManyInstallments);
      return ValidationError.tooManyInstallments.message;
    }

    _installmentsValidationController.add(null);
    return null;
  }

  /// Validação de taxa de investimento
  String? validateInvestmentRate(String? value) {
    if (value == null || value.isEmpty) {
      _rateValidationController.add(ValidationError.requiredField);
      return ValidationError.requiredField.message;
    }

    // Remove formatação brasileira
    String cleanValue = value.replaceAll(',', '.');
    final numValue = double.tryParse(cleanValue);

    if (numValue == null) {
      _rateValidationController.add(ValidationError.invalidRate);
      return ValidationError.invalidRate.message;
    }

    if (numValue < CalculationConstants.MIN_INVESTMENT_RATE) {
      _rateValidationController.add(ValidationError.rateTooLow);
      return ValidationError.rateTooLow.message;
    }

    if (numValue > CalculationConstants.MAX_INVESTMENT_RATE) {
      _rateValidationController.add(ValidationError.rateTooHigh);
      return ValidationError.rateTooHigh.message;
    }

    _rateValidationController.add(null);
    return null;
  }

  /// Validação de regras de negócio entre campos
  ValidationError? validateBusinessRules({
    required double valorAVista,
    required double valorParcela,
    required int numeroParcelas,
    required double taxaInvestimento,
  }) {
    // Verifica se o valor total parcelado é maior que o valor à vista
    final valorTotalParcelado = valorParcela * numeroParcelas;

    if (valorTotalParcelado <= valorAVista) {
      _crossFieldValidationController.add(ValidationError.totalValueTooLow);
      return ValidationError.totalValueTooLow;
    }

    // Verifica se a diferença é muito pequena (< 1%)
    final diferenca = valorTotalParcelado - valorAVista;
    final percentualDiferenca = (diferenca / valorAVista) * 100;

    if (percentualDiferenca < 1.0) {
      _crossFieldValidationController.add(ValidationError.smallDifference);
      return ValidationError.smallDifference;
    }

    // Verifica se a taxa de investimento é realista para o período
    if (taxaInvestimento > 2.0 && numeroParcelas > 12) {
      _crossFieldValidationController.add(ValidationError.unrealisticRate);
      return ValidationError.unrealisticRate;
    }

    _crossFieldValidationController.add(null);
    return null;
  }

  /// Validação geral de todos os campos
  List<ValidationError> validateAll({
    required String valorAVista,
    required String valorParcela,
    required String numeroParcelas,
    required String taxaInvestimento,
  }) {
    List<ValidationError> errors = [];

    // Validações individuais
    final currencyErrors = [
      validateCurrency(valorAVista, 'valor à vista'),
      validateCurrency(valorParcela, 'valor da parcela'),
    ].where((error) => error != null);
    errors.addAll(currencyErrors.map((e) => ValidationError.invalidCurrency));

    final installmentsError = validateInstallments(numeroParcelas);
    if (installmentsError != null) {
      errors.add(ValidationError.invalidInstallments);
    }

    final rateError = validateInvestmentRate(taxaInvestimento);
    if (rateError != null) {
      errors.add(ValidationError.invalidRate);
    }

    // Se não houver erros básicos, valida regras de negócio
    if (errors.isEmpty) {
      try {
        final numVista = double.parse(valorAVista
            .replaceAll(RegExp(r'[R$\s.]'), '')
            .replaceAll(',', '.'));
        final numParcela = double.parse(valorParcela
            .replaceAll(RegExp(r'[R$\s.]'), '')
            .replaceAll(',', '.'));
        final numRate = double.parse(taxaInvestimento.replaceAll(',', '.'));
        final numInstallments = int.parse(numeroParcelas);

        final businessError = validateBusinessRules(
          valorAVista: numVista,
          valorParcela: numParcela,
          numeroParcelas: numInstallments,
          taxaInvestimento: numRate,
        );

        if (businessError != null) {
          errors.add(businessError);
        }
      } catch (e) {
        errors.add(ValidationError.invalidBusinessLogic);
      }
    }

    return errors;
  }

  void dispose() {
    _currencyValidationController.close();
    _installmentsValidationController.close();
    _rateValidationController.close();
    _crossFieldValidationController.close();
  }
}
