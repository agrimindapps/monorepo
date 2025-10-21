/// Serviço responsável por validações de entrada e regras de negócio
///
/// Centraliza toda a lógica de validação, garantindo consistência
/// e facilitando manutenção das regras de validação.
library;

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';

class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  /// Valida se um campo obrigatório está preenchido
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Insira $fieldName';
    }
    return null;
  }

  /// Valida valores monetários
  String? validateCurrency(String? value, String fieldName) {
    // Primeiro verifica se está preenchido
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    // Remove formatação para validação numérica
    String cleanValue = value!.replaceAll(RegExp(r'[R$\s.]'), '');
    cleanValue = cleanValue.replaceAll(',', '.');

    final numValue = double.tryParse(cleanValue);
    if (numValue == null) {
      return '$fieldName deve ser um valor válido';
    }

    if (numValue < CalculationConstants.MIN_CURRENCY_VALUE) {
      return '$fieldName deve ser maior que R\$ ${CalculationConstants.MIN_CURRENCY_VALUE.toStringAsFixed(2)}';
    }

    if (numValue > CalculationConstants.MAX_CURRENCY_VALUE) {
      return '$fieldName deve ser menor que R\$ ${CalculationConstants.MAX_CURRENCY_VALUE.toStringAsFixed(0)}';
    }

    return null;
  }

  /// Valida número de parcelas
  String? validateInstallments(String? value) {
    final requiredError = validateRequired(value, 'o número de parcelas');
    if (requiredError != null) return requiredError;

    final numValue = int.tryParse(value!);
    if (numValue == null) {
      return 'Número de parcelas deve ser um valor inteiro';
    }

    if (numValue < CalculationConstants.MIN_INSTALLMENTS) {
      return 'Número de parcelas deve ser no mínimo ${CalculationConstants.MIN_INSTALLMENTS}';
    }

    if (numValue > CalculationConstants.MAX_INSTALLMENTS) {
      return 'Número de parcelas deve ser no máximo ${CalculationConstants.MAX_INSTALLMENTS}';
    }

    return null;
  }

  /// Valida taxa de investimento
  String? validateInvestmentRate(String? value) {
    final requiredError = validateRequired(value, 'a taxa de juros');
    if (requiredError != null) return requiredError;

    // Remove formatação brasileira
    String cleanValue = value!.replaceAll(',', '.');
    final numValue = double.tryParse(cleanValue);

    if (numValue == null) {
      return 'Taxa de juros deve ser um valor válido';
    }

    if (numValue < CalculationConstants.MIN_INVESTMENT_RATE) {
      return 'Taxa de juros deve ser no mínimo ${CalculationConstants.MIN_INVESTMENT_RATE}%';
    }

    if (numValue > CalculationConstants.MAX_INVESTMENT_RATE) {
      return 'Taxa de juros deve ser no máximo ${CalculationConstants.MAX_INVESTMENT_RATE}%';
    }

    return null;
  }

  /// Valida regras de negócio entre campos relacionados
  String? validateBusinessRules({
    required double valorAVista,
    required double valorParcela,
    required int numeroParcelas,
  }) {
    // Verifica se o valor total parcelado é maior que o valor à vista
    final valorTotalParcelado = valorParcela * numeroParcelas;

    if (valorTotalParcelado <= valorAVista) {
      return 'O valor total parcelado deve ser maior que o valor à vista para que a análise faça sentido';
    }

    // Verifica se a diferença é muito pequena (< 1%)
    final diferenca = valorTotalParcelado - valorAVista;
    final percentualDiferenca = (diferenca / valorAVista) * 100;

    if (percentualDiferenca < 1.0) {
      return 'A diferença entre parcelado e à vista é muito pequena (< 1%). Verifique os valores inseridos';
    }

    return null;
  }

  /// Valida se todos os campos estão preenchidos e válidos
  List<String> validateAllFields({
    required String valorAVista,
    required String valorParcela,
    required String numeroParcelas,
    required String taxaInvestimento,
  }) {
    List<String> errors = [];

    // Validações individuais
    final valorAVistaError = validateCurrency(valorAVista, 'o valor à vista');
    if (valorAVistaError != null) errors.add(valorAVistaError);

    final valorParcelaError =
        validateCurrency(valorParcela, 'o valor da parcela');
    if (valorParcelaError != null) errors.add(valorParcelaError);

    final numeroParcelasError = validateInstallments(numeroParcelas);
    if (numeroParcelasError != null) errors.add(numeroParcelasError);

    final taxaInvestimentoError = validateInvestmentRate(taxaInvestimento);
    if (taxaInvestimentoError != null) errors.add(taxaInvestimentoError);

    return errors;
  }
}
