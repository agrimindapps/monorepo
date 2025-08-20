// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/fluidoterapia_model.dart';

class FluidoterapiaController {
  final model = FluidoterapiaModel();
  final formKey = GlobalKey<FormState>();
  final pesoController = TextEditingController();
  final percentualController = TextEditingController();
  final horasController = TextEditingController();

  bool showInfoCard = true;

  void dispose() {
    pesoController.dispose();
    percentualController.dispose();
    horasController.dispose();
  }

  void toggleInfoCard() {
    showInfoCard = !showInfoCard;
  }

  void limpar() {
    pesoController.clear();
    percentualController.clear();
    horasController.clear();
    model.limpar();
  }

  bool calcular() {
    if (formKey.currentState!.validate()) {
      model.peso = double.parse(pesoController.text);
      model.percentualHidratacao = double.parse(percentualController.text);
      model.periodoAdministracao = double.parse(horasController.text);
      model.calcular();
      return true;
    }
    return false;
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }
}
