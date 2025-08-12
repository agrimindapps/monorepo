/// Constantes para nomes das collections Firebase do app-gasometer
///
/// Este arquivo centraliza todos os nomes das collections para facilitar
/// manutenção e evitar erros de digitação
class FirebaseCollections {
  // Prefix para identificar collections do gasometer
  static const String _prefix = 'gasometer_';

  // Collections principais
  static const String abastecimentos = '${_prefix}abastecimentos';
  static const String veiculos = '${_prefix}veiculos';
  static const String despesas = '${_prefix}despesas';
  static const String manutencoes = '${_prefix}manutencoes';
  static const String odometros = '${_prefix}odometros';

  // Lista com todas as collections (útil para operações em lote)
  static const List<String> allCollections = [
    abastecimentos,
    veiculos,
    despesas,
    manutencoes,
    odometros,
  ];

  // Método para debug - listar todas as collections
  static Map<String, String> getAllCollections() {
    return {
      'Abastecimentos': abastecimentos,
      'Veículos': veiculos,
      'Despesas': despesas,
      'Manutenções': manutencoes,
      'Odômetros': odometros,
    };
  }

  // Validar se uma collection existe
  static bool isValidCollection(String collectionName) {
    return allCollections.contains(collectionName);
  }
}
