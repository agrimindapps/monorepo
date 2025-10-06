import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface do repositório de storage local (Hive)
/// Define os contratos para operações de cache e persistência local
abstract class ILocalStorageRepository {
  /// Inicializa o storage local
  Future<Either<Failure, void>> initialize();

  /// Salva dados com uma chave
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  });

  /// Obtém dados por chave
  Future<Either<Failure, T?>> get<T>({
    required String key,
    String? box,
  });

  /// Remove dados por chave
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  });

  /// Remove todos os dados de uma box
  Future<Either<Failure, void>> clear({
    String? box,
  });

  /// Verifica se uma chave existe
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  });

  /// Obtém todas as chaves de uma box
  Future<Either<Failure, List<String>>> getKeys({
    String? box,
  });

  /// Obtém todos os valores de uma box
  Future<Either<Failure, List<T>>> getValues<T>({
    String? box,
  });

  /// Obtém o tamanho de uma box
  Future<Either<Failure, int>> length({
    String? box,
  });

  /// Salva uma lista de dados
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  });

  /// Obtém uma lista de dados
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  });

  /// Adiciona um item a uma lista existente
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  });

  /// Remove um item de uma lista
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  });

  /// Operações específicas para cache com TTL (Time To Live)
  
  /// Salva dados com expiração
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  });

  /// Obtém dados verificando se não expiraram
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  });

  /// Limpa dados expirados
  Future<Either<Failure, void>> cleanExpiredData({
    String? box,
  });

  /// Operações específicas para configurações do usuário
  
  /// Salva configuração do usuário
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  });

  /// Obtém configuração do usuário
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  });

  /// Obtém todas as configurações do usuário
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings();

  /// Operações específicas para dados offline
  
  /// Salva dados para uso offline
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  });

  /// Obtém dados offline
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  });

  /// Marca dados como sincronizados
  Future<Either<Failure, void>> markAsSynced({
    required String key,
  });

  /// Obtém dados não sincronizados
  Future<Either<Failure, List<String>>> getUnsyncedKeys();
}

/// Wrapper para dados offline com informações de sincronização
class OfflineData<T> {
  const OfflineData({
    required this.data,
    required this.createdAt,
    this.lastSync,
    this.isSynced = false,
  });

  /// Os dados salvos
  final T data;

  /// Quando foi criado/salvo localmente
  final DateTime createdAt;

  /// Última sincronização com o servidor
  final DateTime? lastSync;

  /// Se está sincronizado com o servidor
  final bool isSynced;

  /// Se precisa ser sincronizado
  bool get needsSync => !isSynced || lastSync == null;

  /// Há quanto tempo foi criado
  Duration get age => DateTime.now().difference(createdAt);

  /// Há quanto tempo foi sincronizado
  Duration? get timeSinceLastSync =>
      lastSync != null ? DateTime.now().difference(lastSync!) : null;
}

/// Dados com TTL (Time To Live)
class TTLData<T> {
  const TTLData({
    required this.data,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Os dados salvos
  final T data;

  /// Quando expira
  final DateTime expiresAt;

  /// Quando foi criado
  final DateTime createdAt;

  /// Se está expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Tempo restante até expirar
  Duration get timeToExpire => expiresAt.difference(DateTime.now());

  /// Se ainda é válido
  bool get isValid => !isExpired;
}

/// Chaves padrão para storage local
class LocalStorageKeys {
  static const String userSettings = 'user_settings';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notifications = 'notifications_enabled';
  static const String cachedData = 'cached_data';
  static const String offlineData = 'offline_data';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String tutorialShown = 'tutorial_shown';
}

/// Nomes das boxes core do Hive (genéricas para todos os apps)
/// IMPORTANTE: Não adicionar boxes específicas de apps aqui
/// Cada app deve definir suas próprias boxes usando o BoxRegistryService
class HiveBoxes {
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String offline = 'offline';
}