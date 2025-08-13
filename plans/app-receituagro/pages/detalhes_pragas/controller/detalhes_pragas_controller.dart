// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/tts_service.dart';
import '../../../../core/themes/manager.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../models/praga_unica_model.dart';
import '../../../widgets/diagnostic_application_dialog.dart';
import '../models/praga_details_model.dart';
import '../services/error_handler_service.dart';
import '../services/favorite_service.dart';
import '../services/praga_data_service.dart';

/// Controller refatorado seguindo Single Responsibility Principle
/// Responsável apenas pela orquestração de serviços e gerenciamento de estado reativo
class DetalhesPragasController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // --- Services ---
  final PragaDataService _dataService;
  final FavoriteService _favoriteService;
  final TtsService _ttsService;
  final NavigationService _navigationService;
  final ErrorHandlerService _errorHandler;

  DetalhesPragasController({
    required PragaDataService dataService,
    required FavoriteService favoriteService,
    required TtsService ttsService,
    required NavigationService navigationService,
    required ErrorHandlerService errorHandler,
  })  : _dataService = dataService,
        _favoriteService = favoriteService,
        _ttsService = ttsService,
        _navigationService = navigationService,
        _errorHandler = errorHandler;

  // --- UI Controllers ---
  late TabController tabController;

  // --- Reactive State ---
  final RxBool isLoading = true.obs;
  final RxDouble fontSize = 16.0.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool _isTtsSpeaking = false.obs;
  final RxString _searchCultura = ''.obs;
  final RxList<dynamic> _originalDiagnosticos = <dynamic>[].obs;
  final RxList<dynamic> _filteredDiagnosticos = <dynamic>[].obs;
  final Rx<PragaUnica?> _pragaUnica = Rx<PragaUnica?>(null);

  // --- Getters ---
  PragaUnica? get pragaUnica => _pragaUnica.value;
  bool get isPragaLoaded => _pragaUnica.value != null;
  bool get isDark => ThemeManager().isDark.value;
  List<dynamic> get diagnosticos => _originalDiagnosticos;
  List<dynamic> get diagnosticosFiltered => _filteredDiagnosticos;
  String get searchCultura => _searchCultura.value;
  bool get isFavorite => _favoriteService.isFavorite;
  bool get isTtsSpeaking => _isTtsSpeaking.value;
  PragaDetailsModel? get pragaDetails => _dataService.createPragaDetailsModel(
        _pragaUnica.value,
        diagnosticos,
        isFavorite,
        fontSize.value,
      );

  // --- Lifecycle
  @override
  void onInit() {
    super.onInit();

    // Inicializar TabController
    tabController = TabController(length: 3, vsync: this);
    
    // Adicionar listener para atualizar FAB quando a aba muda
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
      update(['floating_action_button']);
    });

    // Removidos prints de debug para produção
    final pragaId = _extractPragaIdFromArguments(Get.arguments);
    if (pragaId != null && pragaId.isNotEmpty) {
      loadPragaData(pragaId);
    } else {
      // Mantido log de erro via serviço
      debugPrint('DetalhesPragasController - ERRO: pragaId é nulo ou vazio');
    }
  }

  @override
  void onClose() {
    _stopTts();
    tabController.dispose();
    _favoriteService.dispose();
    super.onClose();
  }

  // --- Public Methods ---

  /// Carrega os dados da praga orquestrando múltiplos services com tratamento robusto de erros
  Future<void> loadPragaData(String pragaId) async {
    isLoading.value = true;
    update(['main_body', 'app_bar']);
    try {
      await _errorHandler.withRetry(
        () async {
          final praga = await _errorHandler.handleWithFallback(
            () => _dataService.loadPragaById(pragaId),
            () => null,
            operationName: 'loadPragaById',
            showUserMessage: false,
          );
          if (praga != null) {
            _pragaUnica.value = praga;
            update(['praga_data', 'app_bar']);
            await _loadSecondaryDataWithRecovery(pragaId);
            _showDataLoadedMessage();
          } else {
            throw _errorHandler.createException(
              'Não foi possível carregar dados da praga nem do cache',
              null,
              type: ErrorType.data,
            );
          }
        },
        maxAttempts: 3,
        operationName: 'loadPragaData([0m$pragaId)',
      );
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Falha completa no carregamento da praga após todas as tentativas',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      _errorHandler.showUserErrorWithRetry(
        e,
        () => loadPragaData(pragaId),
        customMessage: 'Não foi possível carregar os dados da praga',
      );
    } finally {
      isLoading.value = false;
      update(['main_body', 'app_bar']);
    }
  }

  /// Carrega dados secundários com recuperação robusta de erros
  Future<void> _loadSecondaryDataWithRecovery(String pragaId) async {
    await Future.wait([
      _loadFavoriteStatusWithRecovery(pragaId),
      _loadDiagnosticosWithRecovery(pragaId),
    ], eagerError: false);
  }

  /// Carrega status de favoritos com tratamento robusto de erros
  Future<void> _loadFavoriteStatusWithRecovery(String pragaId) async {
    await _errorHandler.handleWithFallback(
      () => _favoriteService.loadFavoriteStatus(pragaId),
      () => null, // Fallback para não quebrar se cache não estiver implementado
      operationName: 'loadFavoriteStatus',
      showUserMessage: false,
    );
    update(['app_bar']);
  }

  /// Carrega diagnósticos com tratamento robusto de erros
  Future<void> _loadDiagnosticosWithRecovery(String pragaId) async {
    final diagnosticos = await _errorHandler.handleWithFallback(
      () => _dataService.loadDiagnosticos(pragaId),
      () =>
          <dynamic>[], // Fallback para lista vazia se cache não estiver implementado
      operationName: 'loadDiagnosticos',
      showUserMessage: false,
    );

    if (diagnosticos != null) {
      _setOriginalDiagnosticos(diagnosticos);
    }
  }

  /// Alterna favorito via service com tratamento de erros
  Future<void> toggleFavorite() async {
    if (_pragaUnica.value == null) return;

    await _errorHandler.handleWithFallback(
      () => _favoriteService.toggleFavorite(_pragaUnica.value!.idReg),
      () => null,
      operationName: 'toggleFavorite',
      showUserMessage: true,
    );
    update(['app_bar']);
  }

  /// Define tamanho da fonte
  void setFontSize(double size) {
    fontSize.value = size.clamp(12.0, 24.0);
    update(['app_bar']);
  }

  /// Gerencia ação do TTS (play/pause)
  void handleTtsAction(String text) {
    if (_isTtsSpeaking.value) {
      _stopTts();
    } else {
      _speakText(text);
    }
  }

  /// Inicia a leitura do texto
  void _speakText(String text) {
    if (text.trim().isEmpty) return;

    _ttsService.speak(text);
    _isTtsSpeaking.value = true;
  }

  /// Para a leitura do texto
  void _stopTts() {
    _ttsService.stop();
    _isTtsSpeaking.value = false;
  }

  /// Filtra diagnósticos por texto
  void filterDiagnostico(String searchText) {
    _filterByText(searchText);
  }

  /// Filtra diagnósticos por cultura
  void filterByCultura(String cultura) {
    _filterByCultura(cultura);
  }

  // --- Private Filter Methods ---

  /// Define a lista original de diagnósticos
  void _setOriginalDiagnosticos(List<dynamic> diagnosticos) {
    _originalDiagnosticos.value = List.from(diagnosticos);
    _filteredDiagnosticos.value = List.from(diagnosticos);
  }

  /// Filtra diagnósticos por texto de busca
  void _filterByText(String searchText) {
    if (searchText.isEmpty) {
      _filteredDiagnosticos.value = List.from(_originalDiagnosticos);
    } else {
      _filteredDiagnosticos.value = _originalDiagnosticos.where((diagnostico) {
        final cultura = diagnostico['cultura']?.toString().toLowerCase() ?? '';
        return cultura.contains(searchText.toLowerCase());
      }).toList();
    }
  }

  /// Filtra diagnósticos por cultura específica
  void _filterByCultura(String cultura) {
    _searchCultura.value = cultura;

    if (cultura.isEmpty) {
      _filteredDiagnosticos.value = List.from(_originalDiagnosticos);
    } else {
      _filteredDiagnosticos.value = _originalDiagnosticos.where((diagnostico) {
        return diagnostico['cultura'] == cultura;
      }).toList();
    }
  }

  /// Navega para defensivo via service
  void navigateToDefensivo(String defensivoId) {
    _navigationService.navigateToDefensivoDetails(defensivoId);
  }

  /// Mostra diálogo com informações de aplicação do diagnóstico
  void showDiagnosticDialog(Map<dynamic, dynamic> data, BuildContext context) {
    DiagnosticApplicationDialog.show(
      context: context,
      data: data,
      showLimiteMaximo: true,
      actions: [
        DialogAction(
          label: 'Defensivos',
          onPressed: () {
            Navigator.of(context).pop();
            navigateToDefensivo(
                data['fkIdDefensivo'] ?? data['idDefensivo'] ?? '');
          },
        ),
        DialogAction(
          label: 'Diagnóstico',
          isElevated: true,
          onPressed: () {
            Navigator.of(context).pop();

            final diagnosticoId = data['idReg'] ??
                data['id'] ??
                data['diagnosticoId'] ??
                data['fkIdDiagnostico'] ??
                '';

            _errorHandler.log(
              LogLevel.debug,
              'Tentando navegar para diagnóstico',
              metadata: {
                'diagnosticoId': diagnosticoId,
                'dataKeys': data.keys.toList(),
                'fullData': data.toString(),
              },
            );

            if (diagnosticoId.isNotEmpty) {
              navigateToDiagnostico(diagnosticoId);
            } else {
              _errorHandler.log(LogLevel.warning,
                  'ID do diagnóstico não encontrado nos dados');
            }
          },
        ),
      ],
    );
  }

  /// Navega para diagnóstico via service
  void navigateToDiagnostico(String diagnosticoId) {
    _navigationService.navigateToDiagnosticoDetails(diagnosticoId);
  }

  // --- Private Methods ---

  /// Extrai o ID da praga dos argumentos de navegação
  String? _extractPragaIdFromArguments(dynamic arguments) {
    if (arguments == null) return null;

    try {
      // Se for uma String direta
      if (arguments is String) {
        return arguments.isNotEmpty ? arguments : null;
      }

      // Se for um Map (como {'idReg': 'id_da_praga'} ou {'pragaId': 'id_da_praga'})
      if (arguments is Map<String, dynamic>) {
        final idReg = arguments['idReg'] ?? arguments['pragaId'];
        if (idReg != null) {
          return idReg.toString().isNotEmpty ? idReg.toString() : null;
        }
      }

      // Se for outro tipo de Map genérico
      if (arguments is Map) {
        final idReg = arguments['idReg'] ?? arguments['pragaId'];
        if (idReg != null) {
          return idReg.toString().isNotEmpty ? idReg.toString() : null;
        }
      }

      // Se for um IdentityMap ou qualquer outro tipo, tenta extrair como string
      final argumentsString = arguments.toString();
      if (argumentsString.isNotEmpty &&
          argumentsString != 'null' &&
          !argumentsString.startsWith('Instance of')) {
        return argumentsString;
      }

      return null;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao extrair ID da praga dos argumentos',
        error: e,
        stackTrace: stackTrace,
        metadata: {
          'argumentsType': arguments.runtimeType.toString(),
          'argumentsValue': arguments.toString(),
        },
      );
      return null;
    }
  }

  /// Exibe mensagem de dados carregados
  void _showDataLoadedMessage() {
    // Mensagem sutil de sucesso, apenas em debug
  }
}
