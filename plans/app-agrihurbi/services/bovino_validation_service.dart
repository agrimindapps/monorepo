// Flutter imports:
import 'package:flutter/foundation.dart';

/// Serviço de validação específico para bovinos
class BovinoValidationService {
  // Lista de países válidos (principais produtores bovinos)
  static const List<String> paisesValidos = [
    'Brasil',
    'Argentina',
    'Uruguai',
    'Estados Unidos',
    'Canadá',
    'México',
    'Austrália',
    'Nova Zelândia',
    'França',
    'Alemanha',
    'Holanda',
    'Reino Unido',
    'Irlanda',
    'Espanha',
    'Itália',
    'Portugal',
    'Suíça',
    'Áustria',
    'Dinamarca',
    'Suécia',
    'Noruega',
    'Finlândia',
    'Bélgica',
    'Índia',
    'China',
    'Japão',
    'Coreia do Sul',
    'Etiópia',
    'Quênia',
    'Tanzânia',
    'África do Sul',
    'Outro'
  ];

  // Tipos de animais bovinos válidos
  static const List<String> tiposAnimaisValidos = [
    'Bovino de Corte',
    'Bovino de Leite',
    'Bovino de Dupla Aptidão',
    'Zebu',
    'Taurino',
    'Híbrido',
    'Búfalo',
    'Outro'
  ];

  // Raças bovinas reconhecidas
  static const List<String> racasValidas = [
    'Nelore',
    'Angus',
    'Hereford',
    'Brahman',
    'Simmental',
    'Charolês',
    'Limousin',
    'Holstein',
    'Jersey',
    'Gir',
    'Guzerá',
    'Indubrasil',
    'Canchim',
    'Santa Gertrudis',
    'Brangus',
    'Senepol',
    'Wagyu',
    'Pardo Suíço',
    'Holandês',
    'Girolando',
    'Outro'
  ];

  /// Valida nome comum do bovino
  static ValidationResult validateNomeComum(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('Nome comum é obrigatório');
    }

    final trimmed = value.trim();

    // Verificar tamanho mínimo e máximo
    if (trimmed.length < 2) {
      return ValidationResult.error('Nome deve ter pelo menos 2 caracteres');
    }

    if (trimmed.length > 50) {
      return ValidationResult.error('Nome não pode ter mais de 50 caracteres');
    }

