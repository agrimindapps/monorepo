// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/services/logging_service.dart';
import '../repository/database_repository.dart';
import 'database_index_service.dart';

/// Service centralizado para queries otimizadas com índices e cache
/// Substitui buscas lineares por lookups O(1) e O(log n)
class OptimizedQueryService extends GetxController {
  static OptimizedQueryService get instance => Get.find<OptimizedQueryService>();
  
  late final DatabaseIndexService _indexService;
  late final DatabaseRepository _databaseRepository;
  
  // Flag para controlar se índices foram criados
  bool _indexesInitialized = false;
  
  @override
  void onInit() {
    super.onInit();
    _indexService = DatabaseIndexService();
    _databaseRepository = Get.find<DatabaseRepository>();
    
    // Aguardar dados serem carregados antes de criar índices
    ever(_databaseRepository.isLoaded, (bool loaded) {
      if (loaded && !_indexesInitialized) {
        _initializeIndexes();
      }
    });
  }
  
  /// Inicializa todos os índices necessários
  Future<void> _initializeIndexes() async {
    try {
      if (!_databaseRepository.isLoaded.value) return;
      
      // Fitossanitários (defensivos)
      await _createFitossanitariosIndexes();
      
      // Pragas
      await _createPragasIndexes();
      
      // Diagnósticos
      await _createDiagnosticosIndexes();
      
      // Culturas
      await _createCulturasIndexes();
      
      // FitossanitáriosInfo
      await _createFitossanitariosInfoIndexes();
      
      // PragasInf e PlantasInf
      await _createInfIndexes();
      
      _indexesInitialized = true;
    } catch (e) {
      LoggingService.error('Erro ao inicializar índices: $e', tag: 'OptimizedQueryService');
    }
  }
  
  Future<void> _createFitossanitariosIndexes() async {
    final data = _databaseRepository.gFitossanitarios.map((f) => f.toJson()).toList();
    
    // Índice principal por ID
    _indexService.createIdIndex('fitossanitarios', data, 'idReg');
    
    // Índices por campos frequentemente buscados
    _indexService.createFieldIndex('fitossanitarios', 'classeAgronomica', data);
    _indexService.createFieldIndex('fitossanitarios', 'fabricante', data);
    _indexService.createFieldIndex('fitossanitarios', 'ingredienteAtivo', data);
    _indexService.createFieldIndex('fitossanitarios', 'nomeComercial', data);
    _indexService.createFieldIndex('fitossanitarios', 'tipoProduto', data);
    
    // Índice composto para buscas complexas
    _indexService.createCompositeIndex('fitossanitarios', ['fabricante', 'classeAgronomica'], data);
  }
  
  Future<void> _createPragasIndexes() async {
    final data = _databaseRepository.gPragas.map((p) => p.toJson()).toList();
    
    _indexService.createIdIndex('pragas', data, 'idReg');
    _indexService.createFieldIndex('pragas', 'tipoPraga', data);
    _indexService.createFieldIndex('pragas', 'nomeComum', data);
    _indexService.createFieldIndex('pragas', 'nomeCientifico', data);
  }
  
  Future<void> _createDiagnosticosIndexes() async {
    final data = _databaseRepository.gDiagnosticos.map((d) => d.toJson()).toList();
    
    _indexService.createIdIndex('diagnosticos', data, 'idReg');
    _indexService.createFieldIndex('diagnosticos', 'fkIdDefensivo', data);
    _indexService.createFieldIndex('diagnosticos', 'fkIdPraga', data);
    _indexService.createFieldIndex('diagnosticos', 'fkIdCultura', data);
    
    // Índices compostos para queries comuns
    _indexService.createCompositeIndex('diagnosticos', ['fkIdDefensivo', 'fkIdCultura'], data);
    _indexService.createCompositeIndex('diagnosticos', ['fkIdPraga', 'fkIdCultura'], data);
  }
  
  Future<void> _createCulturasIndexes() async {
    final data = _databaseRepository.gCulturas.map((c) => c.toJson()).toList();
    
    _indexService.createIdIndex('culturas', data, 'idReg');
    _indexService.createFieldIndex('culturas', 'cultura', data);
  }
  
  Future<void> _createFitossanitariosInfoIndexes() async {
    final data = _databaseRepository.gFitossanitariosInfo.map((f) => f.toJson()).toList();
    
    _indexService.createIdIndex('fitossanitarios_info', data, 'idReg');
    _indexService.createFieldIndex('fitossanitarios_info', 'fkIdDefensivo', data);
  }
  
  Future<void> _createInfIndexes() async {
    final pragasInfData = _databaseRepository.gPragasInf.map((p) => p.toJson()).toList();
    final plantasInfData = _databaseRepository.gPlantasInf.map((p) => p.toJson()).toList();
    
    _indexService.createIdIndex('pragas_inf', pragasInfData, 'idReg');
    _indexService.createFieldIndex('pragas_inf', 'fkIdPraga', pragasInfData);
    
    _indexService.createIdIndex('plantas_inf', plantasInfData, 'idReg');
    _indexService.createFieldIndex('plantas_inf', 'fkIdPraga', plantasInfData);
  }
  
  // === MÉTODOS PÚBLICOS PARA QUERIES OTIMIZADAS ===
  
  /// Busca defensivo por ID - O(1)
  Map<String, dynamic>? findDefensivoById(String id) {
    return _indexService.findById('fitossanitarios', id);
  }
  
