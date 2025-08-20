// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../model/medicoes_page_model.dart';

/// Service responsável por gerenciar estado reativo da página de medições
class StateService extends ChangeNotifier
    implements ValueListenable<MedicoesPageState> {
  MedicoesPageState _state = const MedicoesPageState();

  MedicoesPageState get state => _state;

  @override
  MedicoesPageState get value => _state;

  /// Atualiza estado com validação
  void _updateState(MedicoesPageState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Define estado de loading
  void setLoading(bool isLoading) {
    _updateState(_state.copyWith(isLoading: isLoading));
  }

  /// Atualiza lista de pluviômetros
  void setPluviometros(List<Pluviometro> pluviometros) {
    _updateState(_state.copyWith(
      pluviometros: pluviometros,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Atualiza lista de medições
  void setMedicoes(List<Medicoes> medicoes) {
    _updateState(_state.copyWith(
      medicoes: medicoes,
      hasError: false,
      errorMessage: null,
    ));
  }

  /// Define erro
  void setError(String errorMessage) {
    _updateState(_state.copyWith(
      hasError: true,
      errorMessage: errorMessage,
      isLoading: false,
    ));
  }

  /// Limpa erro
  void clearError() {
    if (_state.hasError) {
      _updateState(_state.copyWith(
        hasError: false,
        errorMessage: null,
      ));
    }
  }

  /// Atualiza índice do carousel
  void setCarouselIndex(int index) {
    _updateState(_state.copyWith(currentCarouselIndex: index));
  }

  /// Atualiza pluviômetro selecionado
  void setSelectedPluviometro(String? pluviometroId) {
    _updateState(_state.copyWith(selectedPluviometroId: pluviometroId));
  }

  /// Reset completo do estado
  void reset() {
    _updateState(const MedicoesPageState());
  }

  /// Valida se estado está consistente
  bool get isStateValid {
    // Não pode estar carregando e ter erro ao mesmo tempo
    if (_state.isLoading && _state.hasError) return false;

    // Se tem medições, deve ter pluviômetro selecionado
    if (_state.medicoes.isNotEmpty &&
        (_state.selectedPluviometroId?.isEmpty ?? true)) {
      return false;
    }

    return true;
  }

  /// Debug: obtém resumo do estado atual
  Map<String, dynamic> get stateDebugInfo => {
        'isLoading': _state.isLoading,
        'hasError': _state.hasError,
        'errorMessage': _state.errorMessage,
        'pluviometrosCount': _state.pluviometros.length,
        'medicoesCount': _state.medicoes.length,
        'carouselIndex': _state.currentCarouselIndex,
        'selectedPluviometroId': _state.selectedPluviometroId,
        'isStateValid': isStateValid,
      };
}
