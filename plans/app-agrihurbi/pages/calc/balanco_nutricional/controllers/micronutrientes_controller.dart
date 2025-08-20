// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants.dart';
import '../models/micronutrientes_model.dart';

class MicronutrientesController extends GetxController {
  // Text Controllers
  final teorZincoController = TextEditingController();
  final teorBoroController = TextEditingController();
  final teorCobreController = TextEditingController();
  final teorManganesController = TextEditingController();
  final teorFerroController = TextEditingController();
  final areaPlantadaController = TextEditingController();
  final culturaController = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();
  final focus6 = FocusNode();
  final focus7 = FocusNode();

  // Estado
  bool calculado = false;
  final MicronutrientesModel model;
  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  MicronutrientesController(this.model) {
    model.culturaController.text = model.culturaSelecionada;
  }

  @override
  void onClose() {
    teorZincoController.dispose();
    teorBoroController.dispose();
    teorCobreController.dispose();
    teorManganesController.dispose();
    teorFerroController.dispose();
    areaPlantadaController.dispose();
    culturaController.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    focus5.dispose();
    focus6.dispose();
    focus7.dispose();
    super.onClose();
  }

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError
                  ? BalancoNutricionalIcons.errorOutline
                  : BalancoNutricionalIcons.checkCircleOutline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? BalancoNutricionalColors.red900
            : BalancoNutricionalColors.green700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  void calcular(BuildContext context) {
    if (model.culturaSelecionada.isEmpty) {
      focus7.requestFocus();
      _exibirMensagem(context, BalancoNutricionalStrings.msgErroCultura);
      return;
    }

    final campos = [
      {
        'controller': teorZincoController,
        'nome': BalancoNutricionalStrings.labelTeorZinco,
        'focus': focus1,
        'min': 0.0,
        'max': 50.0,
      },
      {
        'controller': teorBoroController,
        'nome': BalancoNutricionalStrings.labelTeorBoro,
        'focus': focus2,
        'min': 0.0,
        'max': 10.0,
      },
      {
        'controller': teorCobreController,
        'nome': BalancoNutricionalStrings.labelTeorCobre,
        'focus': focus3,
        'min': 0.0,
        'max': 20.0,
      },
      {
        'controller': teorManganesController,
        'nome': BalancoNutricionalStrings.labelTeorManganes,
        'focus': focus4,
        'min': 0.0,
        'max': 100.0,
      },
      {
        'controller': teorFerroController,
        'nome': BalancoNutricionalStrings.labelTeorFerro,
        'focus': focus5,
        'min': 0.0,
        'max': 200.0,
      },
      {
        'controller': areaPlantadaController,
        'nome': BalancoNutricionalStrings.labelAreaPlantada,
        'focus': focus6,
        'min': 0.1,
        'max': 10000.0,
      },
    ];

    for (final campo in campos) {
      final controllerCampo = campo['controller'] as TextEditingController;
      final nomeCampo = campo['nome'] as String;
      final focusCampo = campo['focus'] as FocusNode;
      final min = campo['min'] as double;
      final max = campo['max'] as double;

      if (controllerCampo.text.isEmpty) {
        focusCampo.requestFocus();
        _exibirMensagem(
            context,
            BalancoNutricionalStrings.msgErroCampoObrigatorio
                .replaceFirst('{campo}', nomeCampo));
        return;
      }

      final valorStr = controllerCampo.text.replaceAll(',', '.');
      final valor = double.tryParse(valorStr);

      if (valor == null) {
        focusCampo.requestFocus();
        _exibirMensagem(
            context,
            BalancoNutricionalStrings.msgErroNumeroInvalido
                .replaceFirst('{campo}', nomeCampo));
        return;
      }
      if (valor < min) {
        focusCampo.requestFocus();
        _exibirMensagem(
            context,
            BalancoNutricionalStrings.msgErroValorMin
                .replaceFirst('{campo}', nomeCampo)
                .replaceFirst('{min}', min.toString()));
        return;
      }
      if (valor > max) {
        focusCampo.requestFocus();
        _exibirMensagem(
            context,
            BalancoNutricionalStrings.msgErroValorMax
                .replaceFirst('{campo}', nomeCampo)
                .replaceFirst('{max}', max.toString()));
        return;
      }
    }

    try {
      model.teorZinco =
          double.parse(teorZincoController.text.replaceAll(',', '.'));
      model.teorBoro =
          double.parse(teorBoroController.text.replaceAll(',', '.'));
      model.teorCobre =
          double.parse(teorCobreController.text.replaceAll(',', '.'));
      model.teorManganes =
          double.parse(teorManganesController.text.replaceAll(',', '.'));
      model.teorFerro =
          double.parse(teorFerroController.text.replaceAll(',', '.'));
      model.areaPlantada =
          double.parse(areaPlantadaController.text.replaceAll(',', '.'));

      model.calcular();
      calculado = true;
      
      _exibirMensagem(context, BalancoNutricionalStrings.msgSucessoCalculo,
          isError: false);
    } catch (e) {
      _exibirMensagem(context, 'Erro ao calcular: ${e.toString()}');
    }
  }

  void limpar() {
    teorZincoController.clear();
    teorBoroController.clear();
    teorCobreController.clear();
    teorManganesController.clear();
    teorFerroController.clear();
    areaPlantadaController.clear();
    model.limpar();
    calculado = false;
    
  }

  void setCultura(String cultura) {
    if (cultura != model.culturaSelecionada) {
      model.culturaSelecionada = cultura;
      culturaController.text = cultura;

      // Limpar os campos ao mudar de cultura
      limpar();

      
    }
  }

  String formatNumber(double value) {
    return _numberFormat.format(value);
  }

  String compartilhar() {
    return model.gerarTextoCompartilhamento();
  }
}
