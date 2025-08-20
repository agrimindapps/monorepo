// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Modelo para o cálculo de distribuição de macronutrientes
class MacronutrientesModel {
  // Controllers e focus nodes
  final unfocusNode = FocusNode();
  final caloriasDiariasController = TextEditingController();
  final FocusNode focusCalorias = FocusNode();

  // Controladores para porcentagens (padrão equilibrado)
  final carboidratosController = TextEditingController(text: '50');
  final proteinasController = TextEditingController(text: '25');
  final gordurasController = TextEditingController(text: '25');

  // Variáveis de dados
  double caloriasDiarias = 0;
  int carboidratosPorcentagem = 50;
  int proteinasPorcentagem = 25;
  int gordurasPorcentagem = 25;

  // Resultados em gramas
  double carboidratosGramas = 0;
  double proteinasGramas = 0;
  double gordurasGramas = 0;

  // Resultados em calorias
  double carboidratosCalorias = 0;
  double proteinasCalorias = 0;
  double gordurasCalorias = 0;

  bool calculado = false;

  // Seleção de tipo de distribuição predefinida
  int distribuicaoSelecionada = 3;

  // Formatadores de texto
  final caloriasmask = MaskTextInputFormatter(
    mask: '####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final porcentagemmask = MaskTextInputFormatter(
    mask: '##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void dispose() {
    unfocusNode.dispose();
    caloriasDiariasController.dispose();
    carboidratosController.dispose();
    proteinasController.dispose();
    gordurasController.dispose();
    focusCalorias.dispose();
  }
}
