// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/extensions/theme_extensions.dart';
import '../../../database/espaco_model.dart';
import '../../../repository/espaco_repository.dart';
import '../models/espacos_model.dart';
import '../services/espacos_service.dart';

/// Reactive controller using immutable state pattern
/// Single source of truth with EspacosPageModel
class EspacosController extends GetxController {
  // Single reactive state - immutable pattern
  final _state = const EspacosPageModel().obs;

  // External dependencies
  final _espacosService = EspacosService();
  final searchController = TextEditingController();

  // Getters for reactive state access
  EspacosPageModel get state => _state.value;
  List<EspacoModel> get espacos => state.espacos;
  List<EspacoModel> get displayedEspacos => state.displayedEspacos;
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  String get errorMessage => state.errorMessage;
  bool get isCreating => state.isCreating;
  bool get isUpdating => state.isUpdating;
  bool get isDeleting => state.isDeleting;
  bool get hasOperationInProgress => state.hasOperationInProgress;
  String get searchText => state.searchText;
  bool get isSearching => state.isSearching;
  bool get hasSearchResults => state.hasSearchResults;
  String? get editingEspacoId => state.editingEspacoId;
  bool get isEditing => state.isEditing;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ========== PRIVATE INITIALIZATION ==========

  void _initializeController() {
    // Setup search listener
    searchController.addListener(_onSearchChanged);

    // Load initial data
    carregarEspacos();
  }

  void _onSearchChanged() {
    final searchText = searchController.text;
    _updateSearchState(searchText);
  }

  // ========== STATE MUTATION METHODS ==========

  /// Updates state immutably
  void _updateState(EspacosPageModel Function(EspacosPageModel) updater) {
    _state.value = updater(_state.value);
  }

  /// Sets loading state
  void _setLoadingState(bool isLoading) {
    _updateState((state) => state.copyWith(isLoading: isLoading));
  }

  /// Sets error state
  void _setErrorState(String? errorMessage) {
    _updateState((state) => state.copyWith(
          hasError: errorMessage != null,
          errorMessage: errorMessage ?? '',
        ));
  }

  /// Sets operation states
  void _setOperationState({
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? editingEspacoId,
  }) {
    _updateState((state) => state.copyWith(
          isCreating: isCreating,
          isUpdating: isUpdating,
          isDeleting: isDeleting,
          editingEspacoId: editingEspacoId,
        ));
  }

  /// Updates espacos list and reapplies search filter
  void _updateEspacosList(List<EspacoModel> espacos) {
    _updateState((state) => state.copyWith(espacos: espacos));
    _applyCurrentSearch();
  }

  /// Updates search state
  void _updateSearchState(String searchText) {
    final filteredEspacos = _espacosService.filterEspacos(espacos, searchText);
    final searchState = EspacosSearchState(
      searchText: searchText,
      filteredEspacos: filteredEspacos,
      isSearchActive: searchText.isNotEmpty,
    );

    _updateState((state) => state.copyWith(searchState: searchState));
  }

  /// Reapplies current search filter
  void _applyCurrentSearch() {
    _updateSearchState(searchController.text);
  }

  // ========== PUBLIC API METHODS ==========

  /// Loads all espacos from repository
  Future<void> carregarEspacos() async {
    try {
      _setLoadingState(true);
      _setErrorState(null);

      final espacoRepo = EspacoRepository.instance;
      await espacoRepo.initialize();
      final lista = await espacoRepo.findAll();

      _updateEspacosList(lista);
    } catch (e) {
      _setErrorState('espacos.erro_carregar'.trParams({'erro': e.toString()}));
      _showError('espacos.erro'.tr,
          'espacos.erro_carregar'.trParams({'erro': e.toString()}));
    } finally {
      _setLoadingState(false);
    }
  }

  /// Adds new espaco with validation
  Future<void> adicionarEspaco(String nome, String? descricao) async {
    try {
      _setOperationState(isCreating: true);
      _setErrorState(null);

      // Centralized async validation
      final validation = await _espacosService.validateEspacoAsync(nome);

      if (!validation.isValid) {
        _showWarning('espacos.atencao'.tr,
            validation.getError('nome') ?? 'espacos.dados_invalidos'.tr);
        return;
      }

      final espacoRepo = EspacoRepository.instance;
      final novoEspaco = _espacosService.createEspaco(nome);
      final espacoComDescricao = novoEspaco.copyWith(
        descricao: descricao?.trim(),
      );

      await espacoRepo.salvar(espacoComDescricao);
      await carregarEspacos();

      _showSuccess(
          'espacos.sucesso'.tr,
          'espacos.criado_sucesso'
              .trParams({'nome': _espacosService.formatEspacoName(nome)}));
    } catch (e) {
      _setErrorState('espacos.erro_criar'.trParams({'erro': e.toString()}));
      _showError('espacos.erro'.tr,
          'espacos.erro_criar'.trParams({'erro': e.toString()}));
    } finally {
      _setOperationState(isCreating: false);
    }
  }

