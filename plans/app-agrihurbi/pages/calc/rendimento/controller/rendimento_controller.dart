// Package imports:
import 'package:get/get.dart';
// Project imports:
import '../model/rendimento_model.dart';

class RendimentoController extends GetxController {
  RendimentoModel? _rendimentoAtual;
  final RxBool _isDark = false.obs;
  final RxString _mensagemErro = ''.obs;

  RendimentoModel? get rendimentoAtual => _rendimentoAtual;
  bool get isDark => _isDark.value;
  String get mensagemErro => _mensagemErro.value;

  void setRendimento(RendimentoModel rendimento) {
    _rendimentoAtual = rendimento;
    
  }

  void setDarkMode(bool value) {
    _isDark.value = value;
  }

  double calcularRendimento() {
    if (_rendimentoAtual == null) {
      _mensagemErro.value = 'Nenhum modelo de rendimento selecionado';
      
      return 0.0;
    }

    try {
      double resultado = _rendimentoAtual!.calcularRendimento();
      _mensagemErro.value = '';
      
      return resultado;
    } catch (e) {
      _mensagemErro.value = 'Erro ao calcular rendimento: ${e.toString()}';
      
      return 0.0;
    }
  }

  void limparErro() {
    _mensagemErro.value = '';
    
  }
}
