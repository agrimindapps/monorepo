// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../constants/macronutrientes_constants.dart';
import '../model/macronutrientes_model.dart';
import '../services/macronutrientes_calculation_service.dart';
import '../services/macronutrientes_ui_service.dart';
import '../services/macronutrientes_validation_service.dart';

class MacronutrientesController extends ChangeNotifier {
  final MacronutrientesModel model;
  final MacronutrientesCalculationService _calculationService =
      MacronutrientesCalculationService();

  MacronutrientesController(this.model);

  // Método para calcular a distribuição de macronutrientes
  void calcular(BuildContext context) {
    // Validação de campos vazios
    if (model.caloriasDiariasController.text.isEmpty) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Necessário informar as calorias diárias.');
      model.focusCalorias.requestFocus();
      return;
    }

    if (model.carboidratosController.text.isEmpty ||
        model.proteinasController.text.isEmpty ||
        model.gordurasController.text.isEmpty) {
      MacronutrientesUIService.exibirMensagem(context,
          'Necessário informar as porcentagens de todos os macronutrientes.');
      return;
    }

    // Parsing seguro para calorias diárias
    try {
      double calorias =
          MacronutrientesValidationService.parseDoubleWithValidation(
        model.caloriasDiariasController.text,
        MacronutrientesConstants.caloriasMin,
        MacronutrientesConstants.caloriasMax,
        'Calorias devem estar entre ${MacronutrientesConstants.caloriasMin} e ${MacronutrientesConstants.caloriasMax}',
      );
      model.caloriasDiarias = calorias;
    } catch (e) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Calorias inválidas: ${e.toString()}');
      model.focusCalorias.requestFocus();
      return;
    }

    // Parsing seguro para carboidratos
    try {
      int carbsPorcentagem =
          MacronutrientesValidationService.parseIntWithValidation(
        model.carboidratosController.text,
        MacronutrientesConstants.porcentagemMin,
        MacronutrientesConstants.porcentagemMax,
        'Porcentagem de carboidratos deve estar entre ${MacronutrientesConstants.porcentagemMin} e ${MacronutrientesConstants.porcentagemMax}',
      );
      model.carboidratosPorcentagem = carbsPorcentagem;
    } catch (e) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Porcentagem de carboidratos inválida: ${e.toString()}');
      return;
    }

    // Parsing seguro para proteínas
    try {
      int proteinPorcentagem =
          MacronutrientesValidationService.parseIntWithValidation(
        model.proteinasController.text,
        MacronutrientesConstants.porcentagemMin,
        MacronutrientesConstants.porcentagemMax,
        'Porcentagem de proteínas deve estar entre ${MacronutrientesConstants.porcentagemMin} e ${MacronutrientesConstants.porcentagemMax}',
      );
      model.proteinasPorcentagem = proteinPorcentagem;
    } catch (e) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Porcentagem de proteínas inválida: ${e.toString()}');
      return;
    }

    // Parsing seguro para gorduras
    try {
      int fatPorcentagem =
          MacronutrientesValidationService.parseIntWithValidation(
        model.gordurasController.text,
        MacronutrientesConstants.porcentagemMin,
        MacronutrientesConstants.porcentagemMax,
        'Porcentagem de gorduras deve estar entre ${MacronutrientesConstants.porcentagemMin} e ${MacronutrientesConstants.porcentagemMax}',
      );
      model.gordurasPorcentagem = fatPorcentagem;
    } catch (e) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Porcentagem de gorduras inválida: ${e.toString()}');
      return;
    }

    // Verificar se a soma das porcentagens é 100
    int somaPercentuais = model.carboidratosPorcentagem +
        model.proteinasPorcentagem +
        model.gordurasPorcentagem;

    if (somaPercentuais != 100) {
      MacronutrientesUIService.exibirMensagem(context,
          'A soma das porcentagens deve ser igual a 100%. Atual: $somaPercentuais%');
      return;
    }

    try {
      // Usar o serviço de cálculo para processar a distribuição
      _calculationService.calcularDistribuicao(model);

      model.calculado = true;
      MacronutrientesUIService.exibirMensagem(
          context, 'Cálculo realizado com sucesso!',
          isError: false);

      // Notificar listeners que o estado foi alterado
      notifyListeners();
    } catch (e) {
      MacronutrientesUIService.exibirMensagem(
          context, 'Erro ao realizar cálculos: ${e.toString()}');
      model.calculado = false;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void limpar() {
    model.calculado = false;
    model.caloriasDiarias = 0;
    model.carboidratosPorcentagem = 50;
    model.proteinasPorcentagem = 25;
    model.gordurasPorcentagem = 25;

    model.carboidratosGramas = 0;
    model.proteinasGramas = 0;
    model.gordurasGramas = 0;

    model.carboidratosCalorias = 0;
    model.proteinasCalorias = 0;
    model.gordurasCalorias = 0;

    model.caloriasDiariasController.clear();
    model.carboidratosController.text = '50';
    model.proteinasController.text = '25';
    model.gordurasController.text = '25';

    model.unfocusNode.requestFocus();

    // Notificar listeners que o estado foi alterado
    notifyListeners();
  }

  void aplicarDistribuicaoPredefinida(int id) {
    final distribuicao =
        MacronutrientesConstants.distribuicoesPredefinidas.firstWhere(
      (d) => d['id'] == id,
      orElse: () => MacronutrientesConstants
          .distribuicoesPredefinidas[2], // Equilibrado como padrão
    );

    model.carboidratosController.text = distribuicao['carbs'].toString();
    model.proteinasController.text = distribuicao['protein'].toString();
    model.gordurasController.text = distribuicao['fat'].toString();

    model.carboidratosPorcentagem = distribuicao['carbs'];
    model.proteinasPorcentagem = distribuicao['protein'];
    model.gordurasPorcentagem = distribuicao['fat'];

    // Notificar listeners que o estado foi alterado
    notifyListeners();
  }

  void compartilhar() {
    StringBuffer texto = StringBuffer();

    texto.writeln('Distribuição de Macronutrientes');
    texto.writeln();
    texto.writeln(
        'Meta Calórica Diária: ${model.caloriasDiarias.toStringAsFixed(0)} kcal');
    texto.writeln();
    texto.writeln('Distribuição Percentual:');
    texto.writeln('Carboidratos: ${model.carboidratosPorcentagem}%');
    texto.writeln('Proteínas: ${model.proteinasPorcentagem}%');
    texto.writeln('Gorduras: ${model.gordurasPorcentagem}%');
    texto.writeln();
    texto.writeln('Em Calorias:');
    texto.writeln(
        'Carboidratos: ${model.carboidratosCalorias.toStringAsFixed(0)} kcal');
    texto.writeln(
        'Proteínas: ${model.proteinasCalorias.toStringAsFixed(0)} kcal');
    texto
        .writeln('Gorduras: ${model.gordurasCalorias.toStringAsFixed(0)} kcal');
    texto.writeln();
    texto.writeln('Em Gramas:');
    texto.writeln(
        'Carboidratos: ${model.carboidratosGramas.toStringAsFixed(1)}g');
    texto.writeln('Proteínas: ${model.proteinasGramas.toStringAsFixed(1)}g');
    texto.writeln('Gorduras: ${model.gordurasGramas.toStringAsFixed(1)}g');

    Share.share(texto.toString());
  }

  int getSomaPorcentagens() {
    int carbs = int.tryParse(model.carboidratosController.text) ?? 0;
    int protein = int.tryParse(model.proteinasController.text) ?? 0;
    int fat = int.tryParse(model.gordurasController.text) ?? 0;

    return carbs + protein + fat;
  }
}
