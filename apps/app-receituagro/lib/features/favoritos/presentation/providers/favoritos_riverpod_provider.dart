import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/favorito_entity.dart';

/// Estados para Favoritos
class FavoritosState {
  final FavoritosViewState viewState;
  final Map<String, FavoritosViewState> typeViewStates;
  final Map<String, List<FavoritoEntity>> favoritos;
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
    Map<String, FavoritosViewState>? typeViewStates,
    Map<String, List<FavoritoEntity>>? favoritos,
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
  
  int getCountForType(String tipo) => favoritos[tipo]?.length ?? 0;
  
  FavoritosViewState getViewStateForType(String tipo) => 
    typeViewStates[tipo] ?? FavoritosViewState.loading;
    
  String getEmptyMessageForType(String tipo) {
    switch (tipo) {
      case TipoFavorito.defensivo:
        return 'Nenhum defensivo favoritado ainda';
      case TipoFavorito.praga:
        return 'Nenhuma praga favoritada ainda';
      case TipoFavorito.diagnostico:
        return 'Nenhum diagnóstico salvo ainda';
      default:
        return 'Nenhum item favoritado ainda';
    }
  }
}

/// Notifier responsável por gerenciar favoritos
class FavoritosNotifier extends StateNotifier<FavoritosState> {
  FavoritosNotifier() : super(const FavoritosState());

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
  Future<void> _loadFavoritosByType(String tipo) async {
    // Atualiza estado do tipo específico
    final newTypeStates = Map<String, FavoritosViewState>.from(state.typeViewStates);
    newTypeStates[tipo] = FavoritosViewState.loading;
    state = state.copyWith(typeViewStates: newTypeStates);

    try {
      // Simulação - na implementação real usar usecase
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final favoritosList = <FavoritoEntity>[];
      
      final newFavoritos = Map<String, List<FavoritoEntity>>.from(state.favoritos);
      newFavoritos[tipo] = favoritosList;
      
      newTypeStates[tipo] = favoritosList.isEmpty 
          ? FavoritosViewState.empty 
          : FavoritosViewState.loaded;
          
      state = state.copyWith(
        favoritos: newFavoritos,
        typeViewStates: newTypeStates,
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
    try {
      // Simulação - na implementação real usar usecase
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      // Remove da lista local
      final newFavoritos = Map<String, List<FavoritoEntity>>.from(state.favoritos);
      final currentList = newFavoritos[favorito.tipo] ?? [];
      newFavoritos[favorito.tipo] = currentList.where((f) => f.id != favorito.id).toList();
      
      // Atualiza estado do tipo
      final newTypeStates = Map<String, FavoritosViewState>.from(state.typeViewStates);
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
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao remover favorito: $e');
    }
  }

  /// Limpa cache
  Future<void> clearCache() async {
    try {
      // Simulação - na implementação real usar usecase
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await loadAllFavoritos();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao limpar cache: $e');
    }
  }

  /// Verifica se usuário é premium
  bool get isPremium => false; // Simulação - implementar integração real
}

/// Estados de visualização
enum FavoritosViewState {
  loading,
  loaded,
  empty,
  error,
}

// TipoFavorito removido - usar o da entity que define como constantes String

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