  /// Busca múltiplos defensivos por IDs - O(n) onde n = número de IDs
  List<Map<String, dynamic>> batchFindDefensivosByIds(List<String> ids) {
    return _indexService.batchFindByIds('fitossanitarios', ids);
  }
  
  /// Busca defensivos por fabricante
  List<Map<String, dynamic>> findDefensivosByFabricante(String fabricante) {
    return _indexService.findByField('fitossanitarios', 'fabricante', fabricante);
  }
  
  /// Busca defensivos por classe agronômica
  List<Map<String, dynamic>> findDefensivosByClasseAgronomica(String classe) {
    return _indexService.findByField('fitossanitarios', 'classeAgronomica', classe);
  }
  
  /// Busca defensivos por ingrediente ativo (contains)
  List<Map<String, dynamic>> findDefensivosByIngredienteAtivo(String ingrediente) {
    return _indexService.findByFieldContains('fitossanitarios', 'ingredienteAtivo', ingrediente);
  }
  
  /// Busca defensivos por nome comercial (contains)
  List<Map<String, dynamic>> findDefensivosByNomeComercial(String nome) {
    return _indexService.findByFieldContains('fitossanitarios', 'nomeComercial', nome);
  }
  
  /// Busca praga por ID - O(1)
  Map<String, dynamic>? findPragaById(String id) {
    return _indexService.findById('pragas', id);
  }
  
  /// Busca pragas por tipo
  List<Map<String, dynamic>> findPragasByTipo(String tipo) {
    return _indexService.findByField('pragas', 'tipoPraga', tipo);
  }
  
  /// Busca cultura por ID - O(1)
  Map<String, dynamic>? findCulturaById(String id) {
    return _indexService.findById('culturas', id);
  }
  
  /// Busca diagnóstico por ID - O(1)
  Map<String, dynamic>? findDiagnosticoById(String id) {
    return _indexService.findById('diagnosticos', id);
  }
  
  /// Busca diagnósticos por defensivo
  List<Map<String, dynamic>> findDiagnosticosByDefensivo(String defensivoId) {
    return _indexService.findByField('diagnosticos', 'fkIdDefensivo', defensivoId);
  }
  
  /// Busca diagnósticos por praga
  List<Map<String, dynamic>> findDiagnosticosByPraga(String pragaId) {
    return _indexService.findByField('diagnosticos', 'fkIdPraga', pragaId);
  }
  
  /// Busca diagnósticos por cultura
  List<Map<String, dynamic>> findDiagnosticosByCultura(String culturaId) {
    return _indexService.findByField('diagnosticos', 'fkIdCultura', culturaId);
  }
  
  /// Busca fitossanitário info por defensivo
  List<Map<String, dynamic>> findFitossanitarioInfoByDefensivo(String defensivoId) {
    return _indexService.findByField('fitossanitarios_info', 'fkIdDefensivo', defensivoId);
  }
  
  /// Busca com múltiplos filtros
  List<Map<String, dynamic>> findDefensivosWithFilters(Map<String, String> filters) {
    return _indexService.findByMultipleFields('fitossanitarios', filters);
  }
  
  /// Busca pragas inf por praga
  List<Map<String, dynamic>> findPragasInfByPraga(String pragaId) {
    return _indexService.findByField('pragas_inf', 'fkIdPraga', pragaId);
  }
  
  /// Busca plantas inf por praga
  List<Map<String, dynamic>> findPlantasInfByPraga(String pragaId) {
    return _indexService.findByField('plantas_inf', 'fkIdPraga', pragaId);
  }
  
  /// Busca otimizada para texto livre (nome comercial OU ingrediente ativo)
  List<Map<String, dynamic>> searchDefensivos(String query) {
    if (query.isEmpty) return [];
    
    final byNome = _indexService.findByFieldContains('fitossanitarios', 'nomeComercial', query);
    final byIngrediente = _indexService.findByFieldContains('fitossanitarios', 'ingredienteAtivo', query);
    
    // Unir resultados removendo duplicatas por ID
    final allResults = <String, Map<String, dynamic>>{};
    
    for (final item in byNome) {
      allResults[item['idReg']] = item;
    }
    
    for (final item in byIngrediente) {
      allResults[item['idReg']] = item;
    }
    
    return allResults.values.toList();
  }
  
  /// Conta registros por campo específico (mais eficiente que .where().length)
  int countByField(String tableName, String fieldName, String value) {
    final results = _indexService.findByField(tableName, fieldName, value);
    return results.length;
  }
  
  /// Obtém valores únicos de um campo (para dropdowns, etc)
  List<String> getUniqueValues(String tableName, String fieldName) {
    // Usar estatísticas dos índices se possível
    return _databaseRepository.gFitossanitarios
        .map((f) => f.toJson()[fieldName]?.toString())
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
        ..sort();
  }
  
  /// Rebuida índices quando dados são atualizados
  Future<void> rebuildIndexes() async {
    _indexesInitialized = false;
    await _initializeIndexes();
  }
  
  /// Obtém estatísticas de performance
  Map<String, dynamic> getPerformanceStats() {
    return _indexService.getIndexStats();
  }
  
  /// Invalida cache para refresh de dados
  void invalidateCache() {
    _indexService.invalidateCache('fitossanitarios');
    _indexService.invalidateCache('pragas');
    _indexService.invalidateCache('diagnosticos');
    _indexService.invalidateCache('culturas');
    _indexService.invalidateCache('fitossanitarios_info');
    _indexService.invalidateCache('pragas_inf');
    _indexService.invalidateCache('plantas_inf');
  }
  
  @override
  void onClose() {
    _indexService.dispose();
    super.onClose();
  }
}