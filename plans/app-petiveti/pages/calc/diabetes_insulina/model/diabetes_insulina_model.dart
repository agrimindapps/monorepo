// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo para a calculadora de diabetes e insulina
class DiabetesInsulinaModel {
  // Controladores de texto
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController glicemiaController = TextEditingController();
  final TextEditingController dosagemAnteriorController =
      TextEditingController();
  final TextEditingController dosagemInsulinaController =
      TextEditingController();

  // Estado do formulário
  String? especieSelecionada;
  String? tipoInsulinaSelecionada;
  double? resultado;
  String? recomendacao;
  bool usarRegra = false;
  bool temDoseAnterior = false;
  bool showInfoCard = true;

  // Opções para os dropdowns
  final List<String> especies = ['Cão', 'Gato'];
  final List<String> tiposInsulina = [
    'NPH',
    'Lenta/Glargina',
    'PZI',
    'Regular'
  ];

  // Fator de correção para cada tipo de insulina (unidades por kg por aplicação)
  final Map<String, double> fatoresInsulinaPorKg = {
    'Cão': 0.5, // 0.5 U/kg como ponto de partida para cães
    'Gato': 0.25, // 0.25 U/kg como ponto de partida para gatos
  };

  // Duração aproximada das insulinas (em horas)
  final Map<String, int> duracaoInsulina = {
    'NPH': 12,
    'Lenta/Glargina': 24,
    'PZI': 24,
    'Regular': 6,
  };

  // Limpar todos os campos e resultados
  void limpar() {
    pesoController.clear();
    glicemiaController.clear();
    dosagemAnteriorController.clear();
    dosagemInsulinaController.clear();
    especieSelecionada = null;
    tipoInsulinaSelecionada = null;
    resultado = null;
    recomendacao = null;
    usarRegra = false;
    temDoseAnterior = false;
  }

  // Liberar recursos ao descartar o modelo
  void dispose() {
    pesoController.dispose();
    glicemiaController.dispose();
    dosagemAnteriorController.dispose();
    dosagemInsulinaController.dispose();
  }
}
