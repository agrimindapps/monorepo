// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/quebra_dormencia_model.dart';
import '../repositories/quebra_dormencia_repository.dart';

class QuebraDormenciaController {
  final model = QuebraDormenciaModel();

  // Controllers
  final horasFrioController = TextEditingController();
  final especieController = TextEditingController();
  final variedadeController = TextEditingController();
  final areaPomarController = TextEditingController();
  final numeroArvoresController = TextEditingController();
  final idadePomarController = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();
  final focus6 = FocusNode();

  // Formatters
  final numberFormat = NumberFormat('#,##0.0', 'pt_BR');
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  void dispose() {
    horasFrioController.dispose();
    especieController.dispose();
    variedadeController.dispose();
    areaPomarController.dispose();
    numeroArvoresController.dispose();
    idadePomarController.dispose();

    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    focus5.dispose();
    focus6.dispose();
  }

  void atualizarVariedades() {
    final variedades = QuebraDormenciaRepository.getVariedades(model.especie);
    model.variedade = variedades.first;
    variedadeController.text = model.variedade;
  }

  bool validarCampos(BuildContext context) {
    if (horasFrioController.text.isEmpty) {
      focus1.requestFocus();
      _mostrarMensagem(
          context, 'Necessário informar as horas de frio acumuladas');
      return false;
    }

    if (areaPomarController.text.isEmpty) {
      focus4.requestFocus();
      _mostrarMensagem(context, 'Necessário informar a área do pomar');
      return false;
    }

    return true;
  }

  void calcular(BuildContext context) {
    if (!validarCampos(context)) return;

    model.horasFrio = num.parse(horasFrioController.text.replaceAll(',', '.'));
    model.areaPomar = num.parse(areaPomarController.text.replaceAll(',', '.'));

    if (numeroArvoresController.text.isNotEmpty) {
      model.numeroArvores =
          num.parse(numeroArvoresController.text.replaceAll(',', '.'));
    }

    if (idadePomarController.text.isNotEmpty) {
      model.idadePomar =
          num.parse(idadePomarController.text.replaceAll(',', '.'));
    }

    // Obter requisito de horas de frio para a espécie/variedade selecionada
    final requisitoHF = QuebraDormenciaRepository.getRequisitoHorasFrio(
      model.especie,
      model.variedade,
    );

    // Calcular o déficit de horas de frio
    model.deficitHorasFrio =
        requisitoHF > model.horasFrio ? requisitoHF - model.horasFrio : 0;

    // Obter recomendações para o nível de déficit
    final recomendacao =
        QuebraDormenciaRepository.getRecomendacao(model.deficitHorasFrio);
    model.recomendacaoPrincipal = recomendacao['recomendacao'] as String;
    model.dosagensProdutos =
        Map<String, String>.from(recomendacao['produtos'] as Map);

    // Calcular custos
    model.custoEstimadoPorHectare = recomendacao['custoEstimado'] as num;
    model.custoTotal = model.custoEstimadoPorHectare * model.areaPomar;

    model.calculado = true;

    // Exibir mensagem de sucesso
    _mostrarMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    model.calculado = false;
    horasFrioController.clear();
    areaPomarController.clear();
    numeroArvoresController.clear();
    idadePomarController.clear();
  }

  void _mostrarMensagem(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: isError ? Colors.red : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  String compartilharTexto() {
    return '''
    Quebra de Dormência - Fruticultura

    Espécie: ${model.especie}
    Variedade: ${model.variedade}
    
    Valores de Entrada:
    Horas de frio acumuladas: ${numberFormat.format(model.horasFrio)} horas
    Área do pomar: ${numberFormat.format(model.areaPomar)} ha
    ${model.numeroArvores > 0 ? 'Número de árvores: ${numberFormat.format(model.numeroArvores)}' : ''}
    ${model.idadePomar > 0 ? 'Idade do pomar: ${numberFormat.format(model.idadePomar)} anos' : ''}

    Resultados:
    Déficit de horas de frio: ${numberFormat.format(model.deficitHorasFrio)} horas
    Recomendação: ${model.recomendacaoPrincipal}
    
    Produtos e dosagens recomendadas:
    ${model.dosagensProdutos.entries.map((e) => '${e.key}: ${e.value}').join('\n    ')}
    
    Custo estimado por hectare: ${currencyFormat.format(model.custoEstimadoPorHectare)}
    Custo total estimado: ${currencyFormat.format(model.custoTotal)}
    ''';
  }

  Color getDeficitColor(bool isDark) {
    if (model.deficitHorasFrio < 100) {
      return isDark ? Colors.green.shade300 : Colors.green;
    }
    if (model.deficitHorasFrio < 300) {
      return isDark ? Colors.orange.shade300 : Colors.orange;
    }
    return isDark ? Colors.red.shade300 : Colors.red;
  }
}
