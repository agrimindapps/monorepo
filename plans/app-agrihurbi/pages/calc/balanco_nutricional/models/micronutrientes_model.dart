// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo de dados para o cálculo de micronutrientes
class MicronutrientesModel {
  // Controllers for text fields
  final teorZincoController = TextEditingController();
  final teorBoroController = TextEditingController();
  final teorCobreController = TextEditingController();
  final teorManganesController = TextEditingController();
  final teorFerroController = TextEditingController();
  final areaPlantadaController = TextEditingController();
  final culturaController = TextEditingController();

  // Focus nodes for text fields
  final focusZinco = FocusNode();
  final focusBoro = FocusNode();
  final focusCobre = FocusNode();
  final focusManganes = FocusNode();
  final focusFerro = FocusNode();
  final focusArea = FocusNode();
  final focusCultura = FocusNode();

  // State variables
  double teorZinco = 0;
  double teorBoro = 0;
  double teorCobre = 0;
  double teorManganes = 0;
  double teorFerro = 0;
  double areaPlantada = 0;
  String culturaSelecionada = 'Soja';
  bool calculado = false;

  // Resultados
  double necessidadeZinco = 0;
  double necessidadeBoro = 0;
  double necessidadeCobre = 0;
  double necessidadeManganes = 0;
  double necessidadeFerro = 0;
  double totalZinco = 0;
  double totalBoro = 0;
  double totalCobre = 0;
  double totalManganes = 0;
  double totalFerro = 0;

  // Lista de culturas disponíveis
  static final List<String> culturas = [
    'Soja',
    'Milho',
    'Feijão',
    'Algodão',
    'Café',
    'Trigo',
    'Cana-de-açúcar'
  ];

  // Níveis críticos de micronutrientes por cultura (mg/dm³)
  static final Map<String, Map<String, num>> niveisCriticos = {
    'Soja': {
      'zinco': 1.0,
      'boro': 0.3,
      'cobre': 0.8,
      'manganes': 5.0,
      'ferro': 12.0,
    },
    'Milho': {
      'zinco': 1.5,
      'boro': 0.5,
      'cobre': 1.0,
      'manganes': 6.0,
      'ferro': 15.0,
    },
    'Feijão': {
      'zinco': 1.2,
      'boro': 0.4,
      'cobre': 0.8,
      'manganes': 5.0,
      'ferro': 12.0,
    },
    'Algodão': {
      'zinco': 1.5,
      'boro': 0.8,
      'cobre': 1.0,
      'manganes': 8.0,
      'ferro': 15.0,
    },
    'Café': {
      'zinco': 2.0,
      'boro': 0.6,
      'cobre': 1.2,
      'manganes': 10.0,
      'ferro': 20.0,
    },
    'Trigo': {
      'zinco': 1.0,
      'boro': 0.3,
      'cobre': 0.8,
      'manganes': 5.0,
      'ferro': 10.0,
    },
    'Cana-de-açúcar': {
      'zinco': 1.5,
      'boro': 0.6,
      'cobre': 1.0,
      'manganes': 6.0,
      'ferro': 15.0,
    },
  };

  void calcular() {
    final niveisAtuais = niveisCriticos[culturaSelecionada]!;

    // Calcula a necessidade por hectare baseado na diferença entre o nível crítico e o teor atual
    necessidadeZinco = _calcularNecessidade(teorZinco, niveisAtuais['zinco']!);
    necessidadeBoro = _calcularNecessidade(teorBoro, niveisAtuais['boro']!);
    necessidadeCobre = _calcularNecessidade(teorCobre, niveisAtuais['cobre']!);
    necessidadeManganes =
        _calcularNecessidade(teorManganes, niveisAtuais['manganes']!);
    necessidadeFerro = _calcularNecessidade(teorFerro, niveisAtuais['ferro']!);

    // Calcula o total para a área
    totalZinco = necessidadeZinco * areaPlantada;
    totalBoro = necessidadeBoro * areaPlantada;
    totalCobre = necessidadeCobre * areaPlantada;
    totalManganes = necessidadeManganes * areaPlantada;
    totalFerro = necessidadeFerro * areaPlantada;
  }

  double _calcularNecessidade(double teorAtual, num nivelCritico) {
    final diferenca = nivelCritico - teorAtual;
    // Se o teor atual já é suficiente, não há necessidade de aplicação
    return diferenca > 0 ? diferenca : 0;
  }

  void limpar() {
    teorZinco = 0;
    teorBoro = 0;
    teorCobre = 0;
    teorManganes = 0;
    teorFerro = 0;
    areaPlantada = 0;
    necessidadeZinco = 0;
    necessidadeBoro = 0;
    necessidadeCobre = 0;
    necessidadeManganes = 0;
    necessidadeFerro = 0;
    totalZinco = 0;
    totalBoro = 0;
    totalCobre = 0;
    totalManganes = 0;
    totalFerro = 0;
    calculado = false;

    teorZincoController.clear();
    teorBoroController.clear();
    teorCobreController.clear();
    teorManganesController.clear();
    teorFerroController.clear();
    areaPlantadaController.clear();
  }

  void dispose() {
    teorZincoController.dispose();
    teorBoroController.dispose();
    teorCobreController.dispose();
    teorManganesController.dispose();
    teorFerroController.dispose();
    areaPlantadaController.dispose();
    culturaController.dispose();
    focusZinco.dispose();
    focusBoro.dispose();
    focusCobre.dispose();
    focusManganes.dispose();
    focusFerro.dispose();
    focusArea.dispose();
    focusCultura.dispose();
  }

  String gerarTextoCompartilhamento() {
    return '''
    Necessidade de Micronutrientes

    Cultura: $culturaSelecionada
    
    Valores no solo:
    Teor de Zinco: $teorZinco mg/dm³
    Teor de Boro: $teorBoro mg/dm³
    Teor de Cobre: $teorCobre mg/dm³
    Teor de Manganês: $teorManganes mg/dm³
    Teor de Ferro: $teorFerro mg/dm³
    Área plantada: $areaPlantada ha

    Resultados por hectare:
    Necessidade de Zinco: $necessidadeZinco kg/ha
    Necessidade de Boro: $necessidadeBoro kg/ha
    Necessidade de Cobre: $necessidadeCobre kg/ha
    Necessidade de Manganês: $necessidadeManganes kg/ha
    Necessidade de Ferro: $necessidadeFerro kg/ha

    Total para a área:
    Zinco: $totalZinco kg
    Boro: $totalBoro kg
    Cobre: $totalCobre kg
    Manganês: $totalManganes kg
    Ferro: $totalFerro kg
    ''';
  }
}
