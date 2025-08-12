// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo de dados para a calculadora de conversão
class ConversaoModel {
  // Controladores
  final TextEditingController valorController = TextEditingController();
  final TextEditingController resultadoController = TextEditingController();

  // Dados
  double? resultado;
  bool calculado = false;

  // Método para limpar dados
  void limpar() {
    valorController.clear();
    resultadoController.clear();
    resultado = null;
    calculado = false;
  }

  // Método para disposição dos recursos
  void dispose() {
    valorController.dispose();
    resultadoController.dispose();
  }
}
