// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/gasto_energetico_model.dart';

class GastoEnergeticoController extends ChangeNotifier {
  final model = GastoEnergeticoModel();
  final numberFormat = NumberFormat('#,###', 'pt_BR');

  // Text Controllers
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  final idadeController = TextEditingController();

  // Controllers de tempo para cada atividade
  final dormirController = TextEditingController(text: '8.0');
  final deitadoController = TextEditingController(text: '1.0');
  final sentadoController = TextEditingController(text: '8.0');
  final emPeController = TextEditingController(text: '4.0');
  final caminhandoController = TextEditingController(text: '2.0');
  final exercicioController = TextEditingController(text: '1.0');

  // Focus Nodes
  final focusPeso = FocusNode();
  final focusAltura = FocusNode();
  final focusIdade = FocusNode();

  // Lista de gêneros
  final List<Map<String, dynamic>> generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];

  // Método para calcular o gasto energético
  String? calcular(BuildContext context) {
    // Validações
    if (pesoController.text.isEmpty) {
      focusPeso.requestFocus();
      return 'Necessário informar o peso.';
    }

    if (alturaController.text.isEmpty) {
      focusAltura.requestFocus();
      return 'Necessário informar a altura.';
    }

    if (idadeController.text.isEmpty) {
      focusIdade.requestFocus();
      return 'Necessário informar a idade.';
    }

    // Validar total de horas
    double totalHoras = calcularTotalHoras();
    if (totalHoras < 22 || totalHoras > 26) {
      return 'O total de horas deve ser aproximadamente 24 (entre 22 e 26 horas).';
    }

    // Atualizar modelo com dados do formulário
    model.peso = double.parse(pesoController.text.replaceAll(',', '.'));
    model.altura = double.parse(alturaController.text);
    model.idade = int.parse(idadeController.text);

    // Calcular TMB
    model.calcularTMB();

    // Calcular gastos por atividade
    model.gastoTotal = 0;
    model.gastosPorAtividade.clear();

    _calcularAtividade('Dormindo', 'dormir', dormirController);
    _calcularAtividade('Deitado Acordado', 'deitado', deitadoController);
    _calcularAtividade('Sentado', 'sentado', sentadoController);
    _calcularAtividade('Em Pé / Atividades Leves', 'emPe', emPeController);
    _calcularAtividade('Caminhando', 'caminhando', caminhandoController);
    _calcularAtividade('Exercício Intenso', 'exercicio', exercicioController);

    model.gastoTotal = double.parse(model.gastoTotal.toStringAsFixed(0));
    model.calculado = true;

    notifyListeners();
    return null;
  }

  void _calcularAtividade(
      String nome, String atividade, TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      double horas = double.parse(controller.text.replaceAll(',', '.'));
      model.calcularGastoAtividade(nome, atividade, horas);
    }
  }

  double calcularTotalHoras() {
    double total = 0;
    final controllers = [
      dormirController,
      deitadoController,
      sentadoController,
      emPeController,
      caminhandoController,
      exercicioController
    ];

    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        total += double.parse(controller.text.replaceAll(',', '.'));
      }
    }

    return total;
  }

  void limpar() {
    model.limpar();
    pesoController.clear();
    alturaController.clear();
    idadeController.clear();

    dormirController.text = '8.0';
    deitadoController.text = '1.0';
    sentadoController.text = '8.0';
    emPeController.text = '4.0';
    caminhandoController.text = '2.0';
    exercicioController.text = '1.0';

    notifyListeners();
  }

  String gerarTextoCompartilhamento() {
    StringBuffer t = StringBuffer();
    t.writeln('Gasto Energético Total (GET)');
    t.writeln();
    t.writeln('Dados Pessoais');
    t.writeln(
        'Gênero: ${model.generoSelecionado == 1 ? 'Masculino' : 'Feminino'}');
    t.writeln('Idade: ${model.idade} anos');
    t.writeln('Altura: ${model.altura} cm');
    t.writeln('Peso: ${model.peso} kg');
    t.writeln();
    t.writeln('Resultados');
    t.writeln(
        'Taxa Metabólica Basal (TMB): ${numberFormat.format(model.tmb)} calorias/dia');
    t.writeln(
        'Gasto Energético Total: ${numberFormat.format(model.gastoTotal)} calorias/dia');
    t.writeln();
    t.writeln('Detalhamento por Atividade:');
    model.gastosPorAtividade.forEach((atividade, gasto) {
      t.writeln('$atividade: ${numberFormat.format(gasto)} calorias');
    });
    return t.toString();
  }

  void setGenero(int value) {
    model.generoSelecionado = value;
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose dos controllers
    pesoController.dispose();
    alturaController.dispose();
    idadeController.dispose();
    dormirController.dispose();
    deitadoController.dispose();
    sentadoController.dispose();
    emPeController.dispose();
    caminhandoController.dispose();
    exercicioController.dispose();

    // Dispose dos focus nodes
    focusPeso.dispose();
    focusAltura.dispose();
    focusIdade.dispose();

    super.dispose();
  }
}
