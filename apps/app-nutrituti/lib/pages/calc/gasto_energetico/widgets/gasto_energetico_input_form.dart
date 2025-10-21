// Este arquivo deve ser adaptado do original, removendo lógica de estado e recebendo callbacks e controllers do controller

// Flutter imports:
import 'package:flutter/material.dart';

class GastoEnergeticoInputForm extends StatelessWidget {
  final int generoSelecionado;
  final TextEditingController pesoController;
  final TextEditingController alturaController;
  final TextEditingController idadeController;
  final Map<String, TextEditingController> horasControllers;
  final FocusNode focusPeso;
  final FocusNode focusAltura;
  final FocusNode focusIdade;
  final Function() onCalcular;
  final Function() onLimpar;
  final Function() onInfoPressed;
  final Function(int) onGeneroChanged;

  const GastoEnergeticoInputForm({
    super.key,
    required this.generoSelecionado,
    required this.pesoController,
    required this.alturaController,
    required this.idadeController,
    required this.horasControllers,
    required this.focusPeso,
    required this.focusAltura,
    required this.focusIdade,
    required this.onCalcular,
    required this.onLimpar,
    required this.onInfoPressed,
    required this.onGeneroChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    return Container(); // Implemente conforme o widget original
  }
}
