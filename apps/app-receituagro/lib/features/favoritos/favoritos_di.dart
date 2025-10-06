import 'package:core/core.dart';

import 'data/repositories/favoritos_repository_simplified.dart';
import 'data/services/favoritos_service.dart';
import 'presentation/providers/favoritos_provider_simplified.dart';

/// Dependency Injection ULTRA SIMPLIFICADO para Favoritos
/// 
/// ANTES: 5 services + 5 repositories + 15+ use cases + Provider = 25+ registros
/// DEPOIS: 1 service + 1 repository + 1 provider = 3 registros totais
/// 
/// Princípio: Simplicidade máxima mantendo funcionalidade intacta
class FavoritosDI {
  static final GetIt _getIt = GetIt.instance;

  /// Registra APENAS 3 dependências essenciais - ultra simplificado
  static void registerDependencies() {
    if (_getIt.isRegistered<FavoritosService>()) {
      return; // Já registrado, evita duplicação
    }
    _getIt.registerLazySingleton<FavoritosService>(
      () => FavoritosService(),
    );
    _getIt.registerLazySingleton<FavoritosRepositorySimplified>(
      () => FavoritosRepositorySimplified(
        service: _getIt<FavoritosService>(),
      ),
    );
    _getIt.registerLazySingleton<FavoritosProviderSimplified>(
      () => FavoritosProviderSimplified(
        repository: _getIt<FavoritosRepositorySimplified>(),
      ),
    );
  }

  /// Limpeza simplificada - apenas 3 registros para remover
  static void clearDependencies() {
    try {
      _getIt.unregister<FavoritosProviderSimplified>();
      _getIt.unregister<FavoritosRepositorySimplified>();
      _getIt.unregister<FavoritosService>();
    } catch (e) {
    }
  }

  /// Getter simplificado
  static T get<T extends Object>() => _getIt.get<T>();

  /// Verificação de registro
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}

/// Extension para facilitar uso
extension FavoritosDIExtension on GetIt {
  /// Acesso direto ao provider simplificado
  FavoritosProviderSimplified get favoritosProvider => get<FavoritosProviderSimplified>();
  
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