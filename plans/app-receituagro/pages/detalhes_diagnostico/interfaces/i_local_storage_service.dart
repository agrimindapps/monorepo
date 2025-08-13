// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Interface Local Storage Service
// DESCRIÇÃO: Contrato para serviços de armazenamento local
// RESPONSABILIDADES: Definir operações de favoritos e cache local
// DEPENDÊNCIAS: Nenhuma (interface pura)
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

/// Interface para serviços de armazenamento local
abstract class ILocalStorageService {
  /// Verifica se um item é favorito
  Future<bool> isFavorite(String boxName, String id);

  /// Alterna o status de favorito de um item
  Future<bool> setFavorite(String boxName, String id);

  /// Obtém lista de favoritos
  Future<List<String>> getFavorites(String boxName);
}
