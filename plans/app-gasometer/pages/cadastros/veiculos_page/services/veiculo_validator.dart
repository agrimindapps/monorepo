// Project imports:
import '../../../../database/21_veiculos_model.dart';

/// Validador robusto para dados de veículos
///
/// Implementa validação em múltiplas camadas com sanitização de entrada
/// e proteção contra ataques de injection. Todas as validações são executadas
/// antes da persistência no repositório.
class VeiculoValidator {
  VeiculoValidator._();

  /// ========================================
  /// VALIDATION RESULTS
  /// ========================================

  /// Resultado da validação
  static const String validationPassed = 'VALIDATION_PASSED';

  /// ========================================
  /// PUBLIC VALIDATION METHODS
  /// ========================================

  /// Valida dados completos do veículo antes da persistência
  static ValidationResult validateVehicleData(VeiculoCar veiculo) {
    final errors = <String>[];
    final warnings = <String>[];

    // Sanitizar dados de entrada primeiro
    final sanitizedVeiculo = _sanitizeVehicleInput(veiculo);

    // Validações críticas de segurança
    errors.addAll(_validateSecurityConstraints(sanitizedVeiculo));

    // Validações de campos obrigatórios
    errors.addAll(_validateRequiredFields(sanitizedVeiculo));

    // Validações de formato e tipo
    errors.addAll(_validateFieldFormats(sanitizedVeiculo));

    // Validações de regras de negócio
    errors.addAll(_validateBusinessRules(sanitizedVeiculo));

    // Validações de integridade de dados
    warnings.addAll(_validateDataIntegrity(sanitizedVeiculo));

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      sanitizedVehicle: sanitizedVeiculo,
    );
  }

  /// Validação rápida para campos críticos apenas
  static ValidationResult validateCriticalFields(VeiculoCar veiculo) {
    final errors = <String>[];

    // Sanitizar dados críticos
    final sanitizedVeiculo = _sanitizeVehicleInput(veiculo);

    // Apenas validações essenciais
    errors.addAll(_validateSecurityConstraints(sanitizedVeiculo));
    errors.addAll(_validateRequiredFields(sanitizedVeiculo));

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: [],
      sanitizedVehicle: sanitizedVeiculo,
    );
  }

  /// ========================================
  /// INPUT SANITIZATION
  /// ========================================

  /// Sanitiza entrada para prevenir injection attacks
  static VeiculoCar _sanitizeVehicleInput(VeiculoCar veiculo) {
    return VeiculoCar(
      id: _sanitizeString(veiculo.id),
      createdAt: veiculo.createdAt,
      updatedAt: veiculo.updatedAt,
      marca: _sanitizeString(veiculo.marca),
      modelo: _sanitizeString(veiculo.modelo),
      ano: _sanitizeInteger(veiculo.ano),
      placa: _sanitizePlaca(veiculo.placa),
      odometroInicial: _sanitizeDouble(veiculo.odometroInicial),
      combustivel: _sanitizeInteger(veiculo.combustivel),
      renavan: _sanitizeAlphanumeric(veiculo.renavan),
      chassi: _sanitizeAlphanumeric(veiculo.chassi),
      cor: _sanitizeString(veiculo.cor),
      vendido: veiculo.vendido,
      valorVenda: _sanitizeDouble(veiculo.valorVenda),
      odometroAtual: _sanitizeDouble(veiculo.odometroAtual),
    );
  }

  /// Sanitiza strings removendo caracteres perigosos
  static String _sanitizeString(String input) {
    if (input.isEmpty) return input;

    // Remover caracteres de controle e potencialmente perigosos
    String sanitized = input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Caracteres de controle
        .replaceAll(RegExp(r'[<>"' "']"), '') // HTML/SQL injection básicos
        .replaceAll(RegExp(r'[\$\{\}]'), '') // Template injection
        .replaceAll(RegExp(r'[;]'), '') // SQL injection
        .trim();

    // Limitar tamanho para prevenir buffer overflow
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    return sanitized;
  }

  /// Sanitiza números inteiros
  static int _sanitizeInteger(int input) {
    // Verificar limites seguros
    if (input < 0) return 0;
    if (input > 999999) return 999999; // Limite razoável
    return input;
  }

  /// Sanitiza números decimais
  static double _sanitizeDouble(double input) {
    // Verificar limites seguros
    if (input < 0.0) return 0.0;
    if (input > 9999999.99) return 9999999.99; // Limite razoável
    if (input.isNaN || input.isInfinite) return 0.0;
    return input;
  }

  /// Sanitiza placa de veículo
  static String _sanitizePlaca(String placa) {
    if (placa.isEmpty) return placa;

    // Permitir apenas letras, números, hífens e espaços
    String sanitized =
        placa.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-\s]'), '').trim();

    // Limitar tamanho
    if (sanitized.length > 10) {
      sanitized = sanitized.substring(0, 10);
    }

    return sanitized;
  }

  /// Sanitiza campos alfanuméricos (Renavan, Chassi)
  static String _sanitizeAlphanumeric(String input) {
    if (input.isEmpty) return input;

    // Permitir apenas letras e números
    String sanitized =
        input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '').trim();

    // Limitar tamanho
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }

    return sanitized;
  }

  /// ========================================
  /// SECURITY VALIDATIONS
  /// ========================================

  /// Validações críticas de segurança
  static List<String> _validateSecurityConstraints(VeiculoCar veiculo) {
    final errors = <String>[];

    // Verificar tentativas de injection em campos de texto
    if (_containsInjectionPatterns(veiculo.marca)) {
      errors.add('Marca contém caracteres não permitidos');
    }

    if (_containsInjectionPatterns(veiculo.modelo)) {
      errors.add('Modelo contém caracteres não permitidos');
    }

    if (_containsInjectionPatterns(veiculo.cor)) {
      errors.add('Cor contém caracteres não permitidos');
    }

    // Verificar tamanhos máximos (proteção contra buffer overflow)
    if (veiculo.marca.length > 100) {
      errors.add('Marca excede tamanho máximo permitido');
    }

    if (veiculo.modelo.length > 100) {
      errors.add('Modelo excede tamanho máximo permitido');
    }

    // Verificar padrões suspeitos de ID
    if (_containsSuspiciousIdPatterns(veiculo.id)) {
      errors.add('ID do veículo contém padrão suspeito');
    }

    return errors;
  }

  /// Detecta padrões comuns de injection
  static bool _containsInjectionPatterns(String input) {
    if (input.isEmpty) return false;

    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false), // XSS
      RegExp(r'javascript:', caseSensitive: false), // XSS
      RegExp(r'SELECT\s+\*\s+FROM', caseSensitive: false), // SQL
      RegExp(r'DROP\s+TABLE', caseSensitive: false), // SQL
      RegExp(r'UNION\s+SELECT', caseSensitive: false), // SQL
      RegExp(r'INSERT\s+INTO', caseSensitive: false), // SQL
      RegExp(r'DELETE\s+FROM', caseSensitive: false), // SQL
      RegExp(r'\$\{.*\}'), // Template injection
      RegExp(r'exec\s*\('), // Code execution
      RegExp(r'eval\s*\('), // Code execution
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Detecta padrões suspeitos em IDs
  static bool _containsSuspiciousIdPatterns(String id) {
    if (id.isEmpty) return false;

    final suspiciousPatterns = [
      RegExp(r'\.\.\/'), // Path traversal
      RegExp(r'\/etc\/'), // System files
      RegExp(r'\/proc\/'), // System files
      RegExp(r'null'), // Null injection
      RegExp(r'undefined'), // Undefined injection
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(id));
  }

  /// ========================================
  /// FIELD VALIDATIONS
  /// ========================================

  /// Valida campos obrigatórios
  static List<String> _validateRequiredFields(VeiculoCar veiculo) {
    final errors = <String>[];

    if (veiculo.marca.trim().isEmpty) {
      errors.add('Marca é obrigatória');
    }

    if (veiculo.modelo.trim().isEmpty) {
      errors.add('Modelo é obrigatório');
    }

    if (veiculo.placa.trim().isEmpty) {
      errors.add('Placa é obrigatória');
    }

    if (veiculo.id.trim().isEmpty) {
      errors.add('ID interno é obrigatório');
    }

    return errors;
  }

  /// Valida formatos de campos
  static List<String> _validateFieldFormats(VeiculoCar veiculo) {
    final errors = <String>[];

    // Validar formato da placa
    if (veiculo.placa.isNotEmpty && !_isValidPlacaFormat(veiculo.placa)) {
      errors.add('Formato de placa inválido');
    }

    // Validar ano
    final currentYear = DateTime.now().year;
    if (veiculo.ano < 1900 || veiculo.ano > currentYear + 2) {
      errors.add('Ano deve estar entre 1900 e ${currentYear + 2}');
    }

    // Validar tipo de combustível
    if (veiculo.combustivel < 0 || veiculo.combustivel > 5) {
      errors.add('Tipo de combustível inválido');
    }

    // Validar Renavan (se preenchido)
    if (veiculo.renavan.isNotEmpty && !_isValidRenavan(veiculo.renavan)) {
      errors.add('Formato de Renavan inválido');
    }

    // Validar Chassi (se preenchido)
    if (veiculo.chassi.isNotEmpty && !_isValidChassi(veiculo.chassi)) {
      errors.add('Formato de Chassi inválido');
    }

    return errors;
  }

  /// Valida regras de negócio
  static List<String> _validateBusinessRules(VeiculoCar veiculo) {
    final errors = <String>[];

    // Validar odômetros
    if (veiculo.odometroInicial < 0) {
      errors.add('Odômetro inicial não pode ser negativo');
    }

    if (veiculo.odometroAtual < 0) {
      errors.add('Odômetro atual não pode ser negativo');
    }

    if (veiculo.odometroAtual < veiculo.odometroInicial) {
      errors.add('Odômetro atual não pode ser menor que o inicial');
    }

    // Validar diferença excessiva de odômetro (possível erro)
    if (veiculo.odometroAtual > veiculo.odometroInicial + 1000000) {
      errors.add('Diferença entre odômetros parece excessiva');
    }

    // Validar valor de venda
    if (veiculo.vendido && veiculo.valorVenda <= 0) {
      errors.add('Veículo vendido deve ter valor de venda positivo');
    }

    if (veiculo.valorVenda < 0) {
      errors.add('Valor de venda não pode ser negativo');
    }

    // Validar ano vs odômetro (heurística)
    final ageInYears = DateTime.now().year - veiculo.ano;
    final expectedMaxKm = ageInYears * 30000; // ~30k km/ano
    if (veiculo.odometroAtual > expectedMaxKm * 2) {
      errors.add('Odômetro parece muito alto para a idade do veículo');
    }

    return errors;
  }

  /// Validações de integridade (warnings)
  static List<String> _validateDataIntegrity(VeiculoCar veiculo) {
    final warnings = <String>[];

    // Verificar se marca e modelo fazem sentido juntos
    if (_isUncommonBrandModelCombination(veiculo.marca, veiculo.modelo)) {
      warnings.add('Combinação de marca e modelo pode estar incorreta');
    }

    // Verificar se cor está em branco
    if (veiculo.cor.trim().isEmpty) {
      warnings.add('Cor do veículo não foi preenchida');
    }

    // Verificar se Renavan está em branco
    if (veiculo.renavan.trim().isEmpty) {
      warnings.add('Renavan não foi preenchido');
    }

    return warnings;
  }

  /// ========================================
  /// FORMAT VALIDATION HELPERS
  /// ========================================

  /// Valida formato da placa brasileira
  static bool _isValidPlacaFormat(String placa) {
    final cleanPlaca = placa.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    // Formato antigo: AAA9999
    final oldFormat = RegExp(r'^[A-Z]{3}[0-9]{4}$');

    // Formato Mercosul: AAA9A99
    final mercosulFormat = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

    return oldFormat.hasMatch(cleanPlaca) ||
        mercosulFormat.hasMatch(cleanPlaca);
  }

  /// Valida formato do Renavan
  static bool _isValidRenavan(String renavan) {
    final cleanRenavan = renavan.replaceAll(RegExp(r'\D'), '');

    // Renavan tem 11 dígitos
    if (cleanRenavan.length != 11) return false;

    // Verificar se não são todos iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanRenavan)) return false;

    return true;
  }

  /// Valida formato do Chassi
  static bool _isValidChassi(String chassi) {
    final cleanChassi = chassi.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Chassi moderno tem 17 caracteres alfanuméricos
    if (cleanChassi.length != 17) return false;

    // Não pode conter I, O, Q
    if (RegExp(r'[IOQ]').hasMatch(cleanChassi)) return false;

    // Deve ser alfanumérico
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(cleanChassi)) return false;

    return true;
  }

  /// Verifica combinações não usuais de marca/modelo
  static bool _isUncommonBrandModelCombination(String marca, String modelo) {
    // Lista básica de verificações
    final combinations = {
      'TOYOTA': ['COROLLA', 'CAMRY', 'RAV4', 'HILUX'],
      'HONDA': ['CIVIC', 'ACCORD', 'FIT', 'CR-V'],
      'FORD': ['FIESTA', 'FOCUS', 'FUSION', 'RANGER'],
      'CHEVROLET': ['ONIX', 'CRUZE', 'S10', 'TRACKER'],
      'VOLKSWAGEN': ['GOL', 'POLO', 'JETTA', 'TIGUAN'],
      'FIAT': ['UNO', 'PALIO', 'TORO', 'ARGO'],
    };

    final marcaUpper = marca.toUpperCase();
    final modeloUpper = modelo.toUpperCase();

    if (combinations.containsKey(marcaUpper)) {
      return !combinations[marcaUpper]!
          .any((validModel) => modeloUpper.contains(validModel));
    }

    return false; // Se marca não está na lista, não flagrar como incomum
  }
}

/// ========================================
/// VALIDATION RESULT CLASS
/// ========================================

/// Resultado da validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final VeiculoCar sanitizedVehicle;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.sanitizedVehicle,
  });

  /// Verifica se há apenas warnings (validação passou)
  bool get hasOnlyWarnings => isValid && warnings.isNotEmpty;

  /// Verifica se passou sem problemas
  bool get isPerfect => isValid && warnings.isEmpty;

  /// Obtém primeira mensagem de erro
  String get firstError => errors.isNotEmpty ? errors.first : '';

  /// Obtém todas as mensagens formatadas
  String get allMessages {
    final messages = <String>[];

    if (errors.isNotEmpty) {
      messages.add('ERROS:');
      messages.addAll(errors.map((e) => '• $e'));
    }

    if (warnings.isNotEmpty) {
      messages.add('AVISOS:');
      messages.addAll(warnings.map((w) => '• $w'));
    }

    return messages.join('\n');
  }

  @override
  String toString() =>
      'ValidationResult(valid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
}
