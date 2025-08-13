// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../core/navigation/i_navigation_service.dart';
import '../../../services/mock_admob_service.dart';
import '../interfaces/i_diagnostic_filter_service.dart';
import '../interfaces/i_favorite_service.dart';
import '../interfaces/i_load_defensivo_use_case.dart';
import '../interfaces/i_tts_service.dart';
import '../managers/loading_state_manager.dart';
import '../models/defensivo_details_model.dart';
import '../utils/defensivo_formatter.dart';

/// Controller refatorado seguindo Single Responsibility Principle
/// Responsabilidades: APENAS gerenciamento de estado reativo da UI
class DetalhesDefensivosController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Injeção de dependências
  final ITtsService _ttsService;
  final IFavoriteService _favoriteService;
  final INavigationService _navigationService;
  final IDiagnosticFilterService _filterService;
  final ILoadDefensivoUseCase _loadDefensivoUseCase;
  final MockAdmobService _admobService;

  // Gerenciador de estados de loading
  late final LoadingStateManager _loadingManager;

  // Controladores UI
  late TabController tabController;
  final TextEditingController textController = TextEditingController();

  // Debounce para busca
  Timer? _searchDebounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  // Estados reativos da UI
  final RxBool isPremiumAd = false.obs;
  final RxBool isFavorite = false.obs;
  final RxDouble fontSize = 14.0.obs;
  final RxString searchCultura = ''.obs;

  // Dados do defensivo
  final Rx<DefensivoDetailsModel> defensivo = DefensivoDetailsModel.empty().obs;
  final RxList<dynamic> diagnosticosFiltered = <dynamic>[].obs;

  DetalhesDefensivosController({
    required ITtsService ttsService,
    required IFavoriteService favoriteService,
    required INavigationService navigationService,
    required IDiagnosticFilterService filterService,
    required ILoadDefensivoUseCase loadDefensivoUseCase,
    required MockAdmobService admobService,
  })  : _ttsService = ttsService,
        _favoriteService = favoriteService,
        _navigationService = navigationService,
        _filterService = filterService,
        _loadDefensivoUseCase = loadDefensivoUseCase,
        _admobService = admobService;

  String get defensivoId {
    final args = Get.arguments;
    if (args == null) {
      debugPrint(
          'Warning: No arguments provided for DetalhesDefensivosController');
      return '';
    }
    if (args is! String) {
      debugPrint(
          'Warning: Invalid argument type for defensivoId. Expected String, got ${args.runtimeType}');
      return '';
    }
    if (args.isEmpty) {
      debugPrint('Warning: Empty defensivoId argument provided');
      return '';
    }
    return args;
  }

  @override
  void onInit() {
    super.onInit();
    
    // Inicializa o manager em idle para evitar estados problemáticos
    _loadingManager = LoadingStateManager();
    _loadingManager.setIdle(LoadingStateManager.dataLoading);
    
    _setupControllers();
    
    // Move os listeners para após o build para evitar reações durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
      _loadInitialData();
    });
  }

  void _setupControllers() {
    tabController = TabController(length: 4, vsync: this);
  }

  void _setupListeners() {
    try {
      // Observar mudanças no status premium do anúncio de forma segura
      _admobService.isPremiumAd.listen((value) {
        // Agenda a atualização para o próximo frame se necessário
        if (isPremiumAd.value != value) {
          Future.microtask(() {
            isPremiumAd.value = value;
          });
        }
      });
    } catch (e) {
      debugPrint('Erro ao configurar listeners: $e');
    }
  }

  Future<void> _loadInitialData() async {
    await _loadingManager.executeOperation(
      LoadingStateManager.dataLoading,
      () async {
        if (defensivoId.isNotEmpty) {
          await loadDefensivoData();
          await loadFavoriteStatus();
        }
        isPremiumAd.value = _admobService.isPremiumAd.value;
      },
      loadingMessage: 'Carregando dados iniciais...',
      errorMessage: 'Erro ao carregar dados iniciais',
    );
  }

  // ==================== MÉTODOS PÚBLICOS ====================

  /// Carrega dados do defensivo
  Future<void> loadDefensivoData() async {
    if (defensivoId.isEmpty) return;

    await _loadingManager.executeOperation(
      LoadingStateManager.dataLoading,
      () async {
        final data = await _loadDefensivoUseCase.execute(defensivoId);
        _updateDefensivoData(data);
      },
      loadingMessage: 'Carregando defensivo...',
      errorMessage: 'Erro ao carregar defensivo',
    );
  }

  /// Carrega status de favorito
  Future<void> loadFavoriteStatus() async {
    if (!_hasValidDefensivoData()) return;

    try {
      final idReg = defensivo.value.caracteristicas['idReg']?.toString() ?? '';
      final favoriteStatus =
          await _favoriteService.isFavorite('favDefensivos', idReg);
      isFavorite.value = favoriteStatus;
    } catch (e) {
      // Log error silently
      isFavorite.value = false;
    }
  }

  /// Alterna status de favorito
  Future<void> toggleFavorite() async {
    if (!_hasValidDefensivoData()) return;

    try {
      final idReg = defensivo.value.caracteristicas['idReg']?.toString() ?? '';
      final newStatus =
          await _favoriteService.toggleFavorite('favDefensivos', idReg);
      isFavorite.value = newStatus;
      // Wrap update call to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['app_bar']); // Atualiza o app bar
      });
    } catch (e) {
      // Log error silently - no need for complex error handling for favorites
    }
  }

  /// Controla TTS
  void toggleTts(String text) {
    if (_loadingManager.isLoading(LoadingStateManager.ttsOperation)) {
      stopTts();
    } else {
      _startTts(text);
    }
  }

  void stopTts() {
    _ttsService.stop();
    _loadingManager.setIdle(LoadingStateManager.ttsOperation);
    // Wrap update call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['tts_button']);
    });
  }

  /// Define tamanho da fonte
  void setFontSize(double size) {
    fontSize.value = size.clamp(12.0, 24.0);
    // Wrap update call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['app_bar']); // Atualiza o app bar
    });
  }

  /// Filtra diagnósticos com debounce
  void filtraDiagnostico(String text) {
    _searchDebounceTimer?.cancel();

    if (text.isEmpty) {
      _loadingManager.setIdle(LoadingStateManager.searchOperation);
      _resetDiagnosticoFilter();
      return;
    }

    _loadingManager.startLoading(LoadingStateManager.searchOperation,
        message: 'Buscando...');

    _searchDebounceTimer = Timer(_debounceDelay, () {
      _performSearch(text);
    });
  }

  /// Atualiza filtro de cultura
  void updateSearchCultura(String cultura) {
    // Se for a mesma cultura, não faz nada
    if (searchCultura.value == cultura) return;

    searchCultura.value = cultura;

    // Limpa o texto de busca para evitar conflitos
    textController.clear();

    // Para a busca atual se estiver em andamento
    _searchDebounceTimer?.cancel();
    _loadingManager.setIdle(LoadingStateManager.searchOperation);

    // Se for "Todas" (string vazia), reseta o filtro, senão aplica o filtro
    if (cultura.isEmpty) {
      _resetDiagnosticoFilter();
    } else {
      _applyCurrentFilter(searchText: '');
      // Wrap update call to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['diagnostic_tab']);
      });
    }
  }

  /// Métodos de navegação
  void navigateToPests(Map<dynamic, dynamic> data) {
    _loadingManager.executeOperation(
      LoadingStateManager.navigationOperation,
      () async => _navigationService.navigateToPragaFromData(data),
      loadingMessage: 'Navegando...',
      errorMessage: 'Erro na navegação para pragas',
    );
  }

  void navigateToDiagnostic(Map<dynamic, dynamic> data) {
    // Debug: Log dos dados recebidos
    debugPrint('navigateToDiagnostic - Dados recebidos: $data');
    
    // Verifica se os dados contêm idReg válido
    final diagnosticId = data['idReg'];
    if (diagnosticId == null || diagnosticId.toString().trim().isEmpty) {
      debugPrint('Erro: idReg não encontrado ou vazio nos dados: $data');
      return; // Não tenta navegar se não há ID válido
    }
    
    _loadingManager.executeOperation(
      LoadingStateManager.navigationOperation,
      () async => _navigationService.navigateToDiagnosticoFromData(data),
      loadingMessage: 'Navegando...',
      errorMessage: 'Erro na navegação para diagnóstico',
    );
  }

  /// Obtém dados formatados
  String getDefensivoNome() {
    if (!_hasValidDefensivoData()) return '';
    return defensivo.value.caracteristicas['nomeComum'] ?? '';
  }

  String getDefensivoIngrediente() {
    if (!_hasValidDefensivoData()) return '';
    return defensivo.value.caracteristicas['ingredienteAtivo'] ?? '';
  }

  /// Formata texto removendo tags HTML
  String formatText(String text) {
    return DefensivoFormatter.formatText(text);
  }

  /// Obtém sugestões de busca
  List<String> getSearchSuggestions(String currentTerm) {
    return _filterService.getSearchSuggestions(currentTerm);
  }

  /// Limpa histórico de busca
  void clearSearchHistory() {
    _filterService.clearSearchHistory();
  }

  // ==================== MÉTODOS PRIVADOS ====================

  void _updateDefensivoData(DefensivoDetailsModel data) {
    defensivo.value = data;
    diagnosticosFiltered.value = List<dynamic>.from(data.diagnosticos);
  }

  void _startTts(String text) {
    if (text.trim().isEmpty) return;

    // Defer state changes to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadingManager.executeOperation(
        LoadingStateManager.ttsOperation,
        () async {
          final formattedText = formatText(text).trim();
          _ttsService.speak(formattedText);
          // Wrap update call to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            update(['tts_button']);
          });
        },
        loadingMessage: 'Iniciando narração...',
        errorMessage: 'Erro no TTS',
      ).then((_) {
        // Wrap update call to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update(['tts_button']);
        });
      });
    });
  }

  void _performSearch(String text) {
    _loadingManager.executeOperation(
      LoadingStateManager.searchOperation,
      () async {
        _filterService.addToSearchHistory(text.trim());
        _applyCurrentFilter(searchText: text);
        // Wrap update call to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update(['diagnostic_tab']); // Atualiza a tab de diagnósticos
        });
      },
      successMessage: 'Busca concluída',
      errorMessage: 'Erro na busca',
    );
  }

  void _applyCurrentFilter({String? searchText}) {
    final currentSearchText = searchText ?? textController.text;
    final currentCultura =
        searchCultura.value.isEmpty ? null : searchCultura.value;

    final filteredData = _filterService.filterDiagnosticos(
      diagnosticos: defensivo.value.diagnosticos,
      searchText: currentSearchText,
      selectedCultura: currentCultura,
    );

    // Atualiza o estado de forma segura
    diagnosticosFiltered.value = filteredData;
  }

  void _resetDiagnosticoFilter() {
    // Atualiza o estado de forma segura
    diagnosticosFiltered.value =
        List<dynamic>.from(defensivo.value.diagnosticos);
    // Wrap update call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['diagnostic_tab']); // Atualiza a tab de diagnósticos
    });
  }

  bool _hasValidDefensivoData() {
    return defensivo.value.caracteristicas.isNotEmpty;
  }

  // ==================== GETTERS PARA ESTADOS ====================

  /// Obtém estado de loading para dados
  bool get isDataLoading =>
      _loadingManager.isLoading(LoadingStateManager.dataLoading);

  /// Obtém estado do tema dark
  bool get isDark => ThemeManager().isDark.value;

  /// Obtém estado de TTS
  bool get isTtsSpeaking =>
      _loadingManager.isLoading(LoadingStateManager.ttsOperation);

  /// Obtém estado de busca
  bool get isSearching =>
      _loadingManager.isLoading(LoadingStateManager.searchOperation);

  /// Obtém estado de navegação
  bool get isNavigating =>
      _loadingManager.isLoading(LoadingStateManager.navigationOperation);

  /// Obtém estado geral de loading
  bool get isLoading => _loadingManager.hasAnyLoading;

  /// Verifica se há algum erro
  bool get hasError =>
      _loadingManager.hasError(LoadingStateManager.dataLoading);

  /// Obtém manager de loading (para uso em widgets)
  LoadingStateManager get loadingManager => _loadingManager;

  /// Método para retry após erro
  Future<void> retryLoad() async {
    await _loadInitialData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    tabController.dispose();
    textController.dispose();
    _loadingManager.clearAllStates();
    stopTts();
    super.onClose();
  }
}
