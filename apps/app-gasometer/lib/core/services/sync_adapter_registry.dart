import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../sync/adapters/i_sync_adapter.dart';

/// Registro central de adapters de sincronização
/// 
/// Implementa o padrão Registry para evitar hard-coding de adapters específicos
/// Permite adicionar novos adapters sem modificar código existente
class SyncAdapterRegistry {
  final Map<String, ISyncAdapter> _adapters = {};

  /// Registra um novo adapter
  void register(ISyncAdapter adapter) {
    _adapters[adapter.name] = adapter;
  }

  /// Obtém um adapter específico
  ISyncAdapter? getAdapter(String entityType) {
    return _adapters[entityType];
  }

  /// Obtém todos os adapters registrados
  List<ISyncAdapter> getAll() {
    return _adapters.values.toList();
  }

  /// Obtém todos os adapters registrados (alias para getAll)
  List<ISyncAdapter> get adapters => getAll();

  /// Quantidade de adapters registrados
  int get count => _adapters.length;

  /// Obtém todos os tipos de entidades
  List<String> getEntityTypes() {
    return _adapters.keys.toList();
  }

  /// Verifica se existe adapter para tipo
  bool hasAdapter(String entityType) {
    return _adapters.containsKey(entityType);
  }

  /// Remove adapter
  void unregister(String entityType) {
    _adapters.remove(entityType);
  }

  /// Limpa todos os adapters
  void clear() {
    _adapters.clear();
  }
}
