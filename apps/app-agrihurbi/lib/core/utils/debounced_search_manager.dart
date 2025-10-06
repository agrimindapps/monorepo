import 'dart:async';

/// Manager para controlar buscas com debounce
/// 
/// Evita múltiplas chamadas de busca consecutivas, aplicando um delay
/// configurável antes de executar a busca real.
class DebouncedSearchManager {
  Timer? _debounceTimer;
  final Duration _debounceDelay;
  
  /// Cria um novo manager com delay padrão de 300ms
  DebouncedSearchManager({
    Duration debounceDelay = const Duration(milliseconds: 300),
  }) : _debounceDelay = debounceDelay;
  
  /// Executa busca com debounce
  /// 
  /// Cancela timer anterior e agenda nova busca após o delay configurado.
  /// [query] - Texto da busca
  /// [onSearch] - Callback que será executado com o texto da busca
  void searchWithDebounce(String query, void Function(String) onSearch) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      onSearch(query);
    });
  }
  
  /// Cancela qualquer busca pendente
  void cancelPendingSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
  
  /// Executa busca imediatamente, cancelando delays
  void searchImmediately(String query, void Function(String) onSearch) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    onSearch(query);
  }
  
  /// Verifica se existe busca pendente
  bool get hasPendingSearch => _debounceTimer?.isActive == true;
  
  /// Limpa recursos
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}