    // Verificar caracteres válidos (letras, espaços, hífens, números)
    final validNameRegex = RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-]+$');
    if (!validNameRegex.hasMatch(trimmed)) {
      return ValidationResult.error(
          'Nome deve conter apenas letras, números, espaços e hífens');
    }

    // Verificar se não é apenas números
    final onlyNumbersRegex = RegExp(r'^\d+$');
    if (onlyNumbersRegex.hasMatch(trimmed)) {
      return ValidationResult.error('Nome não pode ser apenas números');
    }

    // Verificar palavras ofensivas básicas
    final palavrasProibidas = ['test', 'teste', 'delete', 'null', 'undefined'];
    final lowerCase = trimmed.toLowerCase();
    for (final palavra in palavrasProibidas) {
      if (lowerCase.contains(palavra)) {
        return ValidationResult.warning(
            'Nome contém palavra não recomendada: $palavra');
      }
    }

    // Verificar padrões suspeitos
    if (trimmed.contains('  ')) {
      return ValidationResult.warning('Nome contém espaços duplos');
    }

    return ValidationResult.success();
  }

  /// Valida país de origem
  static ValidationResult validatePaisOrigem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(); // Campo opcional
    }

    final trimmed = value.trim();

    if (trimmed.length > 30) {
      return ValidationResult.error('País não pode ter mais de 30 caracteres');
    }

    // Verificar se é um país válido da lista
    final isValidCountry = paisesValidos
        .any((pais) => pais.toLowerCase() == trimmed.toLowerCase());

    if (!isValidCountry) {
      return ValidationResult.warning(
          'País não encontrado na lista. Verifique a grafia ou selecione "Outro"');
    }

    return ValidationResult.success();
  }

  /// Valida tipo de animal
  static ValidationResult validateTipoAnimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('Tipo de animal é obrigatório');
    }

    final trimmed = value.trim();

    if (trimmed.length > 30) {
      return ValidationResult.error(
          'Tipo de animal não pode ter mais de 30 caracteres');
    }

    // Verificar se é um tipo válido
    final isValidType = tiposAnimaisValidos
        .any((tipo) => tipo.toLowerCase() == trimmed.toLowerCase());

    if (!isValidType) {
      return ValidationResult.warning(
          'Tipo não encontrado na lista. Verifique a grafia ou selecione "Outro"');
    }

    return ValidationResult.success();
  }

  /// Valida origem/descrição
  static ValidationResult validateOrigem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(); // Campo opcional
    }

    final trimmed = value.trim();

    if (trimmed.length > 500) {
      return ValidationResult.error(
          'Origem não pode ter mais de 500 caracteres');
    }

    if (trimmed.length < 10) {
      return ValidationResult.warning(
          'Descrição da origem muito curta. Considere adicionar mais detalhes');
    }

    // Verificar conteúdo suspeito
    final suspiciousPatterns = ['<script', 'javascript:', 'data:', '<?php'];
    final lowerCase = trimmed.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerCase.contains(pattern)) {
        return ValidationResult.error('Conteúdo não permitido detectado');
      }
    }

    return ValidationResult.success();
  }

  /// Valida características
  static ValidationResult validateCaracteristicas(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(); // Campo opcional
    }

    final trimmed = value.trim();

    if (trimmed.length > 1000) {
      return ValidationResult.error(
          'Características não podem ter mais de 1000 caracteres');
    }

    if (trimmed.length < 10) {
      return ValidationResult.warning(
          'Descrição das características muito curta. Considere adicionar mais detalhes');
    }

    // Verificar se contém informações úteis
    final keywords = [
      'peso',
      'altura',
      'cor',
      'temperamento',
      'produção',
      'resistência'
    ];
    final lowerCase = trimmed.toLowerCase();
    final hasUsefulInfo =
        keywords.any((keyword) => lowerCase.contains(keyword));

    if (!hasUsefulInfo) {
      return ValidationResult.warning(
          'Considere adicionar informações como peso, altura, cor, temperamento, etc.');
    }

    // Verificar conteúdo suspeito
    final suspiciousPatterns = ['<script', 'javascript:', 'data:', '<?php'];
    for (final pattern in suspiciousPatterns) {
      if (lowerCase.contains(pattern)) {
        return ValidationResult.error('Conteúdo não permitido detectado');
      }
    }

    return ValidationResult.success();
  }

  /// Valida duplicatas por nome comum
  static Future<ValidationResult> validateDuplicateNome(String nomeComum,
      String? currentId, Future<List<dynamic>> Function() getAllBovinos) async {
    try {
      final bovinos = await getAllBovinos();

      final duplicate = bovinos.where((bovino) {
        final isSameName = bovino['nome_comum']?.toString().toLowerCase() ==
            nomeComum.toLowerCase();
        final isDifferentRecord =
            currentId == null || bovino['id'] != currentId;
        return isSameName && isDifferentRecord;
      }).isNotEmpty;

      if (duplicate) {
        return ValidationResult.error(
            'Já existe um bovino cadastrado com este nome');
      }

      return ValidationResult.success();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar duplicatas: $e');
      }
      return ValidationResult.warning('Não foi possível verificar duplicatas');
    }
  }

  /// Sanitiza entrada removendo caracteres perigosos
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(RegExp(r'\s+'), ' '); // Normaliza espaços
  }

  /// Valida formulário completo
  static Future<FormValidationResult> validateCompleteForm({
    required String? nomeComum,
    required String? paisOrigem,
    required String? tipoAnimal,
    required String? origem,
    required String? caracteristicas,
    String? currentId,
    Future<List<dynamic>> Function()? getAllBovinos,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Validar campos individuais
    final nomeResult = validateNomeComum(nomeComum);
    if (!nomeResult.isValid) {
      errors.add(nomeResult.message!);
    } else if (nomeResult.isWarning) {
      warnings.add(nomeResult.message!);
    }

    final paisResult = validatePaisOrigem(paisOrigem);
    if (!paisResult.isValid) {
      errors.add(paisResult.message!);
    } else if (paisResult.isWarning) {
      warnings.add(paisResult.message!);
    }

    final tipoResult = validateTipoAnimal(tipoAnimal);
    if (!tipoResult.isValid) {
      errors.add(tipoResult.message!);
    } else if (tipoResult.isWarning) {
      warnings.add(tipoResult.message!);
    }

    final origemResult = validateOrigem(origem);
    if (!origemResult.isValid) {
      errors.add(origemResult.message!);
    } else if (origemResult.isWarning) {
      warnings.add(origemResult.message!);
    }

    final caracteristicasResult = validateCaracteristicas(caracteristicas);
    if (!caracteristicasResult.isValid) {
      errors.add(caracteristicasResult.message!);
    } else if (caracteristicasResult.isWarning) {
      warnings.add(caracteristicasResult.message!);
    }

    // Verificar duplicatas se possível
    if (nomeComum != null && nomeComum.isNotEmpty && getAllBovinos != null) {
      final duplicateResult =
          await validateDuplicateNome(nomeComum, currentId, getAllBovinos);
      if (!duplicateResult.isValid) {
        errors.add(duplicateResult.message!);
      } else if (duplicateResult.isWarning) {
        warnings.add(duplicateResult.message!);
      }
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Resultado de validação individual
class ValidationResult {
  final bool isValid;
  final bool isWarning;
  final String? message;

  const ValidationResult._({
    required this.isValid,
    required this.isWarning,
    this.message,
  });

  factory ValidationResult.success() => const ValidationResult._(
        isValid: true,
        isWarning: false,
      );

  factory ValidationResult.error(String message) => ValidationResult._(
        isValid: false,
        isWarning: false,
        message: message,
      );

  factory ValidationResult.warning(String message) => ValidationResult._(
        isValid: true,
        isWarning: true,
        message: message,
      );
}

/// Resultado de validação do formulário completo
class FormValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  String get firstError => errors.isNotEmpty ? errors.first : '';
  String get allErrors => errors.join('\n');
  String get allWarnings => warnings.join('\n');
}
