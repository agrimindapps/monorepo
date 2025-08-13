// Este é um exemplo de como testar as camadas independentemente
// Em um projeto real, este arquivo estaria em test/

import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivos_stats_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../error/result.dart';
import '../mappers/defensivos_mapper.dart';
import '../use_cases/get_defensivos_home_data_use_case.dart';

/// Mock do repositório para testes unitários
/// 
/// Permite testar UseCases isoladamente, sem depender da implementação real
class MockDefensivosRepository implements IDefensivosRepository {
  bool _isDataLoaded = true;
  bool _shouldReturnError = false;
  String _errorMessage = '';

  // Métodos de configuração para os testes
  void setDataLoaded(bool loaded) => _isDataLoaded = loaded;
  void setError(bool error, [String message = 'Erro de teste']) {
    _shouldReturnError = error;
    _errorMessage = message;
  }

  @override
  bool get isDataLoaded => _isDataLoaded;

  @override
  Future<Result<void>> initialize() async {
    if (_shouldReturnError) {
      return Result.failure(RepositoryError(
        repositoryName: 'MockRepository',
        operation: 'initialize',
        message: _errorMessage,
      ));
    }
    return Result.success(null);
  }

  @override
  Future<Result<DefensivosStatsEntity>> getDefensivosStats() async {
    if (_shouldReturnError) {
      return Result.failure(RepositoryError(
        repositoryName: 'MockRepository',
        operation: 'getDefensivosStats',
        message: _errorMessage,
      ));
    }

    return Result.success(const DefensivosStatsEntity(
      totalDefensivos: 100,
      totalFabricantes: 20,
      totalModosDeAcao: 15,
      totalIngredientesAtivos: 50,
      totalClassesAgronomicas: 10,
    ));
  }

  @override
  Future<Result<List<DefensivoEntity>>> getRecentlyAccessedDefensivos() async {
    if (_shouldReturnError) {
      return Result.failure(RepositoryError(
        repositoryName: 'MockRepository',
        operation: 'getRecentlyAccessedDefensivos',
        message: _errorMessage,
      ));
    }

    return Result.success([
      const DefensivoEntity(
        id: '1',
        nomeComercial: 'Defensivo Teste',
        fabricante: 'Fabricante Teste',
        classeAgronomica: 'Herbicida',
        ingredienteAtivo: 'Glifosato',
        modoDeAcao: 'Sistêmico',
        isNew: false,
        lastAccessed: null,
      ),
    ]);
  }

  @override
  Future<Result<List<DefensivoEntity>>> getNewDefensivos() async {
    if (_shouldReturnError) {
      return Result.failure(RepositoryError(
        repositoryName: 'MockRepository',
        operation: 'getNewDefensivos',
        message: _errorMessage,
      ));
    }

    return Result.success([
      const DefensivoEntity(
        id: '2',
        nomeComercial: 'Defensivo Novo',
        fabricante: 'Fabricante Novo',
        classeAgronomica: 'Fungicida',
        ingredienteAtivo: 'Tebuconazol',
        modoDeAcao: 'Protetor',
        isNew: true,
        lastAccessed: null,
      ),
    ]);
  }

  // Implementações vazias para outros métodos não usados neste teste
  @override
  Future<Result<DefensivoEntity>> getDefensivoById(String id) async =>
      Result.failure(RepositoryError(
        repositoryName: 'MockRepository',
        operation: 'getDefensivoById',
        message: 'Not implemented',
      ));

  @override
  Future<Result<List<DefensivoEntity>>> getDefensivosByCategory(String category) async =>
      Result.success([]);

  @override
  Future<Result<void>> registerDefensivoAccess(String defensivoId) async =>
      Result.success(null);

  @override
  Future<Result<List<String>>> getClassesAgronomicas() async => Result.success([]);

  @override
  Future<Result<List<String>>> getFabricantes() async => Result.success([]);

  @override
  Future<Result<List<String>>> getModosDeAcao() async => Result.success([]);

  @override
  Future<Result<List<String>>> getIngredientesAtivos() async => Result.success([]);

  @override
  Future<Result<void>> dispose() async => Result.success(null);
}

/// Exemplo de teste unitário para o UseCase
/// 
/// Demonstra como testar a lógica de negócio isoladamente
class GetDefensivosHomeDataUseCaseTest {
  static Future<void> runTests() async {
    final mockRepository = MockDefensivosRepository();
    final mapper = DefensivosMapper();
    final useCase = GetDefensivosHomeDataUseCase(mockRepository, mapper);

    // Teste de sucesso
    await testSuccess(useCase, mockRepository);
    
    // Teste de erro no repositório
    await testRepositoryError(useCase, mockRepository);
    
    // Teste com dados não carregados
    await testDataNotLoaded(useCase, mockRepository);

    print('✅ Todos os testes passaram! Clean Architecture permite testes isolados.');
  }

  static Future<void> testSuccess(
    GetDefensivosHomeDataUseCase useCase,
    MockDefensivosRepository mockRepository,
  ) async {
    // Arrange
    mockRepository.setDataLoaded(true);
    mockRepository.setError(false);

    // Act
    final result = await useCase.execute();

    // Assert
    assert(result.isSuccess, 'UseCase deveria retornar sucesso');
    final data = result.valueOrNull!;
    assert(data.stats.totalDefensivos == 100, 'Stats deveriam estar corretas');
    assert(data.recentlyAccessed.length == 1, 'Deveria ter 1 item recente');
    assert(data.newProducts.length == 1, 'Deveria ter 1 produto novo');

    print('✅ Teste de sucesso passou');
  }

  static Future<void> testRepositoryError(
    GetDefensivosHomeDataUseCase useCase,
    MockDefensivosRepository mockRepository,
  ) async {
    // Arrange
    mockRepository.setDataLoaded(true);
    mockRepository.setError(true, 'Erro simulado');

    // Act
    final result = await useCase.execute();

    // Assert
    assert(result.isFailure, 'UseCase deveria retornar erro');
    assert(result.errorOrNull!.message.contains('Erro simulado'), 'Erro deveria conter mensagem');

    print('✅ Teste de erro passou');
  }

  static Future<void> testDataNotLoaded(
    GetDefensivosHomeDataUseCase useCase,
    MockDefensivosRepository mockRepository,
  ) async {
    // Arrange
    mockRepository.setDataLoaded(false);
    mockRepository.setError(false);

    // Act
    final result = await useCase.execute();

    // Assert
    assert(result.isSuccess, 'UseCase deveria inicializar e retornar sucesso');

    print('✅ Teste de inicialização passou');
  }
}

/// Para executar os testes, chame:
/// await GetDefensivosHomeDataUseCaseTest.runTests();