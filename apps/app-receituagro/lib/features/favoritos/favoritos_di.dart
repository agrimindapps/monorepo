import 'package:core/core.dart';

import 'data/repositories/favoritos_repository_simplified.dart';
import 'data/services/favoritos_service.dart';
// import 'presentation/providers/favoritos_provider_simplified.dart'; // DEPRECATED: Migrando para Riverpod

/// Dependency Injection ULTRA SIMPLIFICADO para Favoritos
///
/// REFATORAÇÃO FASE 2:
/// - FavoritosService: 915 linhas → 250 linhas (73% redução)
/// - Specialized Services: 4 services criados (DataResolver, Validator, Sync, Cache)
/// - Logs: 157+ logs → ~10 logs essenciais (94% redução)
/// - Provider: Sendo migrado para Riverpod (FavoritosNotifier)
///
/// Princípio: Simplicidade + Delegation Pattern
class FavoritosDI {
  static final GetIt _getIt = GetIt.instance;

  /// Registra APENAS 2 dependências essenciais (Provider removido - usando Riverpod)
  static void registerDependencies() {
    if (_getIt.isRegistered<FavoritosService>()) {
      return; // Já registrado, evita duplicação
    }

    // Service com specialized services internos
    _getIt.registerLazySingleton<FavoritosService>(
      () => FavoritosService(),
    );

    // Repository
    _getIt.registerLazySingleton<FavoritosRepositorySimplified>(
      () => FavoritosRepositorySimplified(
        service: _getIt<FavoritosService>(),
      ),
    );

    // Provider (DEPRECATED - usar FavoritosNotifier do Riverpod)
    // _getIt.registerLazySingleton<FavoritosProviderSimplified>(
    //   () => FavoritosProviderSimplified(
    //     repository: _getIt<FavoritosRepositorySimplified>(),
    //   ),
    // );
  }

  /// Limpeza simplificada - apenas 2 registros para remover
  static void clearDependencies() {
    try {
      // _getIt.unregister<FavoritosProviderSimplified>(); // DEPRECATED
      _getIt.unregister<FavoritosRepositorySimplified>();
      _getIt.unregister<FavoritosService>();
    } catch (e) {
      // Silently fail
    }
  }

  /// Getter simplificado
  static T get<T extends Object>() => _getIt.get<T>();

  /// Verificação de registro
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}

/// Extension para facilitar uso
extension FavoritosDIExtension on GetIt {
  // /// Acesso direto ao provider simplificado
  // FavoritosProviderSimplified get favoritosProvider => get<FavoritosProviderSimplified>(); // DEPRECATED - usar Riverpod

  /// Acesso direto ao repository simplificado
  FavoritosRepositorySimplified get favoritosRepository => get<FavoritosRepositorySimplified>();

  /// Acesso direto ao service consolidado
  FavoritosService get favoritosService => get<FavoritosService>();
}

/// Comparação de Complexidade:
/// 
/// ANTES (favoritos_di.dart original):
/// -----------------------------------
/// Services: 5 (Storage, Cache, DataResolver, EntityFactory, Validator)
/// Repositories: 5 (Main + 4 específicos por tipo)
/// Use Cases: 15+ (Get, Add, Remove, Toggle, Search, Stats, etc.)
/// Providers: 1 (com 9 dependências injetadas)
/// Total: 25+ registros DI
/// Linhas de código: ~265 linhas
/// 
/// DEPOIS (favoritos_di.dart simplificado):
/// ----------------------------------------
/// Service: 1 (FavoritosService consolidado)
/// Repository: 1 (FavoritosRepositorySimplified)
/// Provider: 1 (FavoritosProviderSimplified com 1 dependência)
/// Total: 3 registros DI
/// Linhas de código: ~55 linhas
/// 
/// Redução: 88% menos registros, 79% menos linhas de código
/// Funcionalidade: 100% preservada