  /// Edits existing espaco with validation
  Future<void> editarEspaco(
      EspacoModel espaco, String novoNome, String? novaDescricao) async {
    try {
      _setOperationState(isUpdating: true, editingEspacoId: espaco.id);
      _setErrorState(null);

      // Centralized async validation (excluding current espaco)
      final validation = await _espacosService.validateEspacoAsync(
        novoNome,
        excludeId: espaco.id,
      );

      if (!validation.isValid) {
        _showWarning('espacos.atencao'.tr,
            validation.getError('nome') ?? 'espacos.dados_invalidos'.tr);
        return;
      }

      final espacoRepo = EspacoRepository.instance;
      final espacoAtualizado = espaco.copyWith(
        nome: _espacosService.formatEspacoName(novoNome),
        descricao: novaDescricao?.trim(),
      );

      await espacoRepo.update(espacoAtualizado.id, espacoAtualizado);
      await carregarEspacos();

      _showSuccess('espacos.sucesso'.tr, 'espacos.atualizado_sucesso'.tr);
    } catch (e) {
      _setErrorState('espacos.erro_atualizar'.trParams({'erro': e.toString()}));
      _showError('espacos.erro'.tr,
          'espacos.erro_atualizar'.trParams({'erro': e.toString()}));
    } finally {
      _setOperationState(isUpdating: false, editingEspacoId: null);
    }
  }

  /// Removes espaco with business logic validation
  Future<void> removerEspaco(EspacoModel espaco) async {
    try {
      _setOperationState(isDeleting: true);
      _setErrorState(null);

      // Business logic validation via service
      final canRemove = await _espacosService.canRemoveEspaco(espaco);

      if (!canRemove) {
        final quantidadePlantas =
            await _espacosService.countPlantasInEspaco(espaco.id);
        _showWarning(
            'espacos.atencao'.tr,
            'espacos.plantas_no_espaco'
                .trParams({'quantidade': quantidadePlantas.toString()}));
        return;
      }

      final espacoRepo = EspacoRepository.instance;
      await espacoRepo.delete(espaco.id);
      await carregarEspacos();

      _showSuccess('espacos.sucesso'.tr,
          'espacos.removido_sucesso'.trParams({'nome': espaco.nome}));
    } catch (e) {
      _setErrorState('espacos.erro_remover'.trParams({'erro': e.toString()}));
      _showError('espacos.erro'.tr,
          'espacos.erro_remover'.trParams({'erro': e.toString()}));
    } finally {
      _setOperationState(isDeleting: false);
    }
  }

  /// Clears search and resets filter
  void limparBusca() {
    searchController.clear();
    _updateSearchState('');
  }

  /// Refreshes espacos list (pull to refresh)
  @override
  Future<void> refresh() async {
    await carregarEspacos();
  }

  // ========== COMPUTED PROPERTIES ==========

  /// Gets espaco by ID from current state
  EspacoModel? getEspacoById(String id) {
    return state.findEspacoById(id);
  }

  /// Checks if espaco name exists (for validation)
  bool hasEspacoWithName(String nome, {String? excludeId}) {
    return state.hasEspacoWithName(nome, excludeId: excludeId);
  }

  /// Gets total espacos count
  int get totalEspacos => state.totalEspacos;

  /// Gets displayed espacos count (considering search)
  int get displayedEspacosCount => displayedEspacos.length;

  /// Checks if there are no espacos
  bool get isEmpty => state.isEmpty;

  /// Checks if there are espacos
  bool get isNotEmpty => state.isNotEmpty;

  // ========== UI FEEDBACK METHODS ==========

  void _showSuccess(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.success(context, title, message);
    }
  }

  void _showError(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.error(context, title, message);
    }
  }

  void _showWarning(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.warning(context, title, message);
    }
  }

  // ========== DIALOG METHODS (TO BE EXTRACTED) ==========
  // TODO: These should be extracted to separate dialog widgets
  // as per REFACTOR #5 in the issues list

  void showNovoEspacoDialog() {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('espacos.novo_espaco'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'espacos.nome_obrigatorio'.tr,
                hintText: 'espacos.nome_hint'.tr,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva o espaço...',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('espacos.cancelar'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.trim().isNotEmpty) {
                Get.back();
                adicionarEspaco(nomeController.text, descricaoController.text);
              } else {
                _showWarning('espacos.atencao'.tr,
                    'espacos.nome_obrigatorio_validacao'.tr);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Get.context?.plantasPrimary ?? const Color(0xFF20B2AA),
              foregroundColor:
                  Get.context?.plantasCores['textoClaro'] ?? Colors.white,
            ),
            child: Text('espacos.criar'.tr),
          ),
        ],
      ),
    );
  }

  void showEditarEspacoDialog(EspacoModel espaco) {
    final nomeController = TextEditingController(text: espaco.nome);
    final descricaoController =
        TextEditingController(text: espaco.descricao ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('espacos.editar_espaco'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'espacos.nome_obrigatorio'.tr,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'espacos.descricao'.tr,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('espacos.cancelar'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.trim().isNotEmpty) {
                Get.back();
                editarEspaco(
                    espaco, nomeController.text, descricaoController.text);
              } else {
                _showWarning('espacos.atencao'.tr,
                    'espacos.nome_obrigatorio_validacao'.tr);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Get.context?.plantasPrimary ?? const Color(0xFF20B2AA),
              foregroundColor:
                  Get.context?.plantasCores['textoClaro'] ?? Colors.white,
            ),
            child: Text('espacos.salvar'.tr),
          ),
        ],
      ),
    );
  }

  void showConfirmarRemocaoDialog(EspacoModel espaco) {
    Get.dialog(
      AlertDialog(
        title: Text('espacos.confirmar_remocao'.tr),
        content:
            Text('espacos.mensagem_remocao'.trParams({'nome': espaco.nome})),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('espacos.cancelar'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              removerEspaco(espaco);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.context?.plantasError ?? Colors.red,
              foregroundColor:
                  Get.context?.plantasCores['textoClaro'] ?? Colors.white,
            ),
            child: Text('espacos.remover'.tr),
          ),
        ],
      ),
    );
  }
}
