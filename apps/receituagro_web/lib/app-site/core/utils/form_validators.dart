import 'dart:async';

/// Sistema de validação robusta para formulários
class FormValidators {
  /// Regex para caracteres alfanuméricos com acentos e espaços
  static final RegExp _alphanumericWithAccents =
      RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\.]+$');

  /// Regex para nomes científicos (permite letras, espaços, hífen e ponto)
  static final RegExp _scientificName = RegExp(r'^[a-zA-Z\s\-\.]+$');

  /// Regex para caracteres perigosos que devem ser removidos
  static final RegExp _dangerousChars = RegExp(r'[<>"&%$#@!*()[\]{}|\\~`^=+]');

  /// Limites de tamanho para diferentes tipos de campo
  static const int _maxCulturaLength = 100;
  static const int _maxNomeLength = 200;
  static const int _maxTipoLength = 50;
  static const int _minLength = 2;

  /// Debounce timer para validação em tempo real
  static Timer? _debounceTimer;

  /// Validador para campo de cultura
  static String? validateCultura(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome da cultura é obrigatório';
    }

    String sanitized = sanitizeInput(value);

    if (sanitized.length < _minLength) {
      return 'Nome da cultura deve ter pelo menos $_minLength caracteres';
    }

    if (sanitized.length > _maxCulturaLength) {
      return 'Nome da cultura deve ter no máximo $_maxCulturaLength caracteres';
    }

    if (!_alphanumericWithAccents.hasMatch(sanitized)) {
      return 'Nome da cultura contém caracteres não permitidos';
    }

    return null;
  }

  /// Validador para nome comum de praga
  static String? validateNomeComum(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome comum é obrigatório';
    }

    String sanitized = sanitizeInput(value);

    if (sanitized.length < _minLength) {
      return 'Nome comum deve ter pelo menos $_minLength caracteres';
    }

    if (sanitized.length > _maxNomeLength) {
      return 'Nome comum deve ter no máximo $_maxNomeLength caracteres';
    }

    if (!_alphanumericWithAccents.hasMatch(sanitized)) {
      return 'Nome comum contém caracteres não permitidos';
    }

    return null;
  }

  /// Validador para nome científico
  static String? validateNomeCientifico(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome científico é obrigatório';
    }

    String sanitized = sanitizeInput(value);

    if (sanitized.length < _minLength) {
      return 'Nome científico deve ter pelo menos $_minLength caracteres';
    }

    if (sanitized.length > _maxNomeLength) {
      return 'Nome científico deve ter no máximo $_maxNomeLength caracteres';
    }

    if (!_scientificName.hasMatch(sanitized)) {
      return 'Nome científico deve conter apenas letras, espaços, hífen e ponto';
    }

    // Validação adicional para formato de nome científico
    if (!_isValidScientificNameFormat(sanitized)) {
      return 'Nome científico deve seguir o formato: Genus species';
    }

    return null;
  }

  /// Validador para tipo de praga
  static String? validateTipoPraga(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional
    }

    String sanitized = sanitizeInput(value);

    if (sanitized.length > _maxTipoLength) {
      return 'Tipo de praga deve ter no máximo $_maxTipoLength caracteres';
    }

    if (!_alphanumericWithAccents.hasMatch(sanitized)) {
      return 'Tipo de praga contém caracteres não permitidos';
    }

    return null;
  }

  /// Validador para status numérico
  static String? validateStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Status é obrigatório';
    }

    final int? status = int.tryParse(value);
    if (status == null) {
      return 'Status deve ser um número válido';
    }

    if (status < 0 || status > 1) {
      return 'Status deve ser 0 (inativo) ou 1 (ativo)';
    }

    return null;
  }

  /// Sanitiza entrada removendo caracteres perigosos
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(_dangerousChars, '');
  }

  /// Valida formato de nome científico básico
  static bool _isValidScientificNameFormat(String name) {
    // Verifica se tem pelo menos duas palavras (gênero e espécie)
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 && parts.every((part) => part.isNotEmpty);
  }

  /// Função para validação em tempo real com debounce
  static void validateWithDebounce(String value, Function(String?) onValidation,
      String? Function(String?) validator) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      onValidation(validator(value));
    });
  }

  /// Verifica se há duplicatas em uma lista
  static bool checkDuplicate(String value, List<String> existingValues) {
    return existingValues.any((existing) =>
        existing.toLowerCase().trim() == value.toLowerCase().trim());
  }

  /// Mensagem de erro para duplicatas
  static String getDuplicateErrorMessage(String fieldName) {
    return '$fieldName já existe. Por favor, escolha outro nome.';
  }

  /// Limpa o debounce timer
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}

/// Extension para facilitar uso em TextFormField
extension TextFormFieldValidation on String? {
  String? validateCultura() => FormValidators.validateCultura(this);
  String? validateNomeComum() => FormValidators.validateNomeComum(this);
  String? validateNomeCientifico() =>
      FormValidators.validateNomeCientifico(this);
  String? validateTipoPraga() => FormValidators.validateTipoPraga(this);
  String? validateStatus() => FormValidators.validateStatus(this);
}
