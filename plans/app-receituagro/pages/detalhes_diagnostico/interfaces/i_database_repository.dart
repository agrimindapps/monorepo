// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Interface Database Repository
// DESCRIÇÃO: Contrato para acesso aos dados do banco
// RESPONSABILIDADES: Definir acesso a diagnósticos, defensivos, pragas, culturas
// DEPENDÊNCIAS: Nenhuma (interface pura)
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

/// Interface para repositório de banco de dados
abstract class IDatabaseRepository {
  /// Lista de diagnósticos
  List<dynamic> get gDiagnosticos;

  /// Lista de fitossanitários
  List<dynamic> get gFitossanitarios;

  /// Lista de pragas
  List<dynamic> get gPragas;

  /// Lista de culturas
  List<dynamic> get gCulturas;

  /// Lista de informações de fitossanitários
  List<dynamic> get gFitossanitariosInfo;

  /// Carrega dados do repositório
  Future<void> loadData();

  /// Atualiza dados do repositório
  Future<void> refreshData();
}
