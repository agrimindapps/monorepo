// Flutter imports:
import 'package:flutter/foundation.dart';

/// Service especializado para validação de dados de plantas
/// Centraliza todas as regras de negócio de validação seguindo SOLID
class PlantaValidationService {
  // Singleton pattern para otimização
  static PlantaValidationService? _instance;
  static PlantaValidationService get instance =>
      _instance ??= PlantaValidationService._();
  PlantaValidationService._();

  // ========== CONSTANTES DE VALIDAÇÃO ==========

  static const int _minNomeLength = 2;
  static const int _maxNomeLength = 50;
  static const int _maxEspecieLength = 100;
  static const int _maxObservacoesLength = 500;
  static const int _minIntervaloDias = 1;
  static const int _maxIntervaloDias = 365;

  // ========== VALIDAÇÃO DE DADOS BÁSICOS ==========

  /// Valida nome da planta com regras específicas
  ValidationResult validateNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return ValidationResult.error('Nome da planta é obrigatório');
    }

    final nomeClean = nome.trim();

    if (nomeClean.length < _minNomeLength) {
      return ValidationResult.error(
          'Nome da planta deve ter pelo menos $_minNomeLength caracteres');
    }

    if (nomeClean.length > _maxNomeLength) {
      return ValidationResult.error(
          'Nome da planta não pode ter mais de $_maxNomeLength caracteres');
    }

    if (!_isValidPlantName(nomeClean)) {
      return ValidationResult.error(
          'Nome da planta contém caracteres inválidos');
    }

    return ValidationResult.success(nomeClean);
  }

  /// Valida espécie da planta (opcional mas com regras se fornecida)
  ValidationResult validateEspecie(String? especie) {
    if (especie == null || especie.trim().isEmpty) {
      return ValidationResult.success(null); // Espécie é opcional
    }

    final especieClean = especie.trim();

    if (especieClean.length > _maxEspecieLength) {
      return ValidationResult.error(
          'Espécie não pode ter mais de $_maxEspecieLength caracteres');
    }

    return ValidationResult.success(especieClean);
  }

  /// Valida observações da planta (opcional)
  ValidationResult validateObservacoes(String? observacoes) {
    if (observacoes == null || observacoes.trim().isEmpty) {
      return ValidationResult.success(null);
    }

    final observacoesClean = observacoes.trim();

    if (observacoesClean.length > _maxObservacoesLength) {
      return ValidationResult.error(
          'Observações não podem ter mais de $_maxObservacoesLength caracteres');
    }

    return ValidationResult.success(observacoesClean);
  }

  // ========== VALIDAÇÃO DE CONFIGURAÇÕES DE CUIDADOS ==========

  /// Valida intervalo de dias para qualquer tipo de cuidado
  ValidationResult validateIntervaloDias(
      int? intervaloDias, String tipoCuidado) {
    if (intervaloDias == null) {
      return ValidationResult.error(
          'Intervalo é obrigatório para $tipoCuidado');
    }

    if (intervaloDias < _minIntervaloDias) {
      return ValidationResult.error(
          'Intervalo para $tipoCuidado deve ser pelo menos $_minIntervaloDias dia');
    }

    if (intervaloDias > _maxIntervaloDias) {
      return ValidationResult.error(
          'Intervalo para $tipoCuidado não pode ser maior que $_maxIntervaloDias dias');
    }

    return ValidationResult.success(intervaloDias);
  }

  /// Valida data de primeira execução do cuidado
  ValidationResult validatePrimeiraData(DateTime? data, String tipoCuidado) {
    if (data == null) {
      return ValidationResult.error(
          'Data de início é obrigatória para $tipoCuidado');
    }

    final hoje = DateTime.now();
    final dataLimite =
        hoje.add(const Duration(days: 365)); // Máximo 1 ano no futuro

    if (data.isBefore(hoje.subtract(const Duration(days: 1)))) {
      return ValidationResult.error(
          'Data de início para $tipoCuidado não pode ser no passado');
    }

    if (data.isAfter(dataLimite)) {
      return ValidationResult.error(
          'Data de início para $tipoCuidado não pode ser mais de 1 ano no futuro');
    }

    return ValidationResult.success(data);
  }

  // ========== VALIDAÇÃO DE IMAGEM ==========

  /// Valida imagem base64 (tamanho e formato)
  ValidationResult validateImageBase64(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      return ValidationResult.success(null); // Imagem é opcional
    }

    // Verificar se é um base64 válido
    if (!_isValidBase64(imageBase64)) {
      return ValidationResult.error('Formato de imagem inválido');
    }

    // Verificar tamanho (aproximadamente 5MB em base64)
    const maxSizeBase64 = 7000000; // ~5MB em base64
    if (imageBase64.length > maxSizeBase64) {
      return ValidationResult.error(
          'Imagem muito grande. Máximo permitido: 5MB');
    }

    return ValidationResult.success(imageBase64);
  }

  // ========== VALIDAÇÃO COMPLETA ==========

  /// Valida todos os dados da planta de uma vez
  FormValidationResult validateCompleteForm({
    required String? nome,
    String? especie,
    String? observacoes,
    String? imageBase64,
    required bool aguaAtiva,
    int? intervaloRegaDias,
    DateTime? primeiraRega,
    required bool aduboAtivo,
    int? intervaloAdubacaoDias,
    DateTime? primeiraAdubacao,
    required bool banhoSolAtivo,
    int? intervaloBanhoSolDias,
    DateTime? primeiroBanhoSol,
    required bool inspecaoPragasAtiva,
    int? intervaloInspecaoPragasDias,
    DateTime? primeiraInspecaoPragas,
    required bool podaAtiva,
    int? intervaloPodaDias,
    DateTime? primeiraPoda,
    required bool replantarAtivo,
    int? intervaloReplantarDias,
    DateTime? primeiroReplantar,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validar dados básicos
    final nomeResult = validateNome(nome);
    if (!nomeResult.isValid) errors.addAll(nomeResult.errors);

    final especieResult = validateEspecie(especie);
    if (!especieResult.isValid) errors.addAll(especieResult.errors);

    final observacoesResult = validateObservacoes(observacoes);
    if (!observacoesResult.isValid) errors.addAll(observacoesResult.errors);

    final imageResult = validateImageBase64(imageBase64);
    if (!imageResult.isValid) errors.addAll(imageResult.errors);

    // Validar configurações de cuidados ativos
    if (aguaAtiva) {
      final intervaloResult = validateIntervaloDias(intervaloRegaDias, 'rega');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult = validatePrimeiraData(primeiraRega, 'rega');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    if (aduboAtivo) {
      final intervaloResult =
          validateIntervaloDias(intervaloAdubacaoDias, 'adubação');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult = validatePrimeiraData(primeiraAdubacao, 'adubação');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    if (banhoSolAtivo) {
      final intervaloResult =
          validateIntervaloDias(intervaloBanhoSolDias, 'banho de sol');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult = validatePrimeiraData(primeiroBanhoSol, 'banho de sol');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    if (inspecaoPragasAtiva) {
      final intervaloResult = validateIntervaloDias(
          intervaloInspecaoPragasDias, 'inspeção de pragas');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult =
          validatePrimeiraData(primeiraInspecaoPragas, 'inspeção de pragas');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    if (podaAtiva) {
      final intervaloResult = validateIntervaloDias(intervaloPodaDias, 'poda');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult = validatePrimeiraData(primeiraPoda, 'poda');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    if (replantarAtivo) {
      final intervaloResult =
          validateIntervaloDias(intervaloReplantarDias, 'replantio');
      if (!intervaloResult.isValid) errors.addAll(intervaloResult.errors);

      final dataResult = validatePrimeiraData(primeiroReplantar, 'replantio');
      if (!dataResult.isValid) errors.addAll(dataResult.errors);
    }

    // Verificar se pelo menos um cuidado está ativo
    if (!(aguaAtiva ||
        aduboAtivo ||
        banhoSolAtivo ||
        inspecaoPragasAtiva ||
        podaAtiva ||
        replantarAtivo)) {
      warnings.add(
          'Nenhum tipo de cuidado está ativo. A planta não terá lembretes automáticos.');
    }

    debugPrint(
        '✅ PlantaValidationService: Validação completa - ${errors.length} erros, ${warnings.length} avisos');

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ========== MÉTODOS UTILITÁRIOS PRIVADOS ==========

  /// Verifica se o nome da planta contém apenas caracteres válidos
  bool _isValidPlantName(String nome) {
    // Permitir letras, números, espaços, hífen, apóstrofe
    final regex = RegExp(r"^[a-zA-ZÀ-ÿ0-9\s\-']+$");
    return regex.hasMatch(nome);
  }

  /// Verifica se a string é um base64 válido
  bool _isValidBase64(String str) {
    try {
      final regex = RegExp(r'^data:image\/[a-zA-Z]+;base64,');
      return regex.hasMatch(str);
    } catch (e) {
      return false;
    }
  }
}

// ========== CLASSES DE RESULTADO ==========

/// Resultado de uma validação individual
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final dynamic value;

  ValidationResult._(this.isValid, this.errors, this.value);

  factory ValidationResult.success(dynamic value) {
    return ValidationResult._(true, [], value);
  }

  factory ValidationResult.error(String error) {
    return ValidationResult._(false, [error], null);
  }
}

/// Resultado da validação completa do formulário
class FormValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  /// Retorna mensagem resumida do resultado
  String get summary {
    if (isValid) {
      return warnings.isNotEmpty
          ? 'Válido com ${warnings.length} aviso(s)'
          : 'Totalmente válido';
    } else {
      return '${errors.length} erro(s) encontrado(s)';
    }
  }
}
