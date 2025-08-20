// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Project imports:
import '../models/evapotranspiracao_model.dart';

class EvapotranspiracaoController extends GetxController {
  final _model = EvapotranspiracaoModel(
    evapotranspiracaoReferencia: 0,
    coeficienteCultura: 0,
    coeficienteEstresse: 1.0, // Valor padrão
  );

  // Controllers para os campos de texto
  final evapotranspiracaoReferenciaController = TextEditingController();
  final coeficienteCulturaController = TextEditingController();
  final coeficienteEstresseController = TextEditingController();

  // Focus nodes
  final evapotranspiracaoReferenciaFocus = FocusNode();
  final coeficienteCulturaFocus = FocusNode();
  final coeficienteEstresseFocus = FocusNode();

  // Estado do formulário
  final RxBool _calculado = false.obs;
  final RxBool _showHelp = false.obs;

  // Getters
  bool get calculado => _calculado.value;
  bool get showHelp => _showHelp.value;
  double get evapotranspiracaoReferencia => _model.evapotranspiracaoReferencia;
  double get coeficienteCultura => _model.coeficienteCultura;
  double get coeficienteEstresse => _model.coeficienteEstresse;
  double get evapotranspiracaoCultura => _model.evapotranspiracaoCultura;

  // Inicialização
  EvapotranspiracaoController() {
    _inicializarControllers();
  }

  void _inicializarControllers() {
    // Definir valores padrão
    coeficienteEstresseController.text = '1.0';
  }

  // Validação de campos
  bool validarCampos(BuildContext context) {
    if (evapotranspiracaoReferenciaController.text.isEmpty) {
      evapotranspiracaoReferenciaFocus.requestFocus();
      _exibirMensagem(
          context, 'Necessário informar a evapotranspiração de referência');
      return false;
    }

    if (coeficienteCulturaController.text.isEmpty) {
      coeficienteCulturaFocus.requestFocus();
      _exibirMensagem(
          context, 'Necessário informar o coeficiente de cultura (Kc)');
      return false;
    }

    if (coeficienteEstresseController.text.isEmpty) {
      coeficienteEstresseFocus.requestFocus();
      _exibirMensagem(
          context, 'Necessário informar o coeficiente de estresse (Ks)');
      return false;
    }

    return true;
  }

  // Calcular a evapotranspiração da cultura
  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    try {
      // Obter os valores dos campos
      _model.evapotranspiracaoReferencia = double.parse(
          evapotranspiracaoReferenciaController.text.replaceAll(',', '.'));

      _model.coeficienteCultura =
          double.parse(coeficienteCulturaController.text.replaceAll(',', '.'));

      _model.coeficienteEstresse =
          double.parse(coeficienteEstresseController.text.replaceAll(',', '.'));

      // Calcular
      _model.calcular();

      // Atualizar estado
      _calculado.value = true;
      
    } catch (e) {
      _exibirMensagem(
          context, 'Erro ao calcular: verifique os valores informados');
    }
  }

  // Limpar o formulário
  void limpar(BuildContext context) {
    evapotranspiracaoReferenciaController.clear();
    coeficienteCulturaController.clear();
    coeficienteEstresseController.text = '1.0';

    _model.reset();
    _calculado.value = false;

    _exibirMensagem(context, 'Formulário limpo!', isError: false);
    
  }

  // Mostrar/ocultar ajuda
  void toggleHelp() {
    _showHelp.value = !_showHelp.value;
    
  }

  // Exibir mensagem
  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade800,
      ));
  }

  @override
  void onClose() {
    // Dispose controllers
    evapotranspiracaoReferenciaController.dispose();
    coeficienteCulturaController.dispose();
    coeficienteEstresseController.dispose();

    // Dispose focus nodes
    evapotranspiracaoReferenciaFocus.dispose();
    coeficienteCulturaFocus.dispose();
    coeficienteEstresseFocus.dispose();

    super.onClose();
  }
}
