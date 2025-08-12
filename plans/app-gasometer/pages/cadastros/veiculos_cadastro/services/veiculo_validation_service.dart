// Project imports:
import '../../../../database/enums.dart';
import '../models/veiculos_constants.dart';

/// Service centralizado para validações de veículos
///
/// Implementa um sistema robusto e configurável de validações que:
/// - Centraliza todas as regras de validação
/// - Permite configuração de regras customizadas
/// - Fornece mensagens de erro consistentes e internationalizadas
/// - Mantém separação clara entre regras de negócio e apresentação
class VeiculoValidationService {
  // ===================================
  // CONFIGURAÇÕES DE VALIDAÇÃO
  // ===================================

  /// Configurações específicas de validação que podem ser customizadas
  static const Map<String, dynamic> _validationConfig = {
    'allowEmptyOptionalFields': true,
    'strictPlateValidation': true,
    'validateChassisChecksum':
        false, // TODO: implementar algoritmo de verificação
    'validateRenavamChecksum': false, // TODO: implementar dígito verificador
    'maxMarcaLength': 50,
    'maxModeloLength': 50,
    'maxCorLength': 30,
    'minOdometer': 0.0,
    'maxOdometer': 999999.0,
  };

  /// Obtém configuração específica
  static T getConfig<T>(String key) {
    return _validationConfig[key] as T;
  }

  // ===================================
  // VALIDAÇÕES DE CAMPOS OBRIGATÓRIOS
  // ===================================

