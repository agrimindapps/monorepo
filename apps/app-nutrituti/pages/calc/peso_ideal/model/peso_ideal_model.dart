// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PesoIdealModel {
  final TextEditingController alturaController = TextEditingController();
  final FocusNode focusAltura = FocusNode();

  double altura = 0;
  Map<String, dynamic> generoDef;

  final List<Map<String, dynamic>> generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];

  double resultado = 0;
  bool calculado = false;
  bool showInfoCard = true;

  final NumberFormat numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  var pesoMask = MaskTextInputFormatter(
    mask: '#,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  PesoIdealModel() : generoDef = {'id': 1, 'text': 'Masculino'};

  void limpar() {
    generoDef = {'id': 1, 'text': 'Masculino'};
    alturaController.clear();
    altura = 0;
    resultado = 0;
    calculado = false;
  }

  void calcular() {
    altura = double.parse(alturaController.text.replaceAll(',', '.'));

    resultado = generoDef['id'] == 1
        ? 35.15 + ((altura - 130) * 0.75)
        : 33.875 + ((altura - 130) * 0.675);

    resultado = double.parse(resultado.toStringAsFixed(2));
    calculado = true;
  }

  void dispose() {
    alturaController.dispose();
    focusAltura.dispose();
  }
}
