import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart' as di;
import '../../../core/interfaces/i_premium_service.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/usecases/favoritos_usecases_stub.dart';

/// Estados para Favoritos
class FavoritosState {
  final FavoritosViewState viewState;
  final Map<TipoFavorito, FavoritosViewState> typeViewStates;
  final Map<TipoFavorito, List<FavoritoEntity>> favoritos;
  final String? errorMessage;
  final bool isInitialized;

  const FavoritosState({
    this.viewState = FavoritosViewState.loading,
    this.typeViewStates = const {},
    this.favoritos = const {},
    this.errorMessage,
    this.isInitialized = false,
  });

  FavoritosState copyWith({
    FavoritosViewState? viewState,
    Map<TipoFavorito, FavoritosViewState>? typeViewStates,
    Map<TipoFavorito, List<FavoritoEntity>>? favoritos,
    String? errorMessage,
    bool? isInitialized,
    bool clearError = false,
  }) {
    return FavoritosState(
      viewState: viewState ?? this.viewState,
      typeViewStates: typeViewStates ?? this.typeViewStates,
      favoritos: favoritos ?? this.favoritos,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  // Getters convenientes
  List<FavoritoEntity> get defensivos => favoritos[TipoFavorito.defensivo] ?? [];
  List<FavoritoEntity> get pragas => favoritos[TipoFavorito.praga] ?? [];
  List<FavoritoEntity> get diagnosticos => favoritos[TipoFavorito.diagnostico] ?? [];
  
  int getCountForType(TipoFavorito tipo) => favoritos[tipo]?.length ?? 0;
  
  FavoritosViewState getViewStateForType(TipoFavorito tipo) => 
    typeViewStates[tipo] ?? FavoritosViewState.loading;
    
  String getEmptyMessageForType(TipoFavorito tipo) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return 'Nenhum defensivo favoritado ainda';
      case TipoFavorito.praga:
        return 'Nenhuma praga favoritada ainda';
      case TipoFavorito.diagnostico:
        return 'Nenhum diagnóstico salvo ainda';
    }
  }
}

/// Notifier responsável por gerenciar favoritos
class FavoritosNotifier extends StateNotifier<FavoritosState> {
  final FavoritosUsecases _usecases;
  final IPremiumService _premiumService;

  FavoritosNotifier({
    FavoritosUsecases? usecases,
    IPremiumService? premiumService,
  }) : _usecases = usecases ?? di.sl<FavoritosUsecases>(),
        _premiumService = premiumService ?? di.sl<IPremiumService>(),
        super(const FavoritosState());

  /// Inicializa favoritos
  Future<void> initialize() async {
    if (state.isInitialized) return;
    
    await loadAllFavoritos();
    state = state.copyWith(isInitialized: true);
  }

  /// Carrega todos os favoritos
  Future<void> loadAllFavoritos() async {
    state = state.copyWith(viewState: FavoritosViewState.loading, clearError: true);

    try {
      // Carrega cada tipo de favorito separadamente
      await Future.wait([
        _loadFavoritosByType(TipoFavorito.defensivo),
        _loadFavoritosByType(TipoFavorito.praga),
        _loadFavoritosByType(TipoFavorito.diagnostico),
      ]);

      // Determina o estado geral
      final hasAnyFavoritos = state.favoritos.values.any((list) => list.isNotEmpty);
      state = state.copyWith(
        viewState: hasAnyFavoritos ? FavoritosViewState.loaded : FavoritosViewState.empty,
      );
    } catch (e) {
      state = state.copyWith(
        viewState: FavoritosViewState.error,
        errorMessage: 'Erro ao carregar favoritos: $e',
      );
    }
  }

  /// Carrega favoritos por tipo
  Future<void> _loadFavoritosByType(TipoFavorito tipo) async {
    // Atualiza estado do tipo específico
    final newTypeStates = Map<TipoFavorito, FavoritosViewState>.from(state.typeViewStates);
    newTypeStates[tipo] = FavoritosViewState.loading;
    state = state.copyWith(typeViewStates: newTypeStates);

    try {
      final result = await _usecases.getFavoritosByType(tipo);
      
      result.fold(
        (failure) {
          newTypeStates[tipo] = FavoritosViewState.error;
          state = state.copyWith(
            typeViewStates: newTypeStates,
            errorMessage: failure.message,
          );
        },
        (favoritosList) {
          final newFavoritos = Map<TipoFavorito, List<FavoritoEntity>>.from(state.favoritos);
          newFavoritos[tipo] = favoritosList;
          
          newTypeStates[tipo] = favoritosList.isEmpty 
              ? FavoritosViewState.empty 
              : FavoritosViewState.loaded;
              
          state = state.copyWith(
            favoritos: newFavoritos,
            typeViewStates: newTypeStates,
          );
        },
      );
    } catch (e) {
      newTypeStates[tipo] = FavoritosViewState.error;
      state = state.copyWith(
        typeViewStates: newTypeStates,
        errorMessage: 'Erro ao carregar $tipo: $e',
      );
    }
  }

  /// Remove favorito
  Future<void> removeFavorito(FavoritoEntity favorito) async {
    final result = await _usecases.removeFavorito(favorito.id, favorito.tipo);
    
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // Remove da lista local
        final newFavoritos = Map<TipoFavorito, List<FavoritoEntity>>.from(state.favoritos);
        final currentList = newFavoritos[favorito.tipo] ?? [];
        newFavoritos[favorito.tipo] = currentList.where((f) => f.id != favorito.id).toList();
        
        // Atualiza estado do tipo
        final newTypeStates = Map<TipoFavorito, FavoritosViewState>.from(state.typeViewStates);
        newTypeStates[favorito.tipo] = newFavoritos[favorito.tipo]!.isEmpty 
            ? FavoritosViewState.empty 
            : FavoritosViewState.loaded;
        
        // Atualiza estado geral
        final hasAnyFavoritos = newFavoritos.values.any((list) => list.isNotEmpty);
        
        state = state.copyWith(
          favoritos: newFavoritos,
          typeViewStates: newTypeStates,
          viewState: hasAnyFavoritos ? FavoritosViewState.loaded : FavoritosViewState.empty,
          clearError: true,
        );
      },
    );
  }

  /// Limpa cache
  Future<void> clearCache() async {
    final result = await _usecases.clearCache();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => loadAllFavoritos(),
    );
  }

  /// Verifica se usuário é premium
  bool get isPremium => _premiumService.isPremium;
}

/// Estados de visualização
enum FavoritosViewState {
  loading,
  loaded,
  empty,
  error,
}

/// Tipos de favorito
enum TipoFavorito {
  defensivo,
  praga,
  diagnostico,
}

/// Provider principal
final favoritosProvider = StateNotifierProvider<FavoritosNotifier, FavoritosState>((ref) {
  return FavoritosNotifier();
});

/// Computed providers
final defensivosFavoritosProvider = Provider<List<FavoritoEntity>>((ref) {
  return ref.watch(favoritosProvider).defensivos;
});

final pragasFavoritasProvider = Provider<List<FavoritoEntity>>((ref) {
  return ref.watch(favoritosProvider).pragas;
});

final diagnosticosFavoritosProvider = Provider<List<FavoritoEntity>>((ref) {
  return ref.watch(favoritosProvider).diagnosticos;
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(favoritosProvider.notifier).isPremium;
});