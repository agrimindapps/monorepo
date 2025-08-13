// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../repository/pragas_repository.dart';
import '../../../router.dart';
import '../../home_pragas/models/navigation_args.dart';
import '../models/cultura_model.dart';
import '../models/lista_culturas_state.dart';
import '../utils/data_sanitizer.dart';
import '../utils/search_constants.dart';

/// Controller for managing list of agricultural cultures with centralized state management
///
/// This controller follows the centralized state management pattern from lista_defensivos_agrupados,
/// where all state mutations go through a single _updateState() method for predictable updates.
///
/// **State Management Architecture:**
/// - Uses Rx<ListaCulturasState> for reactive state management
/// - Single source of truth through _state reactive variable
/// - Immutable state updates via copyWith() pattern
/// - Computed getters for derived state values
/// - Unidirectional data flow: user actions → state mutations → UI updates
///
/// **State Lifecycle:**
/// 1. onInit() - Initialize dependencies and load initial data
/// 2. State mutations through _updateState() only
/// 3. Reactive UI updates automatically via GetX
/// 4. onClose() - Cleanup resources and timers
///
/// **Key Mutation Points:**
/// - carregarDados() - Loads initial cultura data
/// - _filtrarItems() - Filters culturas based on search
/// - toggleSort() - Changes sort direction
/// - handleCulturaTap() - Navigation with selected cultura
/// - clearSearch() - Resets search state
class ListaCulturasController extends GetxController {
  late PragasRepository _pragasRepository;
  final TextEditingController textController = TextEditingController();

  // Timer para debounce da busca
  Timer? _debounceTimer;
  static const Duration _debounceDelay = SearchConstants.debounceDelay;

  // Centralized reactive state management
  final Rx<ListaCulturasState> _state = const ListaCulturasState().obs;
  ListaCulturasState get state => _state.value;

  // Computed getters for derived state values
  bool get hasData => state.culturasList.isNotEmpty;
  bool get hasFilteredResults => state.culturasFiltered.isNotEmpty;
  bool get isSearchActive => state.searchText.isNotEmpty;
  bool get hasSelectedCultura => state.culturaSelecionadaId.isNotEmpty;
  int get totalCulturas => state.culturasList.length;
  int get filteredCount => state.culturasFiltered.length;

  // Legacy reactive variables for backward compatibility
  // These will be updated automatically when state changes
  String get culturaSelecionada => state.culturaSelecionada;
  String get culturaSelecionadaId => state.culturaSelecionadaId;
  List<Map<String, dynamic>> get pragasLista => state.pragasLista;

  @override
  void onInit() {
    super.onInit();
    _initRepository();
    _initializeController();
  }

  void _initRepository() {
    try {
      _pragasRepository = Get.find<PragasRepository>();
    } catch (e) {
      // Fallback for cases where bindings aren't properly set up
      _pragasRepository = PragasRepository();
      Get.put(_pragasRepository);
    }
  }

