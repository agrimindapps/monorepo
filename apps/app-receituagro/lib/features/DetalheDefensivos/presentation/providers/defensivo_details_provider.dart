import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/repositories/defensivo_repository_impl.dart';
import '../../data/repositories/favorito_repository_impl.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivo_details_usecase.dart';
import '../../domain/usecases/manage_favorito_usecase.dart';

/// Provider para o repositório de defensivos
final defensivoRepositoryProvider = Provider((ref) {
  return DefensivoRepositoryImpl(sl());
});

/// Provider para o repositório de favoritos
final favoritoRepositoryProvider = Provider((ref) {
  return FavoritoRepositoryImpl(sl());
});

/// Provider para o caso de uso de buscar detalhes do defensivo
final getDefensivoDetailsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(defensivoRepositoryProvider);
  return GetDefensivoDetailsUseCase(repository);
});

/// Provider para o caso de uso de gerenciar favoritos
final manageFavoritoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(favoritoRepositoryProvider);
  return ManageFavoritoUseCase(repository);
});

/// Estado para os detalhes do defensivo
class DefensivoDetailsState {
  final DefensivoEntity? defensivo;
  final bool isLoading;
  final String? errorMessage;
  final bool isFavorited;

  const DefensivoDetailsState({
    this.defensivo,
    this.isLoading = false,
    this.errorMessage,
    this.isFavorited = false,
  });

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

  bool get hasError => errorMessage != null;
  bool get hasData => defensivo != null;
}

/// Notifier para gerenciar o estado dos detalhes do defensivo
class DefensivoDetailsNotifier extends StateNotifier<DefensivoDetailsState> {
  DefensivoDetailsNotifier(
    this._getDefensivoDetailsUseCase,
    this._manageFavoritoUseCase,
  ) : super(const DefensivoDetailsState());

  final GetDefensivoDetailsUseCase _getDefensivoDetailsUseCase;
  final ManageFavoritoUseCase _manageFavoritoUseCase;

  /// Carrega os detalhes de um defensivo
  Future<void> loadDefensivoDetails({
    String? idReg,
    String? nome,
  }) async {
    if (state.isLoading) return; // Evita múltiplas chamadas simultâneas

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final params = GetDefensivoDetailsParams(
      idReg: idReg,
      nome: nome,
    );

    if (!params.isValid) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ID de registro ou nome do defensivo é obrigatório',
      );
      return;
    }

    final result = await _getDefensivoDetailsUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (defensivo) {
        state = state.copyWith(
          isLoading: false,
          defensivo: defensivo,
          errorMessage: null,
        );
        
        // Verifica se está favoritado
        _checkFavoritoStatus();
      },
    );
  }

  /// Alterna o status de favorito
  Future<void> toggleFavorito() async {
    if (state.defensivo == null) return;

    final defensivo = state.defensivo!;
    final params = ManageFavoritoParams(
      itemId: defensivo.idReg,
      tipo: 'defensivo',
      nome: defensivo.nomeComum,
      fabricante: defensivo.fabricante,
    );

    final result = await _manageFavoritoUseCase(params);

    result.fold(
      (failure) {
        // Em caso de erro, não altera o estado
      },
      (isFavorited) {
        state = state.copyWith(isFavorited: isFavorited);
      },
    );
  }

  /// Verifica o status de favorito atual
  Future<void> _checkFavoritoStatus() async {
    if (state.defensivo == null) return;

    // Implementar verificação de favorito usando o repository
    // Por simplicidade, vamos assumir que não está favoritado inicialmente
    state = state.copyWith(isFavorited: false);
  }

  /// Limpa os dados carregados
  void clearData() {
    state = const DefensivoDetailsState();
  }

  /// Recarrega os dados atuais
  Future<void> reload() async {
    if (state.defensivo != null) {
      await loadDefensivoDetails(
        idReg: state.defensivo!.idReg,
        nome: state.defensivo!.nomeComum,
      );
    }
  }
}

/// Provider para o notifier dos detalhes do defensivo
final defensivoDetailsNotifierProvider = 
    StateNotifierProvider<DefensivoDetailsNotifier, DefensivoDetailsState>((ref) {
  final getUseCase = ref.watch(getDefensivoDetailsUseCaseProvider);
  final manageUseCase = ref.watch(manageFavoritoUseCaseProvider);
  return DefensivoDetailsNotifier(getUseCase, manageUseCase);
});

/// Provider conveniente para acessar apenas o defensivo atual
final currentDefensivoProvider = Provider<DefensivoEntity?>((ref) {
  final state = ref.watch(defensivoDetailsNotifierProvider);
  return state.defensivo;
});

/// Provider conveniente para verificar se está carregando
final isLoadingDefensivoProvider = Provider<bool>((ref) {
  final state = ref.watch(defensivoDetailsNotifierProvider);
  return state.isLoading;
});

/// Provider conveniente para acessar erros
final defensivoErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(defensivoDetailsNotifierProvider);
  return state.errorMessage;
});

/// Provider conveniente para status de favorito
final isFavoritedProvider = Provider<bool>((ref) {
  final state = ref.watch(defensivoDetailsNotifierProvider);
  return state.isFavorited;
});