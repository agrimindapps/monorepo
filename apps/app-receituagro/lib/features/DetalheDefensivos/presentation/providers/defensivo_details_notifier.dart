import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivo_details_usecase.dart';
import '../../domain/usecases/manage_favorito_usecase.dart';

part 'defensivo_details_notifier.g.dart';

/// Defensivo Details state
class DefensivoDetailsState {
  final DefensivoEntity? defensivo;
  final bool isLoading;
  final String? errorMessage;
  final bool isFavorited;

  const DefensivoDetailsState({
    this.defensivo,
    required this.isLoading,
    this.errorMessage,
    required this.isFavorited,
  });

  factory DefensivoDetailsState.initial() {
    return const DefensivoDetailsState(
      defensivo: null,
      isLoading: false,
      errorMessage: null,
      isFavorited: false,
    );
  }

  DefensivoDetailsState copyWith({
    DefensivoEntity? defensivo,
    bool? isLoading,
    String? errorMessage,
    bool? isFavorited,
  }) {
    return DefensivoDetailsState(
      defensivo: defensivo ?? this.defensivo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  DefensivoDetailsState clearError() {
    return copyWith(errorMessage: null);
  }
  bool get hasError => errorMessage != null;
  bool get hasData => defensivo != null;
}

/// Notifier para gerenciar o estado dos detalhes do defensivo (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class DefensivoDetailsNotifier extends _$DefensivoDetailsNotifier {
  late final GetDefensivoDetailsUseCase _getDefensivoDetailsUseCase;
  late final ManageFavoritoUseCase _manageFavoritoUseCase;

  @override
  Future<DefensivoDetailsState> build() async {
    _getDefensivoDetailsUseCase = di.sl<GetDefensivoDetailsUseCase>();
    _manageFavoritoUseCase = di.sl<ManageFavoritoUseCase>();

    return DefensivoDetailsState.initial();
  }

  /// Carrega os detalhes de um defensivo
  Future<void> loadDefensivoDetails({
    String? idReg,
    String? nome,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;
    if (currentState.isLoading) return;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
      ).clearError(),
    );

    final params = GetDefensivoDetailsParams(
      idReg: idReg,
      nome: nome,
    );

    if (!params.isValid) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'ID de registro ou nome do defensivo é obrigatório',
        ),
      );
      return;
    }

    try {
      final result = await _getDefensivoDetailsUseCase(params);

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
          );
        },
        (defensivo) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              defensivo: defensivo,
            ).clearError(),
          );
          _checkFavoritoStatus();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Alterna o status de favorito
  Future<void> toggleFavorito() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.defensivo == null) return;

    try {
      final defensivo = currentState.defensivo!;
      final params = ManageFavoritoParams(
        itemId: defensivo.idReg,
        tipo: 'defensivo',
        nome: defensivo.nomeComum,
        fabricante: defensivo.fabricante,
      );

      final result = await _manageFavoritoUseCase(params);

      result.fold(
        (failure) {
        },
        (isFavorited) {
          state = AsyncValue.data(currentState.copyWith(isFavorited: isFavorited));
        },
      );
    } catch (e) {
    }
  }

  /// Verifica o status de favorito atual
  Future<void> _checkFavoritoStatus() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.defensivo == null) return;
    state = AsyncValue.data(currentState.copyWith(isFavorited: false));
  }

  /// Limpa os dados carregados
  void clearData() {
    state = AsyncValue.data(DefensivoDetailsState.initial());
  }

  /// Recarrega os dados atuais
  Future<void> reload() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.defensivo != null) {
      await loadDefensivoDetails(
        idReg: currentState.defensivo!.idReg,
        nome: currentState.defensivo!.nomeComum,
      );
    }
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }
}
