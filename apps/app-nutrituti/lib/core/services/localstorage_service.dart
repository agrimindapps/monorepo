// STUB - FASE 0.7
// TODO FASE 1: Implementar LocalStorage completo com SharedPreferences

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._();
  LocalStorageService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  // Salvar string
  Future<void> setString(String key, String value) async {
    if (!_isInitialized) return;
    // TODO: Implementar com SharedPreferences
  }

  // Obter string
  String? getString(String key) {
    if (!_isInitialized) return null;
    // TODO: Implementar com SharedPreferences
    return null;
  }

  // Salvar bool
  Future<void> setBool(String key, bool value) async {
    if (!_isInitialized) return;
    // TODO: Implementar
  }

  // Obter bool
  bool? getBool(String key) {
    if (!_isInitialized) return null;
    // TODO: Implementar
    return null;
  }

  // Salvar int
  Future<void> setInt(String key, int value) async {
    if (!_isInitialized) return;
    // TODO: Implementar
  }

  // Obter int
  int? getInt(String key) {
    if (!_isInitialized) return null;
    // TODO: Implementar
    return null;
  }

  // Deletar chave
  Future<void> remove(String key) async {
    if (!_isInitialized) return;
    // TODO: Implementar
  }

  // Limpar tudo
  Future<void> clear() async {
    if (!_isInitialized) return;
    // TODO: Implementar
  }

  // Favorites management (stub for alimentos)
  Future<List<String>> getFavorites(String key) async {
    if (!_isInitialized) return [];
    // TODO FASE 1: Implementar com SharedPreferences
    return [];
  }

  Future<void> setFavorite(String key, String id, bool isFavorite) async {
    if (!_isInitialized) return;
    // TODO FASE 1: Implementar com SharedPreferences
  }

  Future<bool> isFavorite(String key, String id) async {
    if (!_isInitialized) return false;
    // TODO FASE 1: Implementar com SharedPreferences
    return false;
  }
}

// Instância global para facilitar uso
final localStorage = LocalStorageService.instance;
