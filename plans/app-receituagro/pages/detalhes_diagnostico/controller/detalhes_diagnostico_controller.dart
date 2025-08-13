// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Controller Principal
// DESCRIÇÃO: Gerencia estado e lógica de negócio da página de detalhes de diagnóstico
// RESPONSABILIDADES: Estado reativo, loading states, TTS, favoritos, premium
// DEPENDÊNCIAS: GetX Controller, Services interfaces, Models
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../core/cache/i_cache_service.dart';
import '../../../services/premium_service.dart';
import '../interfaces/i_database_repository.dart';
import '../interfaces/i_favorite_service.dart';
import '../interfaces/i_local_storage_service.dart';
import '../interfaces/i_tts_service.dart';
import '../models/diagnostic_data.dart';
import '../models/diagnostico_details_model.dart';
import '../models/loading_state.dart';
import '../services/diagnostico_performance_service.dart';

class DetalhesDiagnosticoController extends GetxController {
  // Serviços injetados
  late final ITtsService _ttsService;
  late final ILocalStorageService _localStorageService;
  late final PremiumService _premiumService;
  late final IDatabaseRepository _databaseRepository;
  late final IFavoriteService _favoriteService;
  late final ICacheService _cacheService;
  late final DiagnosticoPerformanceService _performanceService;

  // Gerenciador de estados de loading padronizado
  final LoadingStateManager _loadingManager = LoadingStateManager();
  final Rx<LoadingStateManager> loadingManager = LoadingStateManager().obs;

  // Estado reativo
  final RxBool isPremium = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isTtsSpeaking = false.obs;
  final RxDouble fontSize = 14.0.obs;

  // Dados do diagnóstico
  final Rx<DiagnosticoDetailsModel> diagnostico =
      DiagnosticoDetailsModel.empty().obs;

  String get diagnosticoId {
    final args = Get.arguments;
    debugPrint(
        'DetalhesDiagnosticoController - Arguments recebidos: $args (type: ${args.runtimeType})');
    return args as String? ?? '';
  }

  // Getters para estados de loading específicos
  bool get isLoading => _loadingManager.hasAnyLoading;
  bool get isLoadingDiagnostic =>
      _loadingManager.isLoading(LoadingStateType.loadingDiagnostic);
  bool get isLoadingFavorite =>
      _loadingManager.isLoading(LoadingStateType.loadingFavorite);
  bool get isLoadingPremium =>
      _loadingManager.isLoading(LoadingStateType.loadingPremium);
  bool get isLoadingTts =>
      _loadingManager.isLoading(LoadingStateType.loadingTts);
  bool get isLoadingApplication =>
      _loadingManager.isLoading(LoadingStateType.loadingApplication);

  // Métodos para atualizar estados de loading
  void _setLoadingState(LoadingStateType type, bool loading,
      {String? message}) {
    if (loading) {
      _loadingManager.setLoading(type, message: message);
    } else {
      _loadingManager.setIdle(type);
    }
    loadingManager.refresh();
  }

  void _setSuccessState(LoadingStateType type, {String? message}) {
    _loadingManager.setSuccess(type, message: message);
    loadingManager.refresh();
  }

  void _setErrorState(LoadingStateType type, dynamic error, {String? message}) {
    _loadingManager.setError(type, error, message: message);
    loadingManager.refresh();
  }

  @override
  void onInit() {
    super.onInit();

    // Injeção de dependências via Get.find()
    _ttsService = Get.find<ITtsService>(tag: 'diagnostico');
    _localStorageService = Get.find<ILocalStorageService>();
    _premiumService = Get.find<PremiumService>();
    _databaseRepository = Get.find<IDatabaseRepository>();
    _favoriteService = Get.find<IFavoriteService>(tag: 'diagnostico');
    _cacheService = Get.find<ICacheService>();

    // Initialize performance service with dependencies
    _performanceService = DiagnosticoPerformanceService(
      databaseRepository: _databaseRepository,
      localStorageService: _localStorageService,
      premiumService: _premiumService,
      cacheService: _cacheService,
    );

    // Se recebeu ID via parâmetro, carregar o diagnóstico com otimização
    if (diagnosticoId.isNotEmpty) {
      loadDiagnosticoDataOptimized(diagnosticoId);
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Recarrega o status de favorito sempre que a página for exibida
    // Isso garante que o estado esteja correto ao vir de favoritos
    if (diagnosticoId.isNotEmpty) {
      _loadFavoriteStatusById(diagnosticoId);
    }
  }

  /// Verifica o status premium do usuário
  Future<void> _checkPremiumStatus() async {
    _setLoadingState(LoadingStateType.loadingPremium, true,
        message: 'Verificando status premium...');

    try {
      // Usar diretamente o PremiumService global - sem cache adicional
      isPremium.value = _premiumService.isPremium;
      _setSuccessState(LoadingStateType.loadingPremium,
          message: 'Status premium verificado');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingPremium, e,
          message: 'Erro ao verificar status premium');
      debugPrint('Erro ao verificar status premium: $e');
    }
  }

