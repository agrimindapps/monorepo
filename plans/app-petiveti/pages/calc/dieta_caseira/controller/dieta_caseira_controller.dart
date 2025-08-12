// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/dieta_caseira_model.dart';

class DietaCaseiraController extends ChangeNotifier {
  final DietaCaseiraModel model = DietaCaseiraModel();
  final formKey = GlobalKey<FormState>();

  bool get showInfoCard => model.showInfoCard;

  void toggleInfoCard() {
    model.showInfoCard = !model.showInfoCard;
    notifyListeners();
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Digite um número válido';
    }
    return null;
  }

  String? validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'Digite um número inteiro válido';
    }
    return null;
  }

  void setEspecie(String? value) {
    model.especieSelecionada = value;
    model.estadoFisiologicoSelecionado = null;
    model.nivelAtividadeSelecionado = null;
    notifyListeners();
  }

  void setEstadoFisiologico(String? value) {
    model.estadoFisiologicoSelecionado = value;
    notifyListeners();
  }

  void setNivelAtividade(String? value) {
    model.nivelAtividadeSelecionado = value;
    notifyListeners();
  }

  void setTipoAlimentacao(String? value) {
    model.tipoAlimentacaoSelecionado = value;
    notifyListeners();
  }

  void calcular(String pesoText, String idadeAnosText, String idadeMesesText) {
    if (!formKey.currentState!.validate()) return;

    // Parse dos valores dos campos
    model.peso = double.tryParse(pesoText.replaceAll(',', '.')) ?? 0;
    model.idadeAnos = int.tryParse(idadeAnosText) ?? 0;
    model.idadeMeses = int.tryParse(idadeMesesText) ?? 0;

    _calcularNecessidadeCalorica();
    _calcularMacronutrientes();
    _calcularQuantidadesAlimentos();
    _gerarRecomendacoes();

    notifyListeners();
  }

  void limpar() {
    model.limpar();
    notifyListeners();
  }

  void _calcularNecessidadeCalorica() {
    if (model.especieSelecionada == null ||
        model.estadoFisiologicoSelecionado == null ||
        model.nivelAtividadeSelecionado == null ||
        model.peso == null) {
      return;
    }

    double rer = 70 * math.pow(model.peso!, 0.75).toDouble();
    double fatorEstado = model.fatoresEnergeticos[model.especieSelecionada!]![
        model.estadoFisiologicoSelecionado!]!;
    double fatorAtividade = model.fatoresAtividade[model.especieSelecionada!]![
        model.nivelAtividadeSelecionado!]!;

    model.necessidadeCalorica = rer * fatorEstado * fatorAtividade;
  }

  void _calcularMacronutrientes() {
    if (model.especieSelecionada == null ||
        model.tipoAlimentacaoSelecionado == null ||
        model.necessidadeCalorica == null) {
      return;
    }

    Map<String, double>? proporcoes;
    if (model.especieSelecionada == 'Cão') {
      proporcoes = model
          .proporcoesMacronutrientesCaes[model.tipoAlimentacaoSelecionado!];
    } else {
      proporcoes = model
          .proporcoesMacronutrientesGatos[model.tipoAlimentacaoSelecionado!];
    }

    if (proporcoes == null) return;

    model.macronutrientes = {
      'Proteína': (model.necessidadeCalorica! * proporcoes['Proteína']!) / 4.0,
      'Gordura': (model.necessidadeCalorica! * proporcoes['Gordura']!) / 9.0,
      'Carboidratos':
          (model.necessidadeCalorica! * proporcoes['Carboidratos']!) / 4.0,
    };
  }

  void _calcularQuantidadesAlimentos() {
    if (model.macronutrientes == null) return;

    double proteina = model.macronutrientes!['Proteína']!;
    double gordura = model.macronutrientes!['Gordura']!;
    double carboidratos = model.macronutrientes!['Carboidratos']!;

    model.quantidadesAlimentos = {
      'Frango (cozido)': (proteina * 0.5) * (100 / 25.0),
      'Carne bovina (cozida)': (proteina * 0.3) * (100 / 26.0),
      'Ovo (cozido)': (proteina * 0.2) * (100 / 13.0),
      'Óleo de coco': gordura * (100 / 99.0),
      'Arroz (cozido)': (carboidratos * 0.5) * (100 / 28.0),
      'Batata doce (cozida)': (carboidratos * 0.3) * (100 / 20.0),
      'Cenoura (cozida)': (carboidratos * 0.2) * (100 / 8.0),
    };
  }

  void _gerarRecomendacoes() {
    if (model.especieSelecionada == null ||
        model.estadoFisiologicoSelecionado == null ||
        model.tipoAlimentacaoSelecionado == null) {
      return;
    }

    Map<String, String> recomendacoes = {
      'geral':
          'Sempre consulte um médico veterinário antes de implementar qualquer dieta caseira. Esta calculadora oferece apenas estimativas educativas.'
    };

    if (model.especieSelecionada == 'Cão') {
      recomendacoes['especie'] =
          'Cães precisam de uma dieta balanceada com proteínas de alta qualidade. Considere adicionar casca de ovo moída ou suplementos de cálcio recomendados pelo veterinário.';
    } else {
      recomendacoes['especie'] =
          'Gatos são carnívoros estritos e necessitam de proteína animal de alta qualidade. A taurina é essencial e deve ser suplementada conforme orientação veterinária.';
    }

    model.recomendacoes = recomendacoes;
  }
}
