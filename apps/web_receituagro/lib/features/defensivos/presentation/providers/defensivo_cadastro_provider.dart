import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/entities/defensivo.dart';
import '../../domain/entities/defensivo_info.dart';
import '../../domain/entities/diagnostico.dart';

part 'defensivo_cadastro_provider.g.dart';

/// State for the defensivo cadastro form (3 tabs)
class DefensivoCadastroState {
  final Defensivo? defensivo;
  final List<Diagnostico> diagnosticos;
  final DefensivoInfo? defensivoInfo;
  final int currentTab; // 0=Informações, 1=Diagnóstico, 2=Aplicação
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved; // Indicates if data was successfully saved

  const DefensivoCadastroState({
    this.defensivo,
    this.diagnosticos = const [],
    this.defensivoInfo,
    this.currentTab = 0,
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  DefensivoCadastroState copyWith({
    Defensivo? defensivo,
    List<Diagnostico>? diagnosticos,
    DefensivoInfo? defensivoInfo,
    int? currentTab,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
  }) {
    return DefensivoCadastroState(
      defensivo: defensivo ?? this.defensivo,
      diagnosticos: diagnosticos ?? this.diagnosticos,
      defensivoInfo: defensivoInfo ?? this.defensivoInfo,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Provider for managing the defensivo cadastro form state
@riverpod
class DefensivoCadastro extends _$DefensivoCadastro {
  @override
  DefensivoCadastroState build() {
    return const DefensivoCadastroState();
  }

  /// Load existing defensivo data for editing
  Future<void> loadDefensivo(String defensivoId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load diagnosticos
      final diagnosticosUseCase = ref.read(
        getDiagnosticosByDefensivoIdUseCaseProvider,
      );
      final diagnosticosResult = await diagnosticosUseCase(defensivoId);

      // Load defensivo info
      final infoUseCase = ref.read(
        getDefensivoInfoByDefensivoIdUseCaseProvider,
      );
      final infoResult = await infoUseCase(defensivoId);

      diagnosticosResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Erro ao carregar diagnósticos: ${failure.message}',
          );
        },
        (diagnosticos) {
          infoResult.fold(
            (failure) {
              state = state.copyWith(
                isLoading: false,
                errorMessage: 'Erro ao carregar informações: ${failure.message}',
              );
            },
            (info) {
              state = state.copyWith(
                diagnosticos: diagnosticos,
                defensivoInfo: info,
                isLoading: false,
              );
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Update defensivo data (Tab 1)
  void updateDefensivo(Defensivo defensivo) {
    state = state.copyWith(defensivo: defensivo);
  }

  /// Add a new diagnostico entry (Tab 2)
  void addDiagnostico(Diagnostico diagnostico) {
    state = state.copyWith(
      diagnosticos: [...state.diagnosticos, diagnostico],
    );
  }

  /// Update existing diagnostico entry (Tab 2)
  void updateDiagnostico(int index, Diagnostico diagnostico) {
    final updatedList = [...state.diagnosticos];
    updatedList[index] = diagnostico;
    state = state.copyWith(diagnosticos: updatedList);
  }

  /// Remove diagnostico entry (Tab 2)
  void removeDiagnostico(int index) {
    final updatedList = [...state.diagnosticos];
    updatedList.removeAt(index);
    state = state.copyWith(diagnosticos: updatedList);
  }

  /// Update defensivo info (Tab 3)
  void updateDefensivoInfo(DefensivoInfo info) {
    state = state.copyWith(defensivoInfo: info);
  }

  /// Change current tab
  void setCurrentTab(int tab) {
    state = state.copyWith(currentTab: tab);
  }

  /// Save Tab 1 (Defensivo - Informações)
  Future<bool> saveTab1() async {
    if (state.defensivo == null) {
      state = state.copyWith(
        errorMessage: 'Dados do defensivo não foram preenchidos',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final isUpdate = state.defensivo!.id.isNotEmpty;

      final result = isUpdate
          ? await ref.read(updateDefensivoUseCaseProvider).call(state.defensivo!)
          : await ref.read(createDefensivoUseCaseProvider).call(state.defensivo!);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (savedDefensivo) {
          state = state.copyWith(
            defensivo: savedDefensivo,
            isLoading: false,
            isSaved: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  /// Save Tab 2 (Diagnosticos)
  Future<bool> saveTab2() async {
    if (state.defensivo == null || state.defensivo!.id.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Salve as informações básicas primeiro (Tab 1)',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final createUseCase = ref.read(createDiagnosticoUseCaseProvider);

      // Save each diagnostico
      for (final diagnostico in state.diagnosticos) {
        final result = await createUseCase(
          diagnostico.copyWith(defensivoId: state.defensivo!.id),
        );

        if (result.isLeft()) {
          result.fold(
            (failure) {
              state = state.copyWith(
                isLoading: false,
                errorMessage: 'Erro ao salvar diagnóstico: ${failure.message}',
              );
            },
            (_) {},
          );
          return false;
        }
      }

      state = state.copyWith(
        isLoading: false,
        isSaved: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  /// Save Tab 3 (DefensivoInfo - Aplicação)
  Future<bool> saveTab3() async {
    if (state.defensivo == null || state.defensivo!.id.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Salve as informações básicas primeiro (Tab 1)',
      );
      return false;
    }

    if (state.defensivoInfo == null) {
      // Info is optional, so skip if empty
      return true;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(saveDefensivoInfoUseCaseProvider);

      final result = await useCase(
        state.defensivoInfo!.copyWith(defensivoId: state.defensivo!.id),
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            isSaved: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  /// Clear all form data (for new cadastro)
  void clearForm() {
    state = const DefensivoCadastroState();
  }
}
