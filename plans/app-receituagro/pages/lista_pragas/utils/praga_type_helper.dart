class PragaTypeHelper {
  static const String insetosType = '1';
  static const String doencasType = '2';
  static const String plantasInvasorasType = '3';

  // Type validation
  static bool isInsetos(String type) => type == insetosType;
  static bool isDoencas(String type) => type == doencasType;
  static bool isPlantasInvasoras(String type) => type == plantasInvasorasType;

  // Type conversion
  static String getTypeFromArguments(dynamic arguments) {
    if (arguments == null) return insetosType;
    
    if (arguments is Map<String, dynamic>) {
      return arguments['tipoPraga']?.toString() ?? insetosType;
    } else if (arguments is String) {
      return arguments;
    }
    
    return insetosType;
  }

  // Type descriptions
  static String getTypeDescription(String type) {
    switch (type) {
      case insetosType:
        return 'Pragas que atacam plantas causando danos às culturas';
      case doencasType:
        return 'Doenças que afetam o desenvolvimento das plantas';
      case plantasInvasorasType:
        return 'Plantas que competem com as culturas por recursos';
      default:
        return 'Organismos que podem causar danos às culturas';
    }
  }

  // Search fields based on type
  static List<String> getSearchFields(String type) {
    switch (type) {
      case insetosType:
        return ['nomeComum', 'nomeSecundario', 'nomeCientifico', 'categoria'];
      case doencasType:
        return ['nomeComum', 'nomeSecundario', 'nomeCientifico', 'sintomas'];
      case plantasInvasorasType:
        return ['nomeComum', 'nomeSecundario', 'nomeCientifico', 'familia'];
      default:
        return ['nomeComum', 'nomeSecundario', 'nomeCientifico'];
    }
  }

  // Sort fields based on type
  static List<String> getSortFields(String type) {
    return ['nomeComum', 'nomeCientifico'];
  }

  // Default sort field
  static String getDefaultSortField(String type) {
    return 'nomeComum';
  }

  // Validation helpers
  static bool hasValidId(Map<String, dynamic> item) {
    final id = item['idReg']?.toString();
    return id != null && id.isNotEmpty;
  }

  static bool hasValidName(Map<String, dynamic> item) {
    final name = item['nomeComum']?.toString();
    return name != null && name.isNotEmpty;
  }

  static bool isValidPragaItem(Map<String, dynamic> item) {
    return hasValidId(item) && hasValidName(item);
  }
}