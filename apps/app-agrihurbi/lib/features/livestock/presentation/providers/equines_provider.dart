import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/equine_entity.dart';
import '../../domain/usecases/get_equines.dart';
import 'livestock_di_providers.dart';

part 'equines_provider.g.dart';

/// State class for Equines
class EquinesState {
  final List<EquineEntity> equines;
  final EquineEntity? selectedEquine;
  final bool isLoading;
  final bool isLoadingDetail;
  final String? errorMessage;
  final String searchQuery;

  const EquinesState({
    this.equines = const [],
    this.selectedEquine,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  EquinesState copyWith({
    List<EquineEntity>? equines,
    EquineEntity? selectedEquine,
    bool? isLoading,
    bool? isLoadingDetail,
    String? errorMessage,
    String? searchQuery,
    bool clearSelectedEquine = false,
    bool clearError = false,
  }) {
    return EquinesState(
      equines: equines ?? this.equines,
      selectedEquine: clearSelectedEquine ? null : (selectedEquine ?? this.selectedEquine),
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Equinos ativos (não deletados)
  List<EquineEntity> get activeEquines =>
      equines.where((equine) => equine.isActive).toList();

  /// Equinos filtrados por busca
  List<EquineEntity> get filteredEquines {
    var filtered = activeEquines;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (equine) =>
                equine.commonName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                equine.registrationId.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                equine.originCountry.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    return filtered;
  }

  /// Estatísticas dos equinos
  int get totalEquines => equines.length;
  int get activeEquinesCount => activeEquines.length;
  int get filteredEquinesCount => filteredEquines.length;

  /// Países de origem únicos para filtros
  List<String> get uniqueOriginCountries {
    final countries =
        activeEquines.map((equine) => equine.originCountry).toSet();
    return countries.toList()..sort();
  }
}

/// Equines Notifier using Riverpod code generation
@riverpod
class EquinesNotifier extends _$EquinesNotifier {
  GetAllEquinesUseCase get _getAllEquines => ref.read(getAllEquinesUseCaseProvider);
  GetEquinesUseCase get _getEquines => ref.read(getEquinesUseCaseProvider);
  GetEquineByIdUseCase get _getEquineById => ref.read(getEquineByIdUseCaseProvider);

  @override
  EquinesState build() {
    return const EquinesState();
  }

  // Convenience getters for backward compatibility
  List<EquineEntity> get equines => state.equines;
  EquineEntity? get selectedEquine => state.selectedEquine;
  bool get isLoading => state.isLoading;
  bool get isLoadingDetail => state.isLoadingDetail;
  String? get errorMessage => state.errorMessage;
  String get searchQuery => state.searchQuery;
  List<EquineEntity> get activeEquines => state.activeEquines;
  List<EquineEntity> get filteredEquines => state.filteredEquines;
  int get totalEquines => state.totalEquines;
  int get activeEquinesCount => state.activeEquinesCount;
  int get filteredEquinesCount => state.filteredEquinesCount;
  List<String> get uniqueOriginCountries => state.uniqueOriginCountries;

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllEquines();

    result.fold(
      (Failure failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint(
          'EquinesNotifier: Erro ao carregar equinos - ${failure.message}',
        );
      },
      (List<EquineEntity> equines) {
        state = state.copyWith(
          equines: equines,
          isLoading: false,
        );
        debugPrint(
          'EquinesNotifier: Equinos carregados - ${equines.length} itens',
        );
      },
    );
  }

  /// Carrega equinos com filtros
  Future<void> loadEquinesWithFilters(dynamic searchParams) async {
    state = state.copyWith(isLoading: true, clearError: true);

    const params = GetEquinesParams(searchParams: null);
    final result = await _getEquines(params);

    result.fold(
      (Failure failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint(
          'EquinesNotifier: Erro ao carregar equinos filtrados - ${failure.message}',
        );
      },
      (List<EquineEntity> equines) {
        state = state.copyWith(
          equines: equines,
          isLoading: false,
        );
        debugPrint(
          'EquinesNotifier: Equinos filtrados carregados - ${equines.length} itens',
        );
      },
    );
  }

  /// Carrega equino por ID
  Future<bool> loadEquineById(String equineId) async {
    state = state.copyWith(isLoadingDetail: true, clearError: true);

    final result = await _getEquineById(equineId);

    bool success = false;
    result.fold(
      (Failure failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingDetail: false,
        );
        debugPrint(
          'EquinesNotifier: Erro ao carregar equino por ID - ${failure.message}',
        );
      },
      (EquineEntity equine) {
        final updatedEquines = List<EquineEntity>.from(state.equines);
        final index = updatedEquines.indexWhere((e) => e.id == equine.id);
        if (index != -1) {
          updatedEquines[index] = equine;
        } else {
          updatedEquines.add(equine);
        }

        state = state.copyWith(
          equines: updatedEquines,
          selectedEquine: equine,
          isLoadingDetail: false,
        );
        success = true;
        debugPrint('EquinesNotifier: Equino carregado por ID - ${equine.id}');
      },
    );

    return success;
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    state = state.copyWith(
      selectedEquine: equine,
      clearSelectedEquine: equine == null,
    );
    debugPrint(
      'EquinesNotifier: Equino selecionado - ${equine?.id ?? 'nenhum'}',
    );
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    debugPrint('EquinesNotifier: Query de busca atualizada - "$query"');
  }

  /// Limpa busca
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    debugPrint('EquinesNotifier: Busca limpa');
  }

  /// Busca equino por ID na lista local
  EquineEntity? getEquineById(String id) {
    try {
      return state.equines.firstWhere((equine) => equine.id == id);
    } catch (e) {
      debugPrint('EquinesNotifier: Equino não encontrado na lista local - $id');
      return null;
    }
  }

  /// Busca equinos por país de origem
  List<EquineEntity> getEquinesByOriginCountry(String originCountry) {
    return state.activeEquines
        .where(
          (equine) =>
              equine.originCountry.toLowerCase() == originCountry.toLowerCase(),
        )
        .toList();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await loadEquines();
  }

  /// Limpa seleção
  void clearSelection() {
    state = state.copyWith(clearSelectedEquine: true);
  }

  /// Verifica se equino está selecionado
  bool isEquineSelected(String equineId) {
    return state.selectedEquine?.id == equineId;
  }

  /// Adiciona ou atualiza equino na lista
  void upsertEquine(EquineEntity equine) {
    final updatedEquines = List<EquineEntity>.from(state.equines);
    final index = updatedEquines.indexWhere((e) => e.id == equine.id);
    if (index != -1) {
      updatedEquines[index] = equine;
    } else {
      updatedEquines.add(equine);
    }
    state = state.copyWith(equines: updatedEquines);
    debugPrint('EquinesNotifier: Equino upsert - ${equine.id}');
  }

  /// Remove equino da lista local
  void removeEquine(String equineId) {
    final updatedEquines = List<EquineEntity>.from(state.equines);
    updatedEquines.removeWhere((equine) => equine.id == equineId);

    state = state.copyWith(
      equines: updatedEquines,
      selectedEquine: state.selectedEquine?.id == equineId ? null : state.selectedEquine,
      clearSelectedEquine: state.selectedEquine?.id == equineId,
    );
    debugPrint('EquinesNotifier: Equino removido da lista local - $equineId');
  }
}
