// Project imports:
import 'despesas_core.dart';

class DespesasValidators {
  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipo é obrigatório';
    }
    if (!DespesasCore.isTipoValid(value)) {
      return 'Tipo inválido';
    }
    return null;
  }

  static String? validateValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor é obrigatório';
    }
    
    final valorStr = value.replaceAll(',', '.');
    final valor = double.tryParse(valorStr);
    
    if (valor == null) {
      return 'Valor deve ser um número válido';
    }
    
    if (!DespesasCore.isValidValor(valor)) {
      return 'Valor deve estar entre R\$ 0,01 e R\$ 99.999,99';
    }
    
    return null;
  }

  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }
    if (!DespesasCore.isValidDescricao(value)) {
      return 'Descrição deve ter no máximo 255 caracteres';
    }
    return null;
  }

  static String? validateObservacao(String? value) {
    if (!DespesasCore.isValidObservacao(value)) {
      return 'Observação deve ter no máximo 500 caracteres';
    }
    return null;
  }

  static String? validateData(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }
    
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    final oneYearFromNow = DateTime(now.year + 1, now.month, now.day);
    
    if (value.isBefore(oneYearAgo)) {
      return 'Data não pode ser anterior a um ano';
    }
    
    if (value.isAfter(oneYearFromNow)) {
      return 'Data não pode ser posterior a um ano';
    }
    
    return null;
  }

  static String? validateAnimalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Animal é obrigatório';
    }
    return null;
  }

  static String sanitizeInput(String? input) {
    if (input == null) return '';
    return input.trim();
  }

  static double? parseValor(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    
    final valorStr = input.replaceAll(',', '.');
    return double.tryParse(valorStr);
  }

  static bool isFormValid({
    required String? tipo,
    required String? valor,
    required String? descricao,
    required DateTime? data,
    required String? animalId,
    String? observacao,
  }) {
    return validateTipo(tipo) == null &&
           validateValor(valor) == null &&
           validateDescricao(descricao) == null &&
           validateData(data) == null &&
           validateAnimalId(animalId) == null &&
           validateObservacao(observacao) == null;
  }

  static Map<String, String?> validateAllFields({
    required String? tipo,
    required String? valor,
    required String? descricao,
    required DateTime? data,
    required String? animalId,
    String? observacao,
  }) {
    return {
      'tipo': validateTipo(tipo),
      'valor': validateValor(valor),
      'descricao': validateDescricao(descricao),
      'data': validateData(data),
      'animalId': validateAnimalId(animalId),
      'observacao': validateObservacao(observacao),
    };
  }

  static String getValidationMessage(String field, String? error) {
    if (error == null) return '';

    final fieldNames = {
      'animalId': 'Animal',
      'tipo': 'Tipo',
      'valor': 'Valor',
      'descricao': 'Descrição',
      'observacao': 'Observação',
      'data': 'Data',
    };

    final fieldName = fieldNames[field] ?? field;
    return '$fieldName: $error';
  }
}