  void _initializeController() {
    textController.addListener(_onSearchTextChanged);
    carregarDados();
    _initializeTheme();
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(state.copyWith(isDark: value));
    });
  }

  /// Centralized state update method - single point of mutation
  void _updateState(ListaCulturasState newState) {
    _state.value = newState;
    // GetX reactive system automatically updates UI, no need for update() call
  }

  Future<void> carregarDados() async {
    _updateState(state.copyWith(isLoading: true));

    try {
      final dados = await _pragasRepository.getCulturas();
      final dadosSanitizados = DataSanitizer.sanitizeApiData(dados);

      _updateState(state.copyWith(
        culturasList: dadosSanitizados,
        culturasFiltered: dadosSanitizados,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPragasPorCultura(
      String culturaId) async {
    try {
      final pragas = await _pragasRepository.getPragasPorCultura(culturaId);
      return pragas;
    } catch (e) {
      return [];
    }
  }

  void _onSearchTextChanged() {
    // Cancela o timer anterior se existir
    _cancelDebounce();

    final searchText = textController.text;

    // Se o texto estiver vazio, filtra imediatamente
    if (searchText.isEmpty) {
      _updateState(state.copyWith(isSearching: false));
      _filtrarItems();
      return;
    }

    // Indica que uma busca está pendente
    _updateState(state.copyWith(
      searchText: searchText,
      isSearching: true,
    ));

    // Inicia novo timer de debounce
    _debounceTimer = Timer(_debounceDelay, () {
      _filtrarItems();
      _updateState(state.copyWith(isSearching: false));
    });
  }

  void _cancelDebounce() {
    if (_debounceTimer != null) {
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  void _filtrarItems() {
    final stopwatch = Stopwatch()..start();

    String searchText = textController.text;
    searchText = DataSanitizer.sanitizeSearchInput(searchText);

    List<CulturaModel> filtered;

    // Usa threshold mínimo configurável
    if (searchText.length >= SearchConstants.minimumSearchLength) {
      final searchLower = searchText.toLowerCase();

      // Otimização para listas grandes
      if (state.culturasList.length > SearchConstants.performanceThreshold) {
        // Para listas grandes, usa busca mais eficiente
        filtered = state.culturasList
            .where((cultura) {
              return cultura.cultura.toLowerCase().contains(searchLower) ||
                  cultura.grupo.toLowerCase().contains(searchLower);
            })
            .take(SearchConstants.maxSearchResults)
            .toList();
      } else {
        // Para listas menores, busca normal
        filtered = state.culturasList.where((cultura) {
          return cultura.cultura.toLowerCase().contains(searchLower) ||
              cultura.grupo.toLowerCase().contains(searchLower);
        }).toList();
      }
    } else {
      filtered = List.from(state.culturasList);
    }

    _updateState(state.copyWith(
      culturasFiltered: filtered,
      searchText: searchText,
    ));
    _ordenarLista();

    stopwatch.stop();
  }

  void toggleSort() {
    _updateState(state.copyWith(isAscending: !state.isAscending));
    _ordenarLista();
  }

  void _ordenarLista() {
    final listaOrdenada = List<CulturaModel>.from(state.culturasFiltered);
    listaOrdenada.sort((a, b) {
      String valueA = _getFieldValue(a, state.sortField);
      String valueB = _getFieldValue(b, state.sortField);

      if (state.isAscending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    });

    _updateState(state.copyWith(culturasFiltered: listaOrdenada));
  }

  String _getFieldValue(CulturaModel cultura, String field) {
    switch (field) {
      case 'cultura':
        return cultura.cultura;
      case 'grupo':
        return cultura.grupo;
      default:
        return cultura.cultura;
    }
  }

  Future<void> handleCulturaTap(CulturaModel cultura) async {
    try {
      // Create typed navigation arguments
      final navigationArgs = PragasPorCulturaArgs(
        culturaId: cultura.idReg,
        culturaNome: cultura.cultura,
        source: 'lista_culturas',
      );

      // Validate arguments before navigation
      NavigationHelper.validateNavigation(
          navigationArgs, AppRoutes.pragasCulturas);
      NavigationHelper.logNavigationAttempt(
          AppRoutes.pragasCulturas, navigationArgs);

      // Update state with selected cultura
      _updateState(state.copyWith(
        culturaSelecionada: cultura.cultura,
        culturaSelecionadaId: cultura.idReg,
      ));

      // Show loading dialog using GetX
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Load pragas data
      final pragas = await _pragasRepository.getPragasPorCultura(cultura.idReg);
      final pragasList = List<Map<String, dynamic>>.from(pragas);

      // Update state with loaded data
      _updateState(state.copyWith(
        pragasLista: pragasList,
      ));

      // Update navigation args with loaded data
      final navigationArgsWithData = PragasPorCulturaArgs(
        culturaId: cultura.idReg,
        culturaNome: cultura.cultura,
        pragasList: pragasList,
        source: 'lista_culturas',
      );

      // Close loading dialog and navigate using typed arguments
      Get.back();
      Get.toNamed(
        AppRoutes.pragasCulturas,
        arguments: navigationArgsWithData.toMap(),
      );
    } catch (error) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen == true) {
        Get.back();
      }


      // Show error using GetX
      Get.snackbar(
        'Erro de Navegação',
        'Não foi possível carregar as pragas para esta cultura: ${error.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
      );
    }
  }

  void clearSearch() {
    _cancelDebounce();
    textController.clear();
    _updateState(state.copyWith(isSearching: false));
  }

  /// Executa busca imediatamente sem aguardar debounce
  /// Útil para casos como pressionar Enter no campo de busca
  void executeSearchImmediately() {
    _cancelDebounce();
    _updateState(state.copyWith(isSearching: false));
    _filtrarItems();
  }

  @override
  void onClose() {
    _cancelDebounce(); // Cancela timer pendente
    textController.dispose();
    super.onClose();
  }
}
