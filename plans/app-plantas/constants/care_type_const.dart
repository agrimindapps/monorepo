/// Enumeração para tipos de cuidados com plantas
///
/// Esta classe define constantes type-safe para todos os tipos de cuidados
/// possíveis com plantas, eliminando strings mágicas no código.
enum CareType {
  /// Cuidado de regagem (água)
  agua('agua'),

  /// Cuidado de adubação
  adubo('adubo'),

  /// Cuidado de banho de sol
  banhoSol('banho_sol'),

  /// Inspeção de pragas
  inspecaoPragas('inspecao_pragas'),

  /// Poda da planta
  poda('poda'),

  /// Replantio
  replantio('replantio');

  const CareType(this.value);

  /// O valor string correspondente ao tipo de cuidado
  final String value;

  /// Converte uma string para CareType
  ///
  /// Lança [ArgumentError] se a string não corresponder a nenhum tipo válido
  static CareType fromString(String value) {
    for (CareType type in CareType.values) {
      if (type.value == value) {
        return type;
      }
    }
    throw ArgumentError('Invalid care type: $value');
  }

  /// Converte uma string para CareType ou retorna null se inválida
  static CareType? fromStringOrNull(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se uma string é um tipo de cuidado válido
  static bool isValidCareType(String? value) {
    if (value == null) return false;
    return CareType.values.any((type) => type.value == value);
  }

  /// Lista de todos os tipos de cuidado básicos
  static List<CareType> get basicCares => [
        CareType.agua,
        CareType.adubo,
      ];

  /// Lista de todos os tipos de cuidado avançados
  static List<CareType> get advancedCares => [
        CareType.banhoSol,
        CareType.inspecaoPragas,
        CareType.poda,
        CareType.replantio,
      ];

  /// Lista de todos os tipos de cuidado obrigatórios
  static List<CareType> get mandatoryCares => [
        CareType.agua,
        CareType.adubo,
        CareType.banhoSol,
      ];

  /// Lista de todas as strings válidas de tipos de cuidado
  static List<String> get allValidStrings =>
      CareType.values.map((type) => type.value).toList();

  /// Lista de strings para cuidados básicos
  static List<String> get basicCareStrings =>
      basicCares.map((type) => type.value).toList();

  /// Lista de strings para cuidados avançados
  static List<String> get advancedCareStrings =>
      advancedCares.map((type) => type.value).toList();

  /// Lista de strings para cuidados obrigatórios
  static List<String> get mandatoryCareStrings =>
      mandatoryCares.map((type) => type.value).toList();

  @override
  String toString() => value;

  /// Valida se uma lista de strings são tipos de cuidado válidos
  ///
  /// Retorna uma lista dos tipos inválidos encontrados
  static List<String> validateCareTypes(List<String> careTypes) {
    final invalid = <String>[];
    for (final careType in careTypes) {
      if (!isValidCareType(careType)) {
        invalid.add(careType);
      }
    }
    return invalid;
  }

  /// Filtra uma lista mantendo apenas os tipos de cuidado válidos
  static List<String> filterValidCareTypes(List<String> careTypes) {
    return careTypes.where((careType) => isValidCareType(careType)).toList();
  }

  /// Converte uma lista de strings para uma lista de CareType válidos
  ///
  /// Ignora valores inválidos silenciosamente
  static List<CareType> fromStringList(List<String> careTypes) {
    final result = <CareType>[];
    for (final careType in careTypes) {
      final type = fromStringOrNull(careType);
      if (type != null) {
        result.add(type);
      }
    }
    return result;
  }

  /// Verifica se pelo menos um tipo básico está presente na lista
  static bool hasBasicCareType(List<String> careTypes) {
    return careTypes.any((careType) => basicCareStrings.contains(careType));
  }

  /// Verifica se todos os tipos obrigatórios estão presentes na lista
  static bool hasAllMandatoryCares(List<String> careTypes) {
    return mandatoryCareStrings
        .every((mandatory) => careTypes.contains(mandatory));
  }

  /// Obtém os tipos obrigatórios que estão faltando em uma lista
  static List<String> getMissingMandatoryCares(List<String> careTypes) {
    return mandatoryCareStrings
        .where((mandatory) => !careTypes.contains(mandatory))
        .toList();
  }
}

/// Classe utilitária com constantes antigas para compatibilidade temporária
///
/// DEPRECATED: Use CareType enum em vez dessas constantes
@Deprecated('Use CareType enum instead')
class CareTypeConstants {
  static const String agua = 'agua';
  static const String adubo = 'adubo';
  static const String banhoSol = 'banho_sol';
  static const String inspecaoPragas = 'inspecao_pragas';
  static const String poda = 'poda';
  static const String replantio = 'replantio';

  static const List<String> allTypes = [
    agua,
    adubo,
    banhoSol,
    inspecaoPragas,
    poda,
    replantio,
  ];

  static const List<String> basicTypes = [
    agua,
    adubo,
  ];

  static const List<String> advancedTypes = [
    banhoSol,
    inspecaoPragas,
    poda,
    replantio,
  ];

  static const List<String> mandatoryTypes = [
    agua,
    adubo,
    banhoSol,
  ];
}
