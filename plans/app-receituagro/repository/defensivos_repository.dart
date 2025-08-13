// Package imports:
// Project imports:
import 'database_repository.dart';
import 'services/defensivos_business_service.dart';
import 'services/defensivos_cache.dart';
import 'services/defensivos_data_access.dart';
import 'services/defensivos_formatter.dart';

/// Facade Repository para Defensivos
/// Mantém interface pública, delegando responsabilidades para services especializados
class DefensivosRepository {
  // Services especializados
  late final DefensivosDataAccess _dataAccess;
  late final DefensivosCache _cache;
  late final DefensivosFormatter _formatter;
  late final DefensivosBusinessService _businessService;
  
  // Estado interno
  bool finalPage = false;
  String searchCultura = '';
  
  DefensivosRepository() {
    _initializeServices();
  }
  
  /// Inicializa todos os services
  void _initializeServices() {
    _dataAccess = DefensivosDataAccess();
    _cache = DefensivosCache();
    _formatter = DefensivosFormatter();
    _businessService = DefensivosBusinessService(_dataAccess, _formatter);
  }

  void dispose() {
    searchCultura = '';
  }

  /// Obtém referência ao DatabaseRepository para verificação de carregamento
  /// Usado pelos controllers para aguardar inicialização
  DatabaseRepository getDatabaseRepository() {
    return _dataAccess.databaseRepository;
  }

  List<Map<String, dynamic>> getClasseAgronomica() {
    try {
      if (!_dataAccess.isDataLoaded) return [];

      final items = _businessService.extractUniqueCategories(
        source: _dataAccess.getAllFitossanitarios(),
        field: 'classeAgronomica',
      );

      return _businessService.createCategoryList(
        items: items,
        countField: 'classeAgronomica',
      );
    } catch (e) {
      return [];
    }
  }

  int getClasseAgronomicaCount() {
    final items = getClasseAgronomica();
    return items.length;
  }

  List<Map<String, dynamic>> getClasseAgronomicaById(String value) {
    final items = _businessService.filterAndSortItems(value, 'classeAgronomica');
    return _formatter.formatCategoryItems(items, false);
  }

  List<Map<String, dynamic>> getDefensivos() {
    return _formatter.formatDefensivosItems(
      _dataAccess.getAllFitossanitarios(),
    );
  }

  int getDefensivosCount() {
    final items = _formatter.formatDefensivosItems(
      _dataAccess.getAllFitossanitarios(),
    );
    return items.length;
  }

  Future<Map<String, dynamic>> getDefensivoById(String idReg) async {
    final dataFito = _dataAccess.getFitossanitarioById(idReg);
    if (dataFito.isEmpty) return {};

    await setDefensivoAcessado(defensivoId: idReg);

    return dataFito;
  }

  Future<Map<String, dynamic>> getDefensivosInfo(String id) async {
    try {
      final defensivo = _dataAccess.getFitossanitarioById(id);
      if (defensivo.isEmpty) return {};

      final fitossanitarioInfo = _dataAccess.getFitossanitarioInfoById(id);
      
      return _businessService.combineDefensivoInfo(defensivo, fitossanitarioInfo);
    } catch (e) {
      return {};
    }
  }

  List<Map<String, dynamic>> getDefensivoDiagnosticos(String id, int type) {
    final field = type == 1 ? 'fkIdDefensivo' : 'fkIdPraga';
    final diagnostics = _dataAccess.getDiagnosticsByField(field, id);
    if (diagnostics.isEmpty) return [];

    final processedDiagnostics = _businessService.processDiagnostics(diagnostics);
    final organizedData = _businessService.organizePorCultura(processedDiagnostics, type);

    return organizedData;
  }

  Future<List<Map<String, dynamic>>> getDefensivosAcessados() async {
    try {
      final dataFitos = _dataAccess.getAllFitossanitarios();
      return await _cache.getRecentItems(dataFitos);
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getDefensivosNovos() {
    try {
      return _dataAccess.getNewestFitossanitarios();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getFabricante() {
    final manufacturers = _businessService.extractUniqueManufacturers();
    return _formatter.formatManufacturers(
      manufacturers,
      (manufacturer) => _dataAccess.countRecordsByField('fabricante', manufacturer),
    );
  }

  int getFabricanteCount() {
    final items = getFabricante();
    return items.length;
  }

  List<Map<String, dynamic>> getFabricanteById(String value) {
    final items = _businessService.filterAndSortManufacturerItems(value);
    return _formatter.formatDefensivosItems(items);
  }

  List<Map<String, dynamic>> getIngredienteAtivo() {
    final items = _businessService.extractUniqueCategories(
      source: _dataAccess.getAllFitossanitarios(),
      field: 'ingredienteAtivo',
      separator: '+',
    );

    return _businessService.createCategoryList(
      items: items,
      countField: 'ingredienteAtivo',
    );
  }

  List<Map<String, dynamic>> getIngredienteAtivoById(String value) {
    final items = _businessService.filterAndSortItems(value, 'ingredienteAtivo');
    return _formatter.formatCategoryItems(items, true);
  }

  int getIngredienteAtivoCount() {
    final items = getIngredienteAtivo();
    return items.length;
  }

  List<Map<String, dynamic>> getModoDeAcao() {
    final items = _businessService.extractUniqueCategories(
      source: _dataAccess.getAllFitossanitarios(),
      field: 'modoAcao',
    );

    return _businessService.createCategoryList(
      items: items,
      countField: 'modoAcao',
    );
  }

  int getModoDeAcaoCount() {
    final items = getModoDeAcao();
    return items.length;
  }

  List<Map<String, dynamic>> getModoDeAcaoById(String value) {
    final items = _businessService.filterAndSortItems(value, 'modoAcao');
    return _formatter.formatCategoryItems(items, false);
  }

  void initInfo() {}

  bool isLastPage() => finalPage;

  void resetPage() {
    finalPage = false;
  }

  Future<void> setDefensivoAcessado({String? defensivoId}) async {
    try {
      if (defensivoId == null || defensivoId.isEmpty) return;
      
      await _cache.addRecentItem(defensivoId);
      await getDefensivosAcessados();
    } catch (e) {
      // Error is handled within cache service
    }
  }

  void setFinalPage(bool value) {
    finalPage = value;
  }

}
