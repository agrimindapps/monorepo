// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../../intermediate.dart';
import '../models/atualizacao_model.dart';
import '../models/atualizacao_state.dart';

class AtualizacaoController extends GetxController {
  final Rx<AtualizacaoState> _state = const AtualizacaoState().obs;
  AtualizacaoState get state => _state.value;

  bool get hasData => state.atualizacoesList.isNotEmpty;
  int get totalAtualizacoes => state.atualizacoesList.length;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
    carregarAtualizacoes();
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(state.copyWith(isDark: value));
    });
  }

  void _updateState(AtualizacaoState newState) {
    _state.value = newState;
  }

  void carregarAtualizacoes() {
    _updateState(state.copyWith(isLoading: true));

    try {
      final atualizacoesData = GlobalEnvironment().atualizacoesText;
      final atualizacoesList = atualizacoesData
          .map((item) => AtualizacaoModel.fromMap(item))
          .toList();

      _updateState(state.copyWith(
        atualizacoesList: atualizacoesList,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(state.copyWith(
        atualizacoesList: [],
        isLoading: false,
      ));
    }
  }

  void recarregarAtualizacoes() {
    carregarAtualizacoes();
  }
}
