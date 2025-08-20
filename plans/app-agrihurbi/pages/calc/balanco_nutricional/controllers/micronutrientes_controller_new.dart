// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../models/micronutrientes_model.dart';

class MicronutrientesController extends GetxController {
  final MicronutrientesModel model;
  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  // Maximum allowed values for each field
  final Map<String, double> _maxValues = {
    'zinco': 100.0, // mg/dm³
    'boro': 50.0, // mg/dm³
    'cobre': 50.0, // mg/dm³
    'manganes': 200.0, // mg/dm³
    'ferro': 500.0, // mg/dm³
    'area': 100000.0 // hectares
  };

  MicronutrientesController(this.model) {
    model.culturaController.text = model.culturaSelecionada;
    _setupFieldValidation();
  }

  void _setupFieldValidation() {
    // Add listeners for real-time validation
    model.teorZincoController.addListener(() =>
        _validateField(model.teorZincoController, 'zinco', model.focusZinco));

    model.teorBoroController.addListener(() =>
        _validateField(model.teorBoroController, 'boro', model.focusBoro));

    model.teorCobreController.addListener(() =>
        _validateField(model.teorCobreController, 'cobre', model.focusCobre));

    model.teorManganesController.addListener(() => _validateField(
        model.teorManganesController, 'manganes', model.focusManganes));

    model.teorFerroController.addListener(() =>
        _validateField(model.teorFerroController, 'ferro', model.focusFerro));

    model.areaPlantadaController.addListener(() =>
        _validateField(model.areaPlantadaController, 'area', model.focusArea));
  }

  void _validateField(
      TextEditingController controller, String fieldName, FocusNode focusNode) {
    if (controller.text.isEmpty) return;

    String text = controller.text.replaceAll(',', '.');
    double? value = double.tryParse(text);

    if (value == null) {
      controller.text = '';
      return;
    }

    // Validate value range
    if (value < 0) {
      controller.text = '0';
    } else if (value > _maxValues[fieldName]!) {
      controller.text = _maxValues[fieldName]!.toString();
    } else {
      // Format to 2 decimal places
      controller.text = value.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  void onCulturaChanged(String? newCultura) {
    if (newCultura != null && newCultura != model.culturaSelecionada) {
      model.culturaSelecionada = newCultura;
      model.culturaController.text = newCultura;
      if (model.calculado) {
        calcular(null);
      }
      
    }
  }

  bool validarCampos(BuildContext? context) {
    // Validate Zinc
    if (model.teorZincoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o teor de Zinco no solo');
      model.focusZinco.requestFocus();
      return false;
    }

    double zinco =
        double.parse(model.teorZincoController.text.replaceAll(',', '.'));
    if (zinco > _maxValues['zinco']!) {
      _exibirMensagem(context,
          'Teor de Zinco não pode ser maior que ${_maxValues['zinco']} mg/dm³');
      model.focusZinco.requestFocus();
      return false;
    }

    // Validate Boron
    if (model.teorBoroController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o teor de Boro no solo');
      model.focusBoro.requestFocus();
      return false;
    }

    double boro =
        double.parse(model.teorBoroController.text.replaceAll(',', '.'));
    if (boro > _maxValues['boro']!) {
      _exibirMensagem(context,
          'Teor de Boro não pode ser maior que ${_maxValues['boro']} mg/dm³');
      model.focusBoro.requestFocus();
      return false;
    }

    // Validate Copper
    if (model.teorCobreController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o teor de Cobre no solo');
      model.focusCobre.requestFocus();
      return false;
    }

    double cobre =
        double.parse(model.teorCobreController.text.replaceAll(',', '.'));
    if (cobre > _maxValues['cobre']!) {
      _exibirMensagem(context,
          'Teor de Cobre não pode ser maior que ${_maxValues['cobre']} mg/dm³');
      model.focusCobre.requestFocus();
      return false;
    }

    // Validate Manganese
    if (model.teorManganesController.text.isEmpty) {
      _exibirMensagem(
          context, 'Necessário informar o teor de Manganês no solo');
      model.focusManganes.requestFocus();
      return false;
    }

    double manganes =
        double.parse(model.teorManganesController.text.replaceAll(',', '.'));
    if (manganes > _maxValues['manganes']!) {
      _exibirMensagem(context,
          'Teor de Manganês não pode ser maior que ${_maxValues['manganes']} mg/dm³');
      model.focusManganes.requestFocus();
      return false;
    }

    // Validate Iron
    if (model.teorFerroController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o teor de Ferro no solo');
      model.focusFerro.requestFocus();
      return false;
    }

    double ferro =
        double.parse(model.teorFerroController.text.replaceAll(',', '.'));
    if (ferro > _maxValues['ferro']!) {
      _exibirMensagem(context,
          'Teor de Ferro não pode ser maior que ${_maxValues['ferro']} mg/dm³');
      model.focusFerro.requestFocus();
      return false;
    }

    // Validate Area
    if (model.areaPlantadaController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a área plantada');
      model.focusArea.requestFocus();
      return false;
    }

    double area =
        double.parse(model.areaPlantadaController.text.replaceAll(',', '.'));
    if (area <= 0) {
      _exibirMensagem(context, 'Área plantada deve ser maior que 0');
      model.focusArea.requestFocus();
      return false;
    }

    if (area > _maxValues['area']!) {
      _exibirMensagem(context,
          'Área plantada não pode ser maior que ${_numberFormat.format(_maxValues['area'])} hectares');
      model.focusArea.requestFocus();
      return false;
    }

    return true;
  }

  void calcular(BuildContext? context) {
    if (!validarCampos(context)) return;

    // Parse input values
    model.teorZinco =
        double.parse(model.teorZincoController.text.replaceAll(',', '.'));
    model.teorBoro =
        double.parse(model.teorBoroController.text.replaceAll(',', '.'));
    model.teorCobre =
        double.parse(model.teorCobreController.text.replaceAll(',', '.'));
    model.teorManganes =
        double.parse(model.teorManganesController.text.replaceAll(',', '.'));
    model.teorFerro =
        double.parse(model.teorFerroController.text.replaceAll(',', '.'));
    model.areaPlantada =
        double.parse(model.areaPlantadaController.text.replaceAll(',', '.'));

    // Calculate values
    model.calcular();
    model.calculado = true;
    
  }

  void limpar() {
    model.limpar();
    
  }

  void compartilhar() {
    if (!model.calculado) return;
    SharePlus.instance.share(ShareParams(text: model.gerarTextoCompartilhamento()));
  }

  void _exibirMensagem(BuildContext? context, String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade900,
      ));
  }

  String formatNumber(num value) {
    return _numberFormat.format(value);
  }
}
