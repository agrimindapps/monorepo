

/// Validation Service - Sistema completo de validação de dados
/// 
/// Funcionalidades:
/// - Validações comuns (email, CPF, CNPJ, telefone)
/// - Validadores customizados
/// - Composição de validadores
/// - Validação de formulários
/// - Validação assíncrona
/// - Internacionalização de mensagens
/// - Validação condicional
/// - Sanitização de dados
class ValidationService {
  static final _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  static final _phonePattern = RegExp(
    r'^\+?[\d\s\-\(\)]{8,}$'
  );
  
  static final _strongPasswordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]'
  );
  static const Map<String, String> _defaultMessages = {
    'required': 'Este campo é obrigatório',
    'email': 'Email inválido',
    'cpf': 'CPF inválido',
    'cnpj': 'CNPJ inválido',
    'phone': 'Telefone inválido',
    'minLength': 'Deve ter pelo menos {min} caracteres',
    'maxLength': 'Deve ter no máximo {max} caracteres',
    'min': 'Deve ser maior ou igual a {min}',
    'max': 'Deve ser menor ou igual a {max}',
    'pattern': 'Formato inválido',
    'strongPassword': 'Senha deve ter pelo menos 8 caracteres, incluindo maiúscula, minúscula, número e símbolo',
    'passwordMatch': 'Senhas não coincidem',
    'url': 'URL inválida',
    'date': 'Data inválida',
    'dateRange': 'Data deve estar entre {start} e {end}',
    'numeric': 'Deve ser um número',
    'integer': 'Deve ser um número inteiro',
    'positive': 'Deve ser positivo',
    'negative': 'Deve ser negativo',
  };

  static Map<String, String> _messages = Map.from(_defaultMessages);

  /// Configura mensagens customizadas
  static void configureMessages(Map<String, String> customMessages) {
    _messages = {..._defaultMessages, ...customMessages};
  }

  /// Obtém mensagem formatada
  static String _getMessage(String key, [Map<String, dynamic>? params]) {
    String message = _messages[key] ?? key;
    
    if (params != null) {
      params.forEach((key, value) {
        message = message.replaceAll('{$key}', value.toString());
      });
    }
    
    return message;
  }

  /// Validador obrigatório
  static Validator<String> required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.error(
          message ?? _getMessage('required'),
        );
      }
      return ValidationResult.valid();
    };
  }

  /// Validador de email
  static Validator<String> email([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid(); // Use required() para obrigatório
      }
      
      if (!_emailPattern.hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('email'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de CPF
  static Validator<String> cpf([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      final cleanCpf = value.replaceAll(RegExp(r'\D'), '');
      
      if (!_isValidCpf(cleanCpf)) {
        return ValidationResult.error(
          message ?? _getMessage('cpf'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de CNPJ
  static Validator<String> cnpj([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      final cleanCnpj = value.replaceAll(RegExp(r'\D'), '');
      
      if (!_isValidCnpj(cleanCnpj)) {
        return ValidationResult.error(
          message ?? _getMessage('cnpj'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de telefone
  static Validator<String> phone([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (!_phonePattern.hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('phone'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de comprimento mínimo
  static Validator<String> minLength(int min, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (value.length < min) {
        return ValidationResult.error(
          message ?? _getMessage('minLength', {'min': min}),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de comprimento máximo
  static Validator<String> maxLength(int max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (value.length > max) {
        return ValidationResult.error(
          message ?? _getMessage('maxLength', {'max': max}),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de valor mínimo
  static Validator<num> min(num minValue, [String? message]) {
    return (value) {
      if (value == null) {
        return ValidationResult.valid();
      }
      
      if (value < minValue) {
        return ValidationResult.error(
          message ?? _getMessage('min', {'min': minValue}),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de valor máximo
  static Validator<num> max(num maxValue, [String? message]) {
    return (value) {
      if (value == null) {
        return ValidationResult.valid();
      }
      
      if (value > maxValue) {
        return ValidationResult.error(
          message ?? _getMessage('max', {'max': maxValue}),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de padrão regex
  static Validator<String> pattern(RegExp pattern, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (!pattern.hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('pattern'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de senha forte
  static Validator<String> strongPassword([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (value.length < 8) {
        return ValidationResult.error(
          message ?? _getMessage('strongPassword'),
        );
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('strongPassword'),
        );
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('strongPassword'),
        );
      }
      if (!RegExp(r'\d').hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('strongPassword'),
        );
      }
      if (!RegExp(r'[@$!%*?&]').hasMatch(value)) {
        return ValidationResult.error(
          message ?? _getMessage('strongPassword'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de confirmação de senha
  static Validator<String> passwordConfirmation(String originalPassword, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (value != originalPassword) {
        return ValidationResult.error(
          message ?? _getMessage('passwordMatch'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de URL
  static Validator<String> url([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      try {
        final uri = Uri.parse(value);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          throw const FormatException();
        }
        return ValidationResult.valid();
      } catch (e) {
        return ValidationResult.error(
          message ?? _getMessage('url'),
        );
      }
    };
  }

  /// Validador numérico
  static Validator<String> numeric([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (double.tryParse(value) == null) {
        return ValidationResult.error(
          message ?? _getMessage('numeric'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de inteiro
  static Validator<String> integer([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      if (int.tryParse(value) == null) {
        return ValidationResult.error(
          message ?? _getMessage('integer'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador positivo
  static Validator<num> positive([String? message]) {
    return (value) {
      if (value == null) {
        return ValidationResult.valid();
      }
      
      if (value <= 0) {
        return ValidationResult.error(
          message ?? _getMessage('positive'),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Validador de data
  static Validator<String> date([String? message]) {
    return (value) {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      try {
        DateTime.parse(value);
        return ValidationResult.valid();
      } catch (e) {
        return ValidationResult.error(
          message ?? _getMessage('date'),
        );
      }
    };
  }

  /// Validador de faixa de datas
  static Validator<DateTime> dateRange(DateTime start, DateTime end, [String? message]) {
    return (value) {
      if (value == null) {
        return ValidationResult.valid();
      }
      
      if (value.isBefore(start) || value.isAfter(end)) {
        return ValidationResult.error(
          message ?? _getMessage('dateRange', {
            'start': start.toIso8601String().split('T')[0],
            'end': end.toIso8601String().split('T')[0],
          }),
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Combina múltiplos validadores com AND
  static Validator<T> combine<T>(List<Validator<T>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (!result.isValid) {
          return result;
        }
      }
      return ValidationResult.valid();
    };
  }

  /// Aplica validador apenas se condição for verdadeira
  static Validator<T> when<T>(bool condition, Validator<T> validator) {
    return (value) {
      if (!condition) {
        return ValidationResult.valid();
      }
      return validator(value);
    };
  }

  /// Aplica validador apenas se função de condição retornar true
  static Validator<T> whenFunction<T>(bool Function(T? value) condition, Validator<T> validator) {
    return (value) {
      if (!condition(value)) {
        return ValidationResult.valid();
      }
      return validator(value);
    };
  }

  /// Valida um mapa de campos
  static ValidationResult validateForm(Map<String, dynamic> data, Map<String, List<Validator>> rules) {
    final errors = <String, List<String>>{};
    
    for (final entry in rules.entries) {
      final fieldName = entry.key;
      final validators = entry.value;
      final value = data[fieldName];
      
      final fieldErrors = <String>[];
      
      for (final validator in validators) {
        final result = validator(value);
        if (!result.isValid) {
          fieldErrors.addAll(result.errors);
        }
      }
      
      if (fieldErrors.isNotEmpty) {
        errors[fieldName] = fieldErrors;
      }
    }
    
    if (errors.isEmpty) {
      return ValidationResult.valid();
    }
    
    return ValidationResult.errorWithFields(errors);
  }

  /// Sanitiza string removendo caracteres especiais
  static String sanitizeString(String input, {bool allowSpaces = true}) {
    if (allowSpaces) {
      return input.replaceAll(RegExp(r'[^\w\s]'), '');
    } else {
      return input.replaceAll(RegExp(r'[^\w]'), '');
    }
  }

  /// Sanitiza email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitiza telefone
  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Sanitiza CPF/CNPJ
  static String sanitizeDocument(String document) {
    return document.replaceAll(RegExp(r'\D'), '');
  }

  /// Sanitiza URL
  static String sanitizeUrl(String url) {
    url = url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  /// Validador assíncrono customizado
  static AsyncValidator<T> asyncCustom<T>(
    Future<ValidationResult> Function(T? value) validator
  ) {
    return validator;
  }

  /// Validador assíncrono de email único (exemplo)
  static AsyncValidator<String> uniqueEmail(
    Future<bool> Function(String email) checkUnique,
    [String? message]
  ) {
    return (value) async {
      if (value == null || value.isEmpty) {
        return ValidationResult.valid();
      }
      
      final isUnique = await checkUnique(value);
      if (!isUnique) {
        return ValidationResult.error(
          message ?? 'Este email já está em uso',
        );
      }
      
      return ValidationResult.valid();
    };
  }

  /// Valida formulário com validadores assíncronos
  static Future<ValidationResult> validateFormAsync(
    Map<String, dynamic> data,
    Map<String, List<Validator>> syncRules,
    [Map<String, List<AsyncValidator>>? asyncRules]
  ) async {
    final syncResult = validateForm(data, syncRules);
    if (!syncResult.isValid) {
      return syncResult;
    }
    if (asyncRules == null || asyncRules.isEmpty) {
      return syncResult;
    }
    final errors = <String, List<String>>{};
    
    for (final entry in asyncRules.entries) {
      final fieldName = entry.key;
      final validators = entry.value;
      final value = data[fieldName];
      
      final fieldErrors = <String>[];
      
      for (final validator in validators) {
        final result = await validator(value);
        if (!result.isValid) {
          fieldErrors.addAll(result.errors);
        }
      }
      
      if (fieldErrors.isNotEmpty) {
        errors[fieldName] = fieldErrors;
      }
    }
    
    if (errors.isEmpty) {
      return ValidationResult.valid();
    }
    
    return ValidationResult.errorWithFields(errors);
  }

  static bool _isValidCpf(String cpf) {
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;
    
    if (int.parse(cpf[9]) != firstDigit) return false;
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;
    
    return int.parse(cpf[10]) == secondDigit;
  }

  static bool _isValidCnpj(String cnpj) {
    if (cnpj.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) return false;
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;
    
    if (int.parse(cnpj[12]) != firstDigit) return false;
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;
    
    return int.parse(cnpj[13]) == secondDigit;
  }
}

/// Tipo de função validadora
typedef Validator<T> = ValidationResult Function(T? value);

/// Tipo de função validadora assíncrona
typedef AsyncValidator<T> = Future<ValidationResult> Function(T? value);

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, List<String>>? fieldErrors;

  ValidationResult._(this.isValid, this.errors, this.fieldErrors);

  /// Cria resultado válido
  factory ValidationResult.valid() {
    return ValidationResult._(true, [], null);
  }

  /// Cria resultado com erro
  factory ValidationResult.error(String error) {
    return ValidationResult._(false, [error], null);
  }

  /// Cria resultado com múltiplos erros
  factory ValidationResult.errors(List<String> errors) {
    return ValidationResult._(false, errors, null);
  }

  /// Cria resultado com erros por campo
  factory ValidationResult.errorWithFields(Map<String, List<String>> fieldErrors) {
    final allErrors = <String>[];
    for (final errors in fieldErrors.values) {
      allErrors.addAll(errors);
    }
    return ValidationResult._(false, allErrors, fieldErrors);
  }

  /// Primeiro erro (se houver)
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Verifica se tem erros para um campo específico
  bool hasFieldError(String field) {
    return fieldErrors?.containsKey(field) ?? false;
  }

  /// Obtém erros de um campo específico
  List<String> getFieldErrors(String field) {
    return fieldErrors?[field] ?? [];
  }

  /// Primeiro erro de um campo específico
  String? getFirstFieldError(String field) {
    final errors = getFieldErrors(field);
    return errors.isNotEmpty ? errors.first : null;
  }

  @override
  String toString() {
    if (isValid) return 'ValidationResult: Valid';
    return 'ValidationResult: Invalid - ${errors.join(', ')}';
  }
}

/// Classe auxiliar para builder de validações
class ValidationBuilder<T> {
  final List<Validator<T>> _validators = [];

  /// Adiciona validador
  ValidationBuilder<T> add(Validator<T> validator) {
    _validators.add(validator);
    return this;
  }

  /// Adiciona validador condicional
  ValidationBuilder<T> addIf(bool condition, Validator<T> validator) {
    if (condition) {
      _validators.add(validator);
    }
    return this;
  }

  /// Constrói validador final
  Validator<T> build() {
    return ValidationService.combine(_validators);
  }

  /// Valida diretamente
  ValidationResult validate(T? value) {
    return build()(value);
  }
}
