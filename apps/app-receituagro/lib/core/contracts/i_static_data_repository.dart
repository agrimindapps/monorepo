import 'package:dartz/dartz.dart';

/// Interface para repositórios de dados estáticos
/// Princípio: Dependency Inversion Principle
abstract class IStaticDataRepository<T> {
  /// Carrega dados do JSON para a versão especificada
  Future<Either<Exception, void>> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String appVersion,
  );

  /// Verifica se os dados estão atualizados para a versão
  bool isUpToDate(String appVersion);

  /// Obtém todos os itens
  List<T> getAll();

  /// Busca item por ID
  T? getById(String id);

  /// Busca itens por critério
  List<T> findBy(bool Function(T item) predicate);

  /// Limpa todos os dados
  Future<Either<Exception, void>> clear();

  /// Obtém estatísticas
  int get count;
}

/// Interface para inicializador do sistema de dados
/// Princípio: Single Responsibility Principle
abstract class IDataInitializer {
  Future<Either<Exception, void>> initialize();
  Future<Either<Exception, void>> loadStaticData(String appVersion);
  bool isInitialized();
}

/// Interface para gerenciador de versões
/// Princípio: Single Responsibility Principle
abstract class IVersionManager {
  String getCurrentVersion();
  bool needsUpdate(String storedVersion, String currentVersion);
  Future<void> markAsUpdated(String version, String boxName);
}

/// Interface para carregador de assets
/// Princípio: Single Responsibility Principle
abstract class IAssetLoader {
  Future<Either<Exception, List<Map<String, dynamic>>>> loadJsonAsset(String assetPath);
}