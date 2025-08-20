// Project imports:
import '../../../../../../app-petiveti/utils/despesas_utils.dart';
import '../../../../utils/format_utils.dart';

/// Consolidated validators that delegate to centralized DespesasUtils
/// Replaces despesa_form_validators.dart with centralized approach
class DespesaFormValidators {
  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Animal deve ser selecionado';
    }
    return null;
  }

  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipo é obrigatório';
    }

    if (!DespesasUtils.isTipoValid(value.trim())) {
      return 'Tipo de despesa inválido';
    }

    return null;
  }

  static String? validateDescricao(String? value) {
    if (value != null && !DespesasUtils.isValidDescriptionLength(value)) {
      return 'Descrição muito longa (máx. 255 caracteres)';
    }

    if (value != null &&
        value.trim().isNotEmpty &&
        value.trim().length < 2) {
      return 'Descrição muito curta (mín. 2 caracteres)';
    }

    return null;
  }

  static String? validateValor(double? value) {
    if (value == null || value <= 0) {
      return 'Valor deve ser maior que zero';
    }

    if (!DespesasUtils.isValidValor(value)) {
      return 'Valor deve estar entre R\$ 0,01 e R\$ 99.999,99';
    }

    return null;
  }

  static String? validateDataDespesa(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }

    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final oneYearFromNow = now.add(const Duration(days: 365));

    if (value.isBefore(oneYearAgo)) {
      return 'Data não pode ser anterior a 1 ano';
    }

    if (value.isAfter(oneYearFromNow)) {
      return 'Data não pode ser posterior a 1 ano';
    }

    return null;
  }

  static bool isFormValid({
    required String animalId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime dataDespesa,
  }) {
    return validateAnimalId(animalId) == null &&
        validateTipo(tipo) == null &&
        validateDescricao(descricao) == null &&
        validateValor(valor) == null &&
        validateDataDespesa(dataDespesa) == null;
  }

  static Map<String, String?> validateAllFields({
    required String animalId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime dataDespesa,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'tipo': validateTipo(tipo),
      'descricao': validateDescricao(descricao),
      'valor': validateValor(valor),
      'dataDespesa': validateDataDespesa(dataDespesa),
    };
  }

  // Delegated functions to centralized utils
  static bool isValidAnimalId(String animalId) {
    return animalId.trim().isNotEmpty;
  }

  static bool isValidTipo(String tipo) => DespesasUtils.isTipoValid(tipo);
  static bool isValidDescricao(String descricao) => DespesasUtils.isValidDescricao(descricao);
  static bool isValidValor(double valor) => DespesasUtils.isValidValor(valor);

  static bool isValidDataDespesa(DateTime dataDespesa) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final oneYearFromNow = now.add(const Duration(days: 365));

    return !dataDespesa.isBefore(oneYearAgo) &&
        !dataDespesa.isAfter(oneYearFromNow);
  }

  // Delegate to FormatUtils for consistency
  static String sanitizeDescricao(String descricao) => FormatUtils.sanitizeText(descricao);
  static String sanitizeTipo(String tipo) => tipo.trim();
  static double sanitizeValor(double valor) => double.parse(valor.toStringAsFixed(2));
  static String formatValorForDisplay(double valor) => FormatUtils.formatValor(valor);
  static String formatValorWithCurrency(double valor) => FormatUtils.formatValorComMoeda(valor);

  static double? parseValorFromString(String valorString) {
    final parsed = FormatUtils.parseValor(valorString);
    return parsed == 0.0 ? null : parsed;
  }

  static String? validateValorString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor é obrigatório';
    }

    final parsedValue = parseValorFromString(value);
    if (parsedValue == null) {
      return 'Formato de valor inválido';
    }

    return validateValor(parsedValue);
  }

  // Delegate to DespesasUtils for consistency
  static List<String> getValidTipos() => DespesasUtils.getAvailableTipos();
  static bool isTipoValid(String tipo) => DespesasUtils.isTipoValid(tipo);
  static String? getDefaultTipo() => DespesasUtils.getDefaultTipo();

  static DateTime getValidDateRange() {
    return DateTime.now();
  }

  static DateTime getMinValidDate() {
    return DateTime.now().subtract(const Duration(days: 365));
  }

  static DateTime getMaxValidDate() {
    return DateTime.now().add(const Duration(days: 365));
  }

  static bool isDateInValidRange(DateTime date) {
    final min = getMinValidDate();
    final max = getMaxValidDate();
    return !date.isBefore(min) && !date.isAfter(max);
  }

  // Delegate to DespesasUtils for consistency
  static String formatDateForDisplay(DateTime date) => DespesasUtils.formatData(date);
  static DateTime? parseDateFromString(String dateString) => DespesasUtils.parseData(dateString);

  static String? validateDateString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Data é obrigatória';
    }

    final parsedDate = parseDateFromString(value);
    if (parsedDate == null) {
      return 'Formato de data inválido (dd/mm/aaaa)';
    }

    return validateDataDespesa(parsedDate);
  }

  static List<String> getAllValidationErrors({
    required String animalId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime dataDespesa,
  }) {
    final errors = <String>[];
    final validation = validateAllFields(
      animalId: animalId,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      dataDespesa: dataDespesa,
    );

    validation.forEach((field, error) {
      if (error != null) {
        errors.add('$field: $error');
      }
    });

    return errors;
  }

  static bool hasAnyValidationError({
    required String animalId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime dataDespesa,
  }) {
    final errors = validateAllFields(
      animalId: animalId,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      dataDespesa: dataDespesa,
    );

    return errors.values.any((error) => error != null);
  }

  static String formatValidationError(String fieldName, String? error) {
    if (error == null) return '';
    return '$fieldName: $error';
  }

  static Map<String, dynamic> getFieldConstraints() {
    return {
      'animalId': {
        'required': true,
        'type': 'string',
      },
      'tipo': {
        'required': true,
        'type': 'string',
        'options': DespesasUtils.getAvailableTipos(),
      },
      'descricao': {
        'required': false,
        'type': 'string',
        'maxLength': 255,
        'minLength': 2,
      },
      'valor': {
        'required': true,
        'type': 'double',
        'min': 0.01,
        'max': 99999.99,
      },
      'dataDespesa': {
        'required': true,
        'type': 'datetime',
        'min': getMinValidDate().toIso8601String(),
        'max': getMaxValidDate().toIso8601String(),
      },
    };
  }
}