  /// Carrega os dados do diagnóstico
  Future<void> loadDiagnosticoData(String diagnosticoId) async {
    _setLoadingState(LoadingStateType.loadingDiagnostic, true,
        message: 'Carregando dados do diagnóstico...');

    try {
      await getDiagnosticoDetalhes(diagnosticoId);
      await _loadFavoriteStatus();
      _setSuccessState(LoadingStateType.loadingDiagnostic,
          message: 'Dados carregados com sucesso');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingDiagnostic, e,
          message: 'Erro ao carregar dados do diagnóstico');
      debugPrint('Erro ao carregar dados do diagnóstico: $e');
    }
  }

  /// Busca os detalhes do diagnóstico pelo ID
  Future<void> getDiagnosticoDetalhes(String id) async {
    try {
      final data = _fetchDiagnosticData(id);
      if (data == null) return;

      _updateDiagnosticoBasico(data);
      _updateDiagnosticoDosagem(data.diag);
      _updateDiagnosticoVazoes(data.diag);
      _updateDiagnosticoIntervalos(data.diag);
    } catch (e) {
      debugPrint('Erro ao obter detalhes do diagnóstico: $e');
    }
  }

  /// Busca os dados do diagnóstico no repositório de forma segura
  DiagnosticData? _fetchDiagnosticData(String id) {
    try {
      // Busca o diagnóstico pelo ID com validação segura
      final diagList = _databaseRepository.gDiagnosticos
          .map((d) => d.toJson())
          .where((r) => r['idReg'] == id)
          .toList();

      // Se não encontrou diagnóstico, retorna null
      if (diagList.isEmpty) {
        debugPrint('Diagnóstico não encontrado com ID: $id');
        return null;
      }

      final diag = diagList.first;
      final String? defensivoId = diag['fkIdDefensivo'] as String?;
      final String? pragaId = diag['fkIdPraga'] as String?;
      final String? culturaId = diag['fkIdCultura'] as String?;

      // Validação adicional para IDs relacionados
      if (defensivoId == null || defensivoId.isEmpty) {
        debugPrint('ID de defensivo inválido no diagnóstico: $id');
        return null;
      }

      // Busca defensivo
      final fitoList = _databaseRepository.gFitossanitarios
          .map((f) => f.toJson())
          .where((r) => r['idReg'] == defensivoId)
          .toList();
      final fito = fitoList.isNotEmpty ? fitoList.first : <String, dynamic>{};

      // Busca praga
      final pragaList = _databaseRepository.gPragas
          .map((p) => p.toJson())
          .where((r) => r['idReg'] == pragaId)
          .toList();
      final praga =
          pragaList.isNotEmpty ? pragaList.first : <String, dynamic>{};

      // Busca cultura
      final culturaList = _databaseRepository.gCulturas
          .map((c) => c.toJson())
          .where((r) => r['idReg'] == culturaId)
          .toList();
      final cultura =
          culturaList.isNotEmpty ? culturaList.first : <String, dynamic>{};

      // Busca info de fitossanitário
      final infoList = _databaseRepository.gFitossanitariosInfo
          .map((f) => f.toJson())
          .where((r) => r['fkIdDefensivo'] == defensivoId)
          .toList();
      final info = infoList.isNotEmpty ? infoList.first : <String, dynamic>{};

      return DiagnosticData(
        diag: diag,
        fito: fito,
        praga: praga,
        cultura: cultura,
        info: info,
      );
    } catch (e) {
      debugPrint('Erro ao buscar dados do diagnóstico: $e');
      return null;
    }
  }

  /// Atualiza as informações básicas do diagnóstico
  void _updateDiagnosticoBasico(DiagnosticData data) {
    diagnostico.value = diagnostico.value.copyWith(
      idReg: data.diag['idReg'],
      nomeDefensivo: data.fito['nomeComum'],
      nomePraga: data.praga['nomeComum'],
      nomeCientifico: data.praga['nomeCientifico'],
      cultura: data.cultura['cultura'],
      ingredienteAtivo:
          '${data.fito['ingredienteAtivo']} ${data.fito['quantProduto']}',
      toxico: data.fito['toxico'],
      classAmbiental: data.fito['classAmbiental'],
      classeAgronomica: data.fito['classeAgronomica'],
      formulacao: data.fito['formulacao'],
      modoAcao: data.fito['modoAcao'],
      mapa: data.fito['mapa'],
      tecnologia: data.info['tecnologia'],
    );
  }

  /// Atualiza as informações de dosagem
  void _updateDiagnosticoDosagem(Map<String, dynamic> diag) {
    final dosagem = formatDosagem(
      diag['dsMin'] ?? '',
      diag['dsMax'] ?? '',
      diag['um'] ?? '',
    );
    diagnostico.value = diagnostico.value.copyWith(dosagem: dosagem);
  }

  /// Atualiza as informações de vazão
  void _updateDiagnosticoVazoes(Map<String, dynamic> diag) {
    final vazaoTerrestre = formatVazao(
      diag['minAplicacaoT'] ?? '',
      diag['maxAplicacaoT'] ?? '',
      diag['umT'] ?? '',
      'Não Especificado',
    );
    final vazaoAerea = formatVazao(
      diag['minAplicacaoA'] ?? '',
      diag['maxAplicacaoA'] ?? '',
      diag['umA'] ?? '',
      'Não indicado para aplicações aéreas',
    );

    diagnostico.value = diagnostico.value.copyWith(
      vazaoTerrestre: vazaoTerrestre,
      vazaoAerea: vazaoAerea,
    );
  }

  /// Atualiza as informações de intervalos
  void _updateDiagnosticoIntervalos(Map<String, dynamic> diag) {
    final intervaloAplicacao = formatInterval(diag['intervalo']);
    final intervaloSeguranca = formatInterval(diag['intervalo2']);

    diagnostico.value = diagnostico.value.copyWith(
      intervaloAplicacao: intervaloAplicacao,
      intervaloSeguranca: intervaloSeguranca,
    );
  }

  /// Formata a vazão de aplicação
  String formatVazao(String min, String max, String um, String defaultText) {
    min = min.trim();
    max = max.trim();
    final vazao = max.isEmpty
        ? min
        : min.isNotEmpty
            ? '$min - $max'
            : max;
    return vazao.isEmpty ? defaultText : '$vazao $um';
  }

  /// Formata o intervalo de aplicação
  String formatInterval(String? interval) {
    return (interval?.length ?? 0) > 0 ? interval! : 'Não Especificado';
  }

  /// Formata a dosagem
  String formatDosagem(String min, String max, String um) {
    final hasMinDosage = min.isNotEmpty && min != '-';
    return hasMinDosage ? '$min - $max $um' : '$max $um';
  }

  /// Método público para recarregar o status de favorito
  Future<void> refreshFavoriteStatus() async {
    await _loadFavoriteStatusById(diagnosticoId);
  }

  /// Carrega o status de favorito usando um ID específico
  Future<void> _loadFavoriteStatusById(String id) async {
    if (id.isEmpty) return;
    
    _setLoadingState(LoadingStateType.loadingFavorite, true,
        message: 'Carregando status de favorito...');

    try {
      final isFav = await _favoriteService.isFavorite('favDiagnosticos', id);
      isFavorite.value = isFav;
      _setSuccessState(LoadingStateType.loadingFavorite,
          message: 'Status de favorito carregado');
      
      // Atualiza o header após carregar o status
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['app_bar']);
      });
    } catch (e) {
      _setErrorState(LoadingStateType.loadingFavorite, e,
          message: 'Erro ao carregar status de favorito');
      debugPrint('Erro ao carregar status de favorito: $e');
    }
  }

  /// Carrega o status de favorito do diagnóstico atual
  Future<void> _loadFavoriteStatus() async {
    final id = diagnostico.value.idReg;
    await _loadFavoriteStatusById(id);
  }

  /// Alterna o estado de favorito do diagnóstico atual
  Future<void> toggleFavorite() async {
    if (!_hasValidDiagnosticoData()) return;

    _setLoadingState(LoadingStateType.loadingFavorite, true,
        message: 'Atualizando favorito...');

    try {
      final id = diagnostico.value.idReg;
      final newFavoriteState =
          await _favoriteService.toggleFavorite('favDiagnosticos', id);
      isFavorite.value = newFavoriteState;

      // Update app bar UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['app_bar']);
      });

      _setSuccessState(LoadingStateType.loadingFavorite,
          message: newFavoriteState
              ? 'Adicionado aos favoritos'
              : 'Removido dos favoritos');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingFavorite, e,
          message: 'Erro ao atualizar favorito');
      debugPrint('Erro ao atualizar favorito: $e');
    }
  }

  /// Verifica se há dados válidos do diagnóstico
  bool _hasValidDiagnosticoData() {
    return diagnostico.value.idReg.isNotEmpty;
  }

  /// Alterna o estado de leitura TTS
  void toggleTts(String text) {
    if (isTtsSpeaking.value) {
      stopTts();
    } else {
      _startTts(text);
    }
  }

  /// Inicia a leitura TTS
  void _startTts(String text) async {
    if (text.trim().isEmpty) return;

    _setLoadingState(LoadingStateType.loadingTts, true,
        message: 'Iniciando leitura...');

    try {
      final cleanText = formatText(text).trim();
      await _ttsService.speak(cleanText);
      isTtsSpeaking.value = true;
      _setSuccessState(LoadingStateType.loadingTts,
          message: 'Leitura iniciada');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingTts, e,
          message: 'Erro ao iniciar leitura');
      debugPrint('Erro ao iniciar TTS: $e');
    }
  }

  /// Para a leitura TTS
  void stopTts() async {
    _setLoadingState(LoadingStateType.loadingTts, true,
        message: 'Parando leitura...');

    try {
      await _ttsService.stop();
      isTtsSpeaking.value = false;
      _setSuccessState(LoadingStateType.loadingTts, message: 'Leitura parada');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingTts, e,
          message: 'Erro ao parar leitura');
      debugPrint('Erro ao parar TTS: $e');
    }
  }

  /// Inicia a leitura TTS de um texto específico
  void speakText(String text) async {
    if (text.isEmpty) return;

    try {
      final cleanText = formatText(text).trim();
      await _ttsService.speak(cleanText);
      isTtsSpeaking.value = true;
    } catch (e) {
      debugPrint('Erro ao falar texto: $e');
    }
  }

  /// Compartilha as informações do diagnóstico
  void compartilhar() async {
    try {
      final data = diagnostico.value;

      String share = '''
Recomendação de Diagnóstico

Defensivo: ${data.nomeDefensivo}
Praga (Nome Comum): ${data.nomePraga}
Praga (Nome Científico): ${data.nomeCientifico}
Cultura: ${data.cultura}

Informações Gerais:
Ingrediente Ativo: ${_compart(data.ingredienteAtivo)}
Toxicologia: ${_compart(data.toxico)}
Classe Ambiental: ${_compart(data.classAmbiental)}
Classe Agronômica: ${_compart(data.classeAgronomica)}
Formulação: ${_compart(data.formulacao)}
Modo de Ação: ${_compart(data.modoAcao)}
Reg. MAPA: ${_compart(data.mapa)}

Aplicação:
Dosagem: ${_compart(data.dosagem)}
Vazão Terrestre: ${_compart(data.vazaoTerrestre)}
Vazão Aérea: ${_compart(data.vazaoAerea)}
Intervalo de Aplicação: ${_compart(data.intervaloAplicacao)}
Intervalo de Segurança: ${_compart(data.intervaloSeguranca)}

Modo de Aplicação: 
${formatText(_compart(data.tecnologia))}

''';

      // Usar SharePlus.instance.share()
      await SharePlus.instance.share(ShareParams(text: share));
    } catch (e) {
      debugPrint('Erro ao compartilhar: $e');
    }
  }

  String _compart(String value) {
    return value.isNotEmpty ? value : 'Não há informações';
  }

  /// Formata o texto removendo tags HTML
  String formatText(String text) {
    return text.replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n');
  }

  /// Formata listas de texto
  String formatList(String text) {
    if (text.isEmpty) return 'Não especificado';

    return text
        .replaceAll(RegExp(r'[;,]+'), ', ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Sanitiza o nome para URL
  String sanitizeForUrl(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '-');
  }

  /// Altera o tamanho da fonte
  void setFontSize(double size) {
    fontSize.value = size;
  }

  @override
  void onClose() {
    stopTts();
    super.onClose();
  }

  /// Carrega os dados do diagnóstico com otimização paralela
  Future<void> loadDiagnosticoDataOptimized(String diagnosticoId) async {
    // Set loading states for all operations
    _setLoadingState(LoadingStateType.loadingDiagnostic, true,
        message: 'Carregando dados...');
    _setLoadingState(LoadingStateType.loadingFavorite, true,
        message: 'Verificando favoritos...');
    _setLoadingState(LoadingStateType.loadingPremium, true,
        message: 'Verificando status premium...');

    try {
      // Load all data in parallel using performance service
      final result =
          await _performanceService.loadDiagnosticoDataParallel(diagnosticoId);

      // Process results
      if (result.diagnosticData != null) {
        _updateDiagnosticoFromData(result.diagnosticData!);
        _setSuccessState(LoadingStateType.loadingDiagnostic,
            message: 'Dados carregados com sucesso');
      } else {
        _setErrorState(
            LoadingStateType.loadingDiagnostic, 'Dados não encontrados',
            message: 'Diagnóstico não encontrado');
      }

      // Update reactive states
      isFavorite.value = result.isFavorite;
      isPremium.value = result.isPremium;

      // Set success states for completed operations
      _setSuccessState(LoadingStateType.loadingFavorite,
          message: 'Status de favorito carregado');
      _setSuccessState(LoadingStateType.loadingPremium,
          message: 'Status premium verificado');

      // Log performance improvement if there were no errors
      if (!result.hasErrors) {
        // Performance logs removed for production
      }

      // Handle partial results or errors with fallbacks
      if (result.hasErrors) {
        debugPrint('⚠️ Alguns dados falharam, usando fallbacks:');
        result.errors.forEach((key, error) {
          debugPrint('  - $key: $error');
          // Set individual error states but don't fail the whole operation
          _setErrorState(_getLoadingStateForOperation(key), error,
              message: 'Falha em $key, usando dados padrão');
        });
      }
    } catch (e) {
      // Fallback to sequential loading if parallel loading fails completely
      debugPrint('❌ Carregamento paralelo falhou, tentando sequencial: $e');
      await _fallbackToSequentialLoading(diagnosticoId);
    }
  }

  /// Fallback method for sequential loading when parallel fails
  Future<void> _fallbackToSequentialLoading(String diagnosticoId) async {
    try {
      await getDiagnosticoDetalhes(diagnosticoId);
      await _loadFavoriteStatus();
      await _checkPremiumStatus();
      _setSuccessState(LoadingStateType.loadingDiagnostic,
          message: 'Dados carregados (modo sequencial)');
    } catch (e) {
      _setErrorState(LoadingStateType.loadingDiagnostic, e,
          message: 'Erro no carregamento de fallback');
      debugPrint('Erro no carregamento de fallback: $e');
    }
  }

  /// Updates diagnostic data from DiagnosticData model
  void _updateDiagnosticoFromData(DiagnosticData data) {
    _updateDiagnosticoBasico(data);
    _updateDiagnosticoDosagem(data.diag);
    _updateDiagnosticoVazoes(data.diag);
    _updateDiagnosticoIntervalos(data.diag);
  }

  /// Maps operation names to LoadingStateType
  LoadingStateType _getLoadingStateForOperation(String operation) {
    switch (operation) {
      case 'diagnostic':
        return LoadingStateType.loadingDiagnostic;
      case 'favorite':
        return LoadingStateType.loadingFavorite;
      case 'premium':
        return LoadingStateType.loadingPremium;
      default:
        return LoadingStateType.loadingDiagnostic;
    }
  }

  /// Clears cache for current diagnostic
  void clearCurrentDiagnosticoCache() {
    if (diagnosticoId.isNotEmpty) {
      _performanceService.clearDiagnosticoCache(diagnosticoId);
    }
  }

  /// Clears all diagnostic cache
  void clearAllDiagnosticoCache() {
    _performanceService.clearAllCache();
  }

  /// Refreshes data with cache invalidation
  Future<void> refreshDiagnosticoData() async {
    if (diagnosticoId.isNotEmpty) {
      // Clear cache first
      clearCurrentDiagnosticoCache();
      // Reload with fresh data
      await loadDiagnosticoDataOptimized(diagnosticoId);
    }
  }

  /// Legacy method - kept for backward compatibility but now uses optimized loading
  Future<void> reloadData() async {
    await refreshDiagnosticoData();
  }
}
