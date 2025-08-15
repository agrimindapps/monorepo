import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';

// Import dos models Hive
import '../models/cultura_hive.dart';
import '../models/diagnostico_hive.dart';
import '../models/fitossanitario_hive.dart';
import '../models/fitossanitario_info_hive.dart';
import '../models/plantas_inf_hive.dart';
import '../models/pragas_hive.dart';
import '../models/pragas_inf_hive.dart';

/// Serviço específico do Hive para ReceitaAgro
/// Gerencia boxes estáticas (sem sincronização) para dados dos JSONs
class ReceitaAgroHiveService {
  static const String _boxCulturas = 'receituagro_culturas_static';
  static const String _boxDiagnosticos = 'receituagro_diagnosticos_static';
  static const String _boxFitossanitarios = 'receituagro_fitossanitarios_static';
  static const String _boxFitossanitariosInfo = 'receituagro_fitossanitarios_info_static';
  static const String _boxPlantasInf = 'receituagro_plantas_inf_static';
  static const String _boxPragas = 'receituagro_pragas_static';
  static const String _boxPragasInf = 'receituagro_pragas_inf_static';

  static bool _isInitialized = false;

  /// Inicializa o Hive e registra todos os adapters
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Registra todos os adapters Hive
    await _registerAdapters();

    _isInitialized = true;
  }

  /// Registra todos os adapters das classes ReceitaAgro
  static Future<void> _registerAdapters() async {
    // TODO: Registrar adapters quando forem gerados com build_runner
    // Verifica se já foram registrados para evitar duplicatas
    // if (!Hive.isAdapterRegistered(100)) {
    //   Hive.registerAdapter(CulturaHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(101)) {
    //   Hive.registerAdapter(DiagnosticoHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(102)) {
    //   Hive.registerAdapter(FitossanitarioHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(103)) {
    //   Hive.registerAdapter(FitossanitarioInfoHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(104)) {
    //   Hive.registerAdapter(PlantasInfHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(105)) {
    //   Hive.registerAdapter(PragasHiveAdapter());
    // }
    // if (!Hive.isAdapterRegistered(106)) {
    //   Hive.registerAdapter(PragasInfHiveAdapter());
    // }
    print('Adapters Hive não registrados - executar: dart run build_runner build');
  }

  /// Abre todas as boxes necessárias
  static Future<void> openBoxes() async {
    await initialize();

    // TODO: Abrir boxes quando adapters estiverem disponíveis
    // await Future.wait([
    //   Hive.openBox<CulturaHive>(_boxCulturas),
    //   Hive.openBox<DiagnosticoHive>(_boxDiagnosticos),
    //   Hive.openBox<FitossanitarioHive>(_boxFitossanitarios),
    //   Hive.openBox<FitossanitarioInfoHive>(_boxFitossanitariosInfo),
    //   Hive.openBox<PlantasInfHive>(_boxPlantasInf),
    //   Hive.openBox<PragasHive>(_boxPragas),
    //   Hive.openBox<PragasInfHive>(_boxPragasInf),
    // ]);
    
    // Versão temporária com boxes de Map
    await Future.wait([
      Hive.openBox<Map>(_boxCulturas),
      Hive.openBox<Map>(_boxDiagnosticos),
      Hive.openBox<Map>(_boxFitossanitarios),
      Hive.openBox<Map>(_boxFitossanitariosInfo),
      Hive.openBox<Map>(_boxPlantasInf),
      Hive.openBox<Map>(_boxPragas),
      Hive.openBox<Map>(_boxPragasInf),
    ]);
  }

  // ==================== CULTURAS ====================

  /// Salva culturas dos dados do JSON
  static Future<void> saveCulturas(List<Map<String, dynamic>> culturasJson, String appVersion) async {
    final box = Hive.box<CulturaHive>(_boxCulturas);

    // Verifica se já foi carregado para esta versão
    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) {
      return; // Já está atualizado
    }

    // Limpa dados antigos
    await box.clear();

    // Carrega novos dados
    for (final culturaJson in culturasJson) {
      final cultura = CulturaHive.fromJson(culturaJson);
      await box.put(cultura.idReg, cultura);
    }

    // Marca a versão
    await box.put(versionKey, appVersion);
  }

  /// Obtém todas as culturas
  static List<CulturaHive> getCulturas() {
    final box = Hive.box<CulturaHive>(_boxCulturas);
    return box.values.where((cultura) => cultura.idReg != '_app_version').toList();
  }

  /// Busca cultura por ID
  static CulturaHive? getCulturaById(String idReg) {
    final box = Hive.box<CulturaHive>(_boxCulturas);
    return box.get(idReg);
  }

  // ==================== DIAGNÓSTICOS ====================

  /// Salva diagnósticos dos dados do JSON
  static Future<void> saveDiagnosticos(List<Map<String, dynamic>> diagnosticosJson, String appVersion) async {
    final box = Hive.box<DiagnosticoHive>(_boxDiagnosticos);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final diagnosticoJson in diagnosticosJson) {
      final diagnostico = DiagnosticoHive.fromJson(diagnosticoJson);
      await box.put(diagnostico.idReg, diagnostico);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém todos os diagnósticos
  static List<DiagnosticoHive> getDiagnosticos() {
    final box = Hive.box<DiagnosticoHive>(_boxDiagnosticos);
    return box.values.where((diag) => diag.idReg != '_app_version').toList();
  }

  /// Busca diagnóstico por praga e cultura
  static List<DiagnosticoHive> getDiagnosticosByPragaCultura(String pragaId, String culturaId) {
    final box = Hive.box<DiagnosticoHive>(_boxDiagnosticos);
    return box.values
        .where((diag) => diag.fkIdPraga == pragaId && diag.fkIdCultura == culturaId)
        .toList();
  }

  // ==================== FITOSSANITÁRIOS ====================

  /// Salva fitossanitários dos dados do JSON
  static Future<void> saveFitossanitarios(List<Map<String, dynamic>> fitossanitariosJson, String appVersion) async {
    final box = Hive.box<FitossanitarioHive>(_boxFitossanitarios);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final fitossanitarioJson in fitossanitariosJson) {
      final fitossanitario = FitossanitarioHive.fromJson(fitossanitarioJson);
      await box.put(fitossanitario.idReg, fitossanitario);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém todos os fitossanitários
  static List<FitossanitarioHive> getFitossanitarios() {
    final box = Hive.box<FitossanitarioHive>(_boxFitossanitarios);
    return box.values.where((fito) => fito.idReg != '_app_version').toList();
  }

  /// Busca fitossanitário por ID
  static FitossanitarioHive? getFitossanitarioById(String idReg) {
    final box = Hive.box<FitossanitarioHive>(_boxFitossanitarios);
    return box.get(idReg);
  }

  // ==================== FITOSSANITÁRIOS INFO ====================

  /// Salva informações dos fitossanitários
  static Future<void> saveFitossanitariosInfo(List<Map<String, dynamic>> fitossanitariosInfoJson, String appVersion) async {
    final box = Hive.box<FitossanitarioInfoHive>(_boxFitossanitariosInfo);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final infoJson in fitossanitariosInfoJson) {
      final info = FitossanitarioInfoHive.fromJson(infoJson);
      await box.put(info.idReg, info);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém informações de fitossanitário por ID do defensivo
  static FitossanitarioInfoHive? getFitossanitarioInfoByDefensivoId(String defensivoId) {
    final box = Hive.box<FitossanitarioInfoHive>(_boxFitossanitariosInfo);
    return box.values.firstWhere(
      (info) => info.fkIdDefensivo == defensivoId,
      orElse: () => throw StateError('Não encontrado'),
    );
  }

  // ==================== PRAGAS ====================

  /// Salva pragas dos dados do JSON
  static Future<void> savePragas(List<Map<String, dynamic>> pragasJson, String appVersion) async {
    final box = Hive.box<PragasHive>(_boxPragas);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final pragaJson in pragasJson) {
      final praga = PragasHive.fromJson(pragaJson);
      await box.put(praga.idReg, praga);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém todas as pragas
  static List<PragasHive> getPragas() {
    final box = Hive.box<PragasHive>(_boxPragas);
    return box.values.where((praga) => praga.idReg != '_app_version').toList();
  }

  /// Busca praga por ID
  static PragasHive? getPragaById(String idReg) {
    final box = Hive.box<PragasHive>(_boxPragas);
    return box.get(idReg);
  }

  // ==================== PRAGAS INFO ====================

  /// Salva informações das pragas
  static Future<void> savePragasInfo(List<Map<String, dynamic>> pragasInfoJson, String appVersion) async {
    final box = Hive.box<PragasInfHive>(_boxPragasInf);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final infoJson in pragasInfoJson) {
      final info = PragasInfHive.fromJson(infoJson);
      await box.put(info.idReg, info);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém informações de praga por ID da praga
  static PragasInfHive? getPragaInfoByPragaId(String pragaId) {
    final box = Hive.box<PragasInfHive>(_boxPragasInf);
    try {
      return box.values.firstWhere((info) => info.fkIdPraga == pragaId);
    } catch (e) {
      return null;
    }
  }

  // ==================== PLANTAS INFO ====================

  /// Salva informações das plantas
  static Future<void> savePlantasInfo(List<Map<String, dynamic>> plantasInfoJson, String appVersion) async {
    final box = Hive.box<PlantasInfHive>(_boxPlantasInf);

    final versionKey = '_app_version';
    final storedVersion = box.get(versionKey);

    if (storedVersion == appVersion) return;

    await box.clear();

    for (final infoJson in plantasInfoJson) {
      final info = PlantasInfHive.fromJson(infoJson);
      await box.put(info.idReg, info);
    }

    await box.put(versionKey, appVersion);
  }

  /// Obtém informações de planta por ID da praga
  static PlantasInfHive? getPlantaInfoByPragaId(String pragaId) {
    final box = Hive.box<PlantasInfHive>(_boxPlantasInf);
    try {
      return box.values.firstWhere((info) => info.fkIdPraga == pragaId);
    } catch (e) {
      return null;
    }
  }

  // ==================== UTILITÁRIOS ====================

  /// Verifica se todas as boxes estão atualizadas para a versão do app
  static bool isDataUpToDate(String appVersion) {
    final boxes = [
      Hive.box<CulturaHive>(_boxCulturas),
      Hive.box<DiagnosticoHive>(_boxDiagnosticos),
      Hive.box<FitossanitarioHive>(_boxFitossanitarios),
      Hive.box<PragasHive>(_boxPragas),
    ];

    for (final box in boxes) {
      final storedVersion = box.get('_app_version');
      if (storedVersion != appVersion) {
        return false;
      }
    }

    return true;
  }

  /// Carrega todos os dados estáticos de uma vez
  static Future<void> loadAllStaticData({
    required String appVersion,
    required List<Map<String, dynamic>> culturasJson,
    required List<Map<String, dynamic>> diagnosticosJson,
    required List<Map<String, dynamic>> fitossanitariosJson,
    required List<Map<String, dynamic>> fitossanitariosInfoJson,
    required List<Map<String, dynamic>> pragasJson,
    required List<Map<String, dynamic>> pragasInfoJson,
    required List<Map<String, dynamic>> plantasInfoJson,
  }) async {
    if (isDataUpToDate(appVersion)) {
      return; // Já está atualizado
    }

    await openBoxes();

    await Future.wait([
      saveCulturas(culturasJson, appVersion),
      saveDiagnosticos(diagnosticosJson, appVersion),
      saveFitossanitarios(fitossanitariosJson, appVersion),
      saveFitossanitariosInfo(fitossanitariosInfoJson, appVersion),
      savePragas(pragasJson, appVersion),
      savePragasInfo(pragasInfoJson, appVersion),
      savePlantasInfo(plantasInfoJson, appVersion),
    ]);
  }

  /// Fecha todas as boxes
  static Future<void> closeBoxes() async {
    await Future.wait([
      Hive.box<CulturaHive>(_boxCulturas).close(),
      Hive.box<DiagnosticoHive>(_boxDiagnosticos).close(),
      Hive.box<FitossanitarioHive>(_boxFitossanitarios).close(),
      Hive.box<FitossanitarioInfoHive>(_boxFitossanitariosInfo).close(),
      Hive.box<PlantasInfHive>(_boxPlantasInf).close(),
      Hive.box<PragasHive>(_boxPragas).close(),
      Hive.box<PragasInfHive>(_boxPragasInf).close(),
    ]);
  }
}