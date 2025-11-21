import 'package:flutter/material.dart';

/// Serviço responsável por gerenciar TextEditingControllers
///
/// Centraliza criação, listeners e dispose de controllers,
/// seguindo o princípio Single Responsibility.

class ExpenseFormControllersManager {
  ExpenseFormControllersManager() {
    _initializeControllers();
  }

  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  late final TextEditingController odometerController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;

  final Map<String, VoidCallback> _listeners = {};

  /// Inicializa todos os controllers
  void _initializeControllers() {
    descriptionController = TextEditingController();
    amountController = TextEditingController();
    odometerController = TextEditingController();
    locationController = TextEditingController();
    notesController = TextEditingController();
  }

  /// Adiciona listener a um controller
  void addListener(String controllerName, VoidCallback listener) {
    final controller = _getController(controllerName);
    if (controller != null) {
      controller.addListener(listener);
      _listeners[controllerName] = listener;
    }
  }

  /// Remove listener de um controller
  void removeListener(String controllerName) {
    final controller = _getController(controllerName);
    final listener = _listeners[controllerName];

    if (controller != null && listener != null) {
      controller.removeListener(listener);
      _listeners.remove(controllerName);
    }
  }

  /// Obtém controller por nome
  TextEditingController? _getController(String name) {
    switch (name) {
      case 'description':
        return descriptionController;
      case 'amount':
        return amountController;
      case 'odometer':
        return odometerController;
      case 'location':
        return locationController;
      case 'notes':
        return notesController;
      default:
        return null;
    }
  }

  /// Define texto de um controller
  void setText(String controllerName, String text) {
    final controller = _getController(controllerName);
    if (controller != null) {
      controller.text = text;
    }
  }

  /// Obtém texto de um controller
  String getText(String controllerName) {
    final controller = _getController(controllerName);
    return controller?.text ?? '';
  }

  /// Limpa texto de um controller específico
  void clearController(String controllerName) {
    final controller = _getController(controllerName);
    controller?.clear();
  }

  /// Limpa todos os controllers
  void clearAll() {
    descriptionController.clear();
    amountController.clear();
    odometerController.clear();
    locationController.clear();
    notesController.clear();
  }

  /// Define múltiplos textos de uma vez
  void setMultipleTexts(Map<String, String> values) {
    values.forEach((controllerName, text) {
      setText(controllerName, text);
    });
  }

  /// Obtém todos os textos dos controllers
  Map<String, String> getAllTexts() {
    return {
      'description': descriptionController.text,
      'amount': amountController.text,
      'odometer': odometerController.text,
      'location': locationController.text,
      'notes': notesController.text,
    };
  }

  /// Valida se algum campo obrigatório está vazio
  bool hasEmptyRequiredFields() {
    return descriptionController.text.isEmpty || amountController.text.isEmpty;
  }

  /// Obtém lista de campos vazios obrigatórios
  List<String> getEmptyRequiredFields() {
    final empty = <String>[];

    if (descriptionController.text.isEmpty) {
      empty.add('description');
    }
    if (amountController.text.isEmpty) {
      empty.add('amount');
    }

    return empty;
  }

  /// Move foco para um controller específico
  void requestFocus(BuildContext context, String controllerName) {
    final controller = _getController(controllerName);
    if (controller != null) {
      // Remove foco atual
      FocusScope.of(context).unfocus();

      // Aguarda frame para aplicar novo foco
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final focusNode = FocusNode();
        focusNode.requestFocus();
      });
    }
  }

  /// Libera recursos dos controllers
  void dispose() {
    // Remove todos os listeners primeiro
    _listeners.forEach((name, listener) {
      final controller = _getController(name);
      controller?.removeListener(listener);
    });
    _listeners.clear();

    // Dispose dos controllers
    descriptionController.dispose();
    amountController.dispose();
    odometerController.dispose();
    locationController.dispose();
    notesController.dispose();
  }

  /// Valida formato de valor monetário
  bool isValidAmount(String text) {
    if (text.isEmpty) return false;

    // Remove símbolos de moeda e espaços
    final cleaned = text.replaceAll(RegExp(r'[R$\s]'), '');

    // Verifica se é um número válido
    final value = double.tryParse(cleaned.replaceAll(',', '.'));
    return value != null && value > 0;
  }

  /// Valida formato de odômetro
  bool isValidOdometer(String text) {
    if (text.isEmpty) return true; // Opcional

    // Remove pontos e espaços
    final cleaned = text.replaceAll(RegExp(r'[.\s]'), '');

    // Verifica se é um número inteiro válido
    final value = int.tryParse(cleaned);
    return value != null && value >= 0;
  }

  /// Formata valor monetário enquanto digita
  String formatAmount(String text) {
    if (text.isEmpty) return text;

    // Remove caracteres não numéricos
    final cleaned = text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return '';

    // Converte para double (centavos)
    final value = double.parse(cleaned) / 100;

    // Formata como moeda brasileira
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata odômetro enquanto digita
  String formatOdometer(String text) {
    if (text.isEmpty) return text;

    // Remove caracteres não numéricos
    final cleaned = text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return '';

    // Adiciona pontos de milhar
    final value = int.parse(cleaned);
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]}.',
    );
  }
}