  /// Valida campo marca com regras avançadas
  static String? validateMarca(String? value) {
    if (value == null || value.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final maxLength = getConfig<int>('maxMarcaLength');
    if (trimmedValue.length > maxLength) {
      return 'Marca deve ter no máximo $maxLength caracteres';
    }

    // Validação de caracteres especiais maliciosos (proteção XSS/SQL injection)
    if (RegExp(r'[<>"\\&%$#@!*()[\]{}]').hasMatch(trimmedValue)) {
      return 'Marca contém caracteres não permitidos';
    }

    return null;
  }

  /// Valida campo modelo com regras avançadas
  static String? validateModelo(String? value) {
    if (value == null || value.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final maxLength = getConfig<int>('maxModeloLength');
    if (trimmedValue.length > maxLength) {
      return 'Modelo deve ter no máximo $maxLength caracteres';
    }

    // Validação de caracteres especiais maliciosos (proteção XSS/SQL injection)
    if (RegExp(r'[<>"\\&%$#@!*()[\]{}]').hasMatch(trimmedValue)) {
      return 'Modelo contém caracteres não permitidos';
    }

    return null;
  }

  /// Valida campo ano com regras avançadas
  static String? validateAno(int? value) {
    if (value == null) {
      return VeiculosConstants.mensagensValidacao['anoObrigatorio'];
    }

    final currentYear = DateTime.now().year;
    if (value < VeiculosConstants.anoMinimo || value > currentYear + 1) {
      return VeiculosConstants.mensagensValidacao['anoInvalido'];
    }

    return null;
  }

  /// Valida campo cor com regras avançadas
  static String? validateCor(String? value) {
    if (value == null || value.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final maxLength = getConfig<int>('maxCorLength');
    if (trimmedValue.length > maxLength) {
      return 'Cor deve ter no máximo $maxLength caracteres';
    }

    // Validação de caracteres especiais maliciosos
    if (RegExp(r'[<>"\\&%$#@!*()[\]{}]').hasMatch(trimmedValue)) {
      return 'Cor contém caracteres não permitidos';
    }

    return null;
  }

  /// Valida campo placa com múltiplos formatos (Mercosul e antiga)
  static String? validatePlaca(String? value) {
    if (value == null || value.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    final trimmedValue = value.trim().toUpperCase();
    if (trimmedValue.isEmpty) {
      return VeiculosConstants.mensagensValidacao['campoObrigatorio'];
    }

    // Validação usando regex consolidadas do VeiculosConstants
    final placaMercosulValid =
        VeiculosConstants.placaMercosulRegex.hasMatch(trimmedValue);
    final placaAntigaValid =
        VeiculosConstants.placaAntigaRegex.hasMatch(trimmedValue);

    if (!placaMercosulValid && !placaAntigaValid) {
      return VeiculosConstants.mensagensValidacao['placaInvalida'];
    }

    return null;
  }

  // ===================================
  // VALIDAÇÕES DE CAMPOS OPCIONAIS
  // ===================================

  /// Valida campo chassi com regras avançadas
  static String? validateChassi(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }

    final trimmedValue = value.trim().toUpperCase();

    // Validação de comprimento
    if (trimmedValue.length != VeiculosConstants.chassiComprimento) {
      return VeiculosConstants.mensagensValidacao['chassiInvalido'];
    }

    // Validação usando regex consolidada
    if (!VeiculosConstants.chassiRegex.hasMatch(trimmedValue)) {
      return VeiculosConstants.mensagensValidacao['chassiInvalido'];
    }

    // TODO: Implementar validação de dígito verificador se configurado
    if (getConfig<bool>('validateChassisChecksum')) {
      // Implementação futura do algoritmo de verificação
    }

    return null;
  }

  /// Valida campo renavam com regras avançadas
  static String? validateRenavam(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }

    final trimmedValue = value.trim();

    // Validação de comprimento
    if (trimmedValue.length != VeiculosConstants.renavamComprimento) {
      return 'RENAVAM deve ter ${VeiculosConstants.renavamComprimento} dígitos';
    }

    // Validação se contém apenas números
    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return 'RENAVAM deve conter apenas números';
    }

    // TODO: Implementar validação de dígito verificador se configurado
    if (getConfig<bool>('validateRenavamChecksum')) {
      // Implementação futura do dígito verificador
    }

    return null;
  }

  /// Valida odômetro inicial vs atual com regras de negócio
  static String? validateOdometro(double? value, double? odometroAtual) {
    if (value == null) return null;

    final minOdometer = getConfig<double>('minOdometer');
    final maxOdometer = getConfig<double>('maxOdometer');

    if (value < minOdometer || value > maxOdometer) {
      return 'Odômetro deve estar entre $minOdometer e $maxOdometer km';
    }

    if (odometroAtual != null && value > odometroAtual) {
      return VeiculosConstants.mensagensValidacao['odometroMaiorQueAtual'];
    }

    return null;
  }

  /// Valida tipo de combustível
  static String? validateCombustivel(TipoCombustivel? value) {
    if (value == null) {
      return VeiculosConstants.mensagensValidacao['combustivelObrigatorio'];
    }
    return null;
  }

  // ===================================
  // VALIDAÇÕES COMPOSTAS E REGRAS DE NEGÓCIO
  // ===================================

  /// Valida formulário completo com todas as regras
  static bool validateForm({
    required String? marca,
    required String? modelo,
    required int? ano,
    required String? cor,
    required TipoCombustivel? combustivel,
    String? placa,
    String? chassi,
    String? renavam,
    double? odometroInicial,
    double? odometroAtual,
  }) {
    return validateMarca(marca) == null &&
        validateModelo(modelo) == null &&
        validateAno(ano) == null &&
        validateCor(cor) == null &&
        validateCombustivel(combustivel) == null &&
        validatePlaca(placa) == null &&
        validateChassi(chassi) == null &&
        validateRenavam(renavam) == null &&
        validateOdometro(odometroInicial, odometroAtual) == null;
  }

  /// Obtém lista de erros de validação para um formulário
  static List<String> getFormValidationErrors({
    required String? marca,
    required String? modelo,
    required int? ano,
    required String? cor,
    required TipoCombustivel? combustivel,
    String? placa,
    String? chassi,
    String? renavam,
    double? odometroInicial,
    double? odometroAtual,
  }) {
    final errors = <String>[];

    final marcaError = validateMarca(marca);
    if (marcaError != null) errors.add('Marca: $marcaError');

    final modeloError = validateModelo(modelo);
    if (modeloError != null) errors.add('Modelo: $modeloError');

    final anoError = validateAno(ano);
    if (anoError != null) errors.add('Ano: $anoError');

    final corError = validateCor(cor);
    if (corError != null) errors.add('Cor: $corError');

    final combustivelError = validateCombustivel(combustivel);
    if (combustivelError != null) errors.add('Combustível: $combustivelError');

    final placaError = validatePlaca(placa);
    if (placaError != null) errors.add('Placa: $placaError');

    final chassiError = validateChassi(chassi);
    if (chassiError != null) errors.add('Chassi: $chassiError');

    final renavamError = validateRenavam(renavam);
    if (renavamError != null) errors.add('RENAVAM: $renavamError');

    final odometroError = validateOdometro(odometroInicial, odometroAtual);
    if (odometroError != null) errors.add('Odômetro: $odometroError');

    return errors;
  }

  /// Sanitiza string removendo caracteres potencialmente maliciosos
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\\&%$#@!*()[\]{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Verifica se configuração permite campos opcionais vazios
  static bool allowEmptyOptionalFields() {
    return getConfig<bool>('allowEmptyOptionalFields');
  }
}
