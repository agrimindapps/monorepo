import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/defensivo_details_entity.dart';
import '../../domain/usecases/get_defensivo_details_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

/// Provider para gerenciar estado dos detalhes do defensivo
/// Responsabilidade única: dados básicos, favoritos e loading
class DefensivoDetailsProvider extends ChangeNotifier {
  final GetDefensivoDetailsUsecase _getDefensivoDetailsUsecase;
  final ToggleFavoriteUsecase _toggleFavoriteUsecase;

  DefensivoDetailsProvider({
    GetDefensivoDetailsUsecase? getDefensivoDetailsUsecase,
    ToggleFavoriteUsecase? toggleFavoriteUsecase,
  }) : _getDefensivoDetailsUsecase = getDefensivoDetailsUsecase ?? sl<GetDefensivoDetailsUsecase>(),
        _toggleFavoriteUsecase = toggleFavoriteUsecase ?? sl<ToggleFavoriteUsecase>();

  DefensivoDetailsEntity? _defensivo;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFavorited = false;

  // Getters
  DefensivoDetailsEntity? get defensivo => _defensivo;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isFavorited => _isFavorited;

  /// Carrega detalhes do defensivo
  Future<void> loadDefensivoDetails(String defensivoName) async {
    _setLoading(true);
    _clearError();

    final result = await _getDefensivoDetailsUsecase(
      GetDefensivoDetailsParams(defensivoName: defensivoName),
    );

    result.fold(
      (failure) {
        _setError('Erro ao carregar defensivo: ${failure.message}');
        _setLoading(false);
      },
      (defensivo) {
        _defensivo = defensivo;
        _setLoading(false);
        if (defensivo == null) {
          _setError('Defensivo não encontrado');
        }
      },
    );
  }

  /// Alterna status de favorito
  Future<void> toggleFavorite() async {
    if (_defensivo == null) return;

    final defensivoData = {
      'nome': _defensivo!.nomeComum,
      'fabricante': _defensivo!.fabricante,
      'idReg': _defensivo!.id,
    };

    final result = await _toggleFavoriteUsecase(
      ToggleFavoriteParams(
        defensivoId: _defensivo!.id,
        defensivoData: defensivoData,
      ),
    );

    result.fold(
      (failure) {
        // Em caso de falha, não altera o estado UI
      },
      (success) {
        if (success) {
          _isFavorited = !_isFavorited;
          notifyListeners();
        }
      },
    );
  }

  /// Define estado de favorito (chamado na inicialização)
  void setFavoritedState(bool isFavorited) {
    _isFavorited = isFavorited;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  /// Reset do provider para uso em nova tela
  void reset() {
    _defensivo = null;
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    _isFavorited = false;
    notifyListeners();
  }
}