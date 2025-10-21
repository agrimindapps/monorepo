// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ProteinasDiariasModel {
  // Controllers e focus nodes
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController atividadeFisicaController =
      TextEditingController();
  final FocusNode focusPeso = FocusNode();
  final FocusNode focusAtividadeFisica = FocusNode();

  // Variáveis de entrada
  double peso = 0;
  String nivelAtividade = 'Sedentário'; // Padrão

  // Lista de níveis de atividade
  final List<String> niveisAtividade = [
    'Sedentário',
    'Levemente ativo',
    'Moderadamente ativo',
    'Muito ativo',
    'Extremamente ativo'
  ];

  // Variáveis de resultado
  double proteinasMinimas = 0;
  double proteinasMaximas = 0;
  bool calculado = false;

  // Formatador para números
  final NumberFormat numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  // Formatadores de texto
  var pesoMask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void limpar() {
    pesoController.clear();
    nivelAtividade = 'Sedentário';
    peso = 0;
    proteinasMinimas = 0;
    proteinasMaximas = 0;
    calculado = false;
  }

  void dispose() {
    pesoController.dispose();
    atividadeFisicaController.dispose();
    focusPeso.dispose();
    focusAtividadeFisica.dispose();
  }
}
