// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Implementação Database Repository
// DESCRIÇÃO: Implementação concreta do repositório de banco de dados
// RESPONSABILIDADES: Adapter para DatabaseRepository global
// DEPENDÊNCIAS: DatabaseRepository global, interface IDatabaseRepository
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Project imports:
import '../../../repository/database_repository.dart';
import '../interfaces/i_database_repository.dart';

/// Implementação do repositório de banco de dados
class DatabaseRepositoryImpl implements IDatabaseRepository {
  final DatabaseRepository _databaseRepository;

  DatabaseRepositoryImpl(this._databaseRepository);

  @override
  List<dynamic> get gDiagnosticos => _databaseRepository.gDiagnosticos;

  @override
  List<dynamic> get gFitossanitarios => _databaseRepository.gFitossanitarios;

  @override
  List<dynamic> get gPragas => _databaseRepository.gPragas;

  @override
  List<dynamic> get gCulturas => _databaseRepository.gCulturas;

  @override
  List<dynamic> get gFitossanitariosInfo =>
      _databaseRepository.gFitossanitariosInfo;

  @override
  Future<void> loadData() async {
    // A implementação específica depende dos métodos disponíveis no DatabaseRepository
    return;
  }

  @override
  Future<void> refreshData() async {
    // A implementação específica depende dos métodos disponíveis no DatabaseRepository
    return;
  }
}
