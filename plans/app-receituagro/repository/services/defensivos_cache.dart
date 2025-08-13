// Project imports:
import '../../../core/services/localstorage_service.dart';

/// Cache Service para Defensivos
/// Responsabilidade única: gerenciar cache e itens recentes
class DefensivosCache {
  static const int _maxRecentItems = 7;
  static const String _recentKey = 'acessadosFitos';
  
  final LocalStorageService _storage = LocalStorageService();
  
  /// Inicializa o storage de itens recentes
  Future<void> initializeRecentAccess([List<String>? testIds]) async {
    final hasRecents = await _storage.hasKey(_recentKey);
    if (!hasRecents) {
      await _storage.createRecentItems(_recentKey);
      
      // Para teste, adicionar alguns IDs se fornecidos
      if (testIds != null && testIds.isNotEmpty) {
        for (final id in testIds.take(3)) {
          await _storage.setRecentItem(_recentKey, id);
        }
      }
    }
  }
  
  /// Obtém lista de IDs de itens recentes
  Future<List<String>> getRecentIds() async {
    try {
      return await _storage.getRecentItems(_recentKey);
    } catch (e) {
      return [];
    }
  }
  
  /// Adiciona item aos recentes
  Future<void> addRecentItem(String id) async {
    if (id.isEmpty) return;
    try {
      await _storage.setRecentItem(_recentKey, id);
    } catch (e) {
      // Log error but don't throw
    }
  }
  
  /// Processa lista de IDs recentes e filtra items válidos da fonte de dados
  List<Map<String, dynamic>> processRecentItems(
    List<String> recentIds,
    List<Map<String, dynamic>> sourceData,
  ) {
    final processedItems = <Map<String, dynamic>>[];
    
    try {
      for (final id in recentIds) {
        if (id.isEmpty) continue;
        
        try {
          final item = sourceData.firstWhere(
            (r) => r['idReg'] != null && r['idReg'].toString() == id,
            orElse: () => {},
          );
          
          if (item.isNotEmpty) {
            processedItems.add(item);
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Error processing - return what we have
    }
    
    return processedItems.take(_maxRecentItems).toList();
  }
  
  /// Obtém itens recentes processados
  Future<List<Map<String, dynamic>>> getRecentItems(
    List<Map<String, dynamic>> sourceData,
  ) async {
    // Inicializar se necessário com IDs de teste
    final testIds = sourceData.isNotEmpty
        ? sourceData.take(3).map((item) => item['idReg'].toString()).toList()
        : null;
    await initializeRecentAccess(testIds);
    
    final recentIds = await getRecentIds();
    return processRecentItems(recentIds, sourceData);
  }
}