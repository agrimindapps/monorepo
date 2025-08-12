// Flutter imports:
import 'package:flutter/material.dart';

class GestacaoModel {
  // Controladores de texto
  final TextEditingController especieController = TextEditingController();
  final TextEditingController dataInicioController = TextEditingController();

  // Dados da gestação
  DateTime? dataInicio;
  DateTime? dataParto;
  int? diasGestacao;
  String? resultado;

  // Estados da UI
  bool showInfoCard = true;
  bool calculado = false;

  // Períodos de gestação para diferentes espécies (em dias)
  static final Map<String, int> periodosGestacao = {
    'Cadela': 63,
    'Gata': 65,
    'Vaca': 280,
    'Égua': 340,
    'Ovelha': 150,
    'Cabra': 150,
    'Porca': 114,
  };

  void limpar() {
    especieController.clear();
    dataInicioController.clear();
    dataInicio = null;
    dataParto = null;
    diasGestacao = null;
    resultado = null;
    calculado = false;
  }

  void dispose() {
    especieController.dispose();
    dataInicioController.dispose();
  }
}
