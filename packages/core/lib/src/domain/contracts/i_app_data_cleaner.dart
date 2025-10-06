/// Interface para limpeza de dados específicos por app
/// Permite que cada app implemente sua própria lógica de limpeza
/// mantendo flexibilidade para diferentes tipos de dados e estruturas
abstract class IAppDataCleaner {
  /// Nome do app que implementa este cleaner
  String get appName;

  /// Versão do cleaner (para controle de compatibilidade)
  String get version;

  /// Descrição dos dados que serão limpos
  String get description;

  /// Limpa todos os dados específicos do app
  /// Retorna um Map com estatísticas da limpeza:
  /// - 'success': bool - se a operação foi bem-sucedida
  /// - 'clearedBoxes': List<String> - nomes das boxes limpas
  /// - 'clearedPreferences': List<String> - chaves SharedPreferences removidas
  /// - 'errors': List<String> - erros encontrados durante limpeza
  /// - 'totalRecordsCleared': int - total de registros removidos
  Future<Map<String, dynamic>> clearAllAppData();

  /// Obter estatísticas dos dados antes da limpeza
  /// Útil para mostrar confirmação ao usuário
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning();

  /// Verificar se existem dados para limpar
  Future<bool> hasDataToClear();

  /// Limpar categoria específica de dados (opcional)
  /// Parâmetro category pode ser: 'vehicles', 'fuel', 'maintenance', etc.
  Future<Map<String, dynamic>> clearCategoryData(String category) {
    return clearAllAppData();
  }

  /// Obter lista de categorias disponíveis para limpeza (opcional)
  List<String> getAvailableCategories() {
    return ['all']; // Implementação padrão
  }

  /// Verificar integridade dos dados após limpeza
  Future<bool> verifyDataCleanup();
}
