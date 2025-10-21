// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../gasto_energetico_utils.dart';
import '../model/gasto_energetico_model.dart';

class GastoEnergeticoController extends ChangeNotifier {
  // Controllers
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  final idadeController = TextEditingController();

  // Focus nodes
  final focusPeso = FocusNode();
  final focusAltura = FocusNode();
  final focusIdade = FocusNode();

  int generoSelecionado = 1;
  bool calculado = false;
  late GastoEnergeticoModel modelo;

  // Controllers para as horas de cada atividade
  late Map<String, TextEditingController> horasControllers;

  GastoEnergeticoController() {
    modelo = GastoEnergeticoModel.empty();
    horasControllers = {
      'dormir': TextEditingController(text: '8,0'),
      'deitado': TextEditingController(text: '1,0'),
      'sentado': TextEditingController(text: '8,0'),
      'emPe': TextEditingController(text: '4,0'),
      'caminhando': TextEditingController(text: '2,0'),
      'exercicio': TextEditingController(text: '1,0'),
    };
  }

  void disposeAll() {
    pesoController.dispose();
    alturaController.dispose();
    idadeController.dispose();
    focusPeso.dispose();
    focusAltura.dispose();
    focusIdade.dispose();
    horasControllers.forEach((_, controller) => controller.dispose());
  }

  void atualizarGenero(int genero) {
    generoSelecionado = genero;
    notifyListeners();
  }

  void limpar() {
    generoSelecionado = 1;
    pesoController.clear();
    alturaController.clear();
    idadeController.clear();
    horasControllers['dormir']?.text = '8,0';
    horasControllers['deitado']?.text = '1,0';
    horasControllers['sentado']?.text = '8,0';
    horasControllers['emPe']?.text = '4,0';
    horasControllers['caminhando']?.text = '2,0';
    horasControllers['exercicio']?.text = '1,0';
    modelo = GastoEnergeticoModel.empty();
    calculado = false;
    notifyListeners();
  }

  String? calcular() {
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
    Map<String, double> horasPorAtividade = {};
    bool temHorasVazias = false;
    horasControllers.forEach((key, controller) {
      if (controller.text.isEmpty) {
        temHorasVazias = true;
      } else {
        horasPorAtividade[key] =
            double.parse(controller.text.replaceAll(',', '.'));
      }
    });
    if (temHorasVazias) {
      return 'Informe as horas para todas as atividades.';
    }
    if (!GastoEnergeticoUtils.verificarTotalHoras(horasPorAtividade)) {
      final totalHoras =
          GastoEnergeticoUtils.calcularTotalHoras(horasPorAtividade);
      return 'O total de horas (${totalHoras.toStringAsFixed(1)}) deve ser aproximadamente 24 horas.';
    }
    final peso = double.parse(pesoController.text.replaceAll(',', '.'));
    final altura = double.parse(alturaController.text);
    final idade = int.parse(idadeController.text);
    final tmb = GastoEnergeticoUtils.calcularTMB(
        peso, altura, idade, generoSelecionado);
    final tmbPorHora = tmb / 24;
    Map<String, double> gastosPorAtividade = {};
    double gastoTotal = 0;
    horasPorAtividade.forEach((atividade, horas) {
      final gastoAtividade = GastoEnergeticoUtils.calcularGastoAtividade(
          atividade, horas, tmbPorHora);
      gastosPorAtividade[atividade] = gastoAtividade;
      gastoTotal += gastoAtividade;
    });
    modelo = GastoEnergeticoModel(
      generoSelecionado: generoSelecionado,
      peso: peso,
      altura: altura,
      idade: idade,
      tmb: tmb,
      gastoTotal: gastoTotal,
      gastosPorAtividade: gastosPorAtividade,
    );
    calculado = true;
    notifyListeners();
    return null;
  }
}
