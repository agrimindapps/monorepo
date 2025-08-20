// Flutter imports:
import 'package:flutter/material.dart';

class DosagemMedicamentosModel {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController dosagemController = TextEditingController();
  final TextEditingController concentracaoController = TextEditingController();

  double? resultado;
  String? medicamentoSelecionado;
  bool showInfoCard = true;
  bool showAlertaCard = true;
  String unidadeResultado = 'ml';

  // Lista de medicamentos comuns para pets com suas dosagens recomendadas (mg/kg)
  final Map<String, List<double>> medicamentos = {
    'Amoxicilina': [10.0, 20.0],
    'Cefalexina': [15.0, 30.0],
    'Metronidazol': [10.0, 25.0],
    'Dipirona': [25.0, 50.0],
    'Meloxicam': [0.1, 0.2],
    'Prednisolona': [0.5, 2.0],
    'Tramadol': [2.0, 5.0],
    'Doxiciclina': [5.0, 10.0],
    'Ivermectina': [0.2, 0.4],
    'Enrofloxacina': [2.5, 5.0],
  };

  void limpar() {
    pesoController.clear();
    dosagemController.clear();
    concentracaoController.clear();
    medicamentoSelecionado = null;
    resultado = null;
  }

  void dispose() {
    pesoController.dispose();
    dosagemController.dispose();
    concentracaoController.dispose();
  }
}
