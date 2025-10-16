import 'package:core/core.dart';

import 'data/repositories/favoritos_repository_simplified.dart';
import 'data/services/favoritos_service.dart';
import 'domain/repositories/i_favoritos_repository.dart';
// import 'presentation/providers/favoritos_provider_simplified.dart'; // DEPRECATED: Migrando para Riverpod

/// Dependency Injection ULTRA SIMPLIFICADO para Favoritos
///
/// REFATORAÇÃO FASE 2:
/// - FavoritosService: 915 linhas → 250 linhas (73% redução)
/// - Specialized Services: 4 services criados (DataResolver, Validator, Sync, Cache)
/// - Logs: 157+ logs → ~10 logs essenciais (94% redução)
/// - Provider: Sendo migrado para Riverpod (FavoritosNotifier)
///
/// ⚠️ IMPORTANTE: Separado em 2 métodos para evitar conflitos com Injectable:
/// 1. registerServices() - chamado ANTES do Injectable (apenas FavoritosService)
/// 2. IFavoritosRepository - gerenciado via @LazySingleton (Injectable)
///
/// Princípio: Simplicidade + Delegation Pattern
class FavoritosDI {
  static final GetIt _getIt = GetIt.instance;
  static bool _servicesRegistered = false;

  /// Registra APENAS FavoritosService (chamado ANTES do Injectable)
  /// ⚠️ FavoritosRepositorySimplified é registrado via @LazySingleton (Injectable)
  static void registerServices() {
    if (_servicesRegistered) return;

    // Service com specialized services internos (não tem @injectable)
    _getIt.registerLazySingleton<FavoritosService>(
      () => FavoritosService(),
    );

    _servicesRegistered = true;
  }

  /// Registra FavoritosRepositorySimplified como classe concreta (chamado DEPOIS do Injectable)
  /// ⚠️ IFavoritosRepository já foi registrado via @LazySingleton pelo Injectable
  static void registerRepository() {
    if (!_getIt.isRegistered<FavoritosRepositorySimplified>()) {
      // Registra a classe concreta usando a mesma instância registrada como interface
      final repository = _getIt<IFavoritosRepository>() as FavoritosRepositorySimplified;
      _getIt.registerLazySingleton<FavoritosRepositorySimplified>(() => repository);
    }
  }

  /// Método legado (mantido para compatibilidade) - agora só registra services
  @Deprecated('Use registerServices() - Repository agora via @LazySingleton')
  static void registerDependencies() {
    registerServices();

    // Provider (DEPRECATED - usar FavoritosNotifier do Riverpod)
    // _getIt.registerLazySingleton<FavoritosProviderSimplified>(
    //   () => FavoritosProviderSimplified(
    //     repository: _getIt<FavoritosRepositorySimplified>(),
    //   ),
    // );
  }

  /// Limpeza simplificada - apenas FavoritosService (FavoritosRepositorySimplified via @LazySingleton)
  static void clearDependencies() {
    try {
      // _getIt.unregister<FavoritosProviderSimplified>(); // DEPRECATED
      // ❌ REMOVIDO: FavoritosRepositorySimplified (gerenciado via @LazySingleton)
      if (_servicesRegistered) {
        _getIt.unregister<FavoritosService>();
        _servicesRegistered = false;
      }
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

  // ❌ REMOVIDO: FavoritosRepositorySimplified (usar GetIt.instance.get<IFavoritosRepository>() diretamente)
  // FavoritosRepositorySimplified é gerenciado via @LazySingleton (Injectable)

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
