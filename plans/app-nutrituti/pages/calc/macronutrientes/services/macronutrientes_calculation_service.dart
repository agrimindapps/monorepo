// Project imports:
import '../constants/macronutrientes_constants.dart';
import '../model/macronutrientes_model.dart';

class MacronutrientesCalculationService {
  // Método para calcular distribuição de macronutrientes
  void calcularDistribuicao(MacronutrientesModel model) {
    // Calcular calorias para cada macronutriente
    model.carboidratosCalorias =
        model.caloriasDiarias * (model.carboidratosPorcentagem / 100);
    model.proteinasCalorias =
        model.caloriasDiarias * (model.proteinasPorcentagem / 100);
    model.gordurasCalorias =
        model.caloriasDiarias * (model.gordurasPorcentagem / 100);

    // Calcular gramas para cada macronutriente
    model.carboidratosGramas = model.carboidratosCalorias /
        MacronutrientesConstants.caloriasPorGrama['carboidratos']!;
    model.proteinasGramas = model.proteinasCalorias /
        MacronutrientesConstants.caloriasPorGrama['proteinas']!;
    model.gordurasGramas = model.gordurasCalorias /
        MacronutrientesConstants.caloriasPorGrama['gorduras']!;

    // Arredondar resultados
    model.carboidratosGramas =
        double.parse(model.carboidratosGramas.toStringAsFixed(1));
    model.proteinasGramas =
        double.parse(model.proteinasGramas.toStringAsFixed(1));
    model.gordurasGramas =
        double.parse(model.gordurasGramas.toStringAsFixed(1));

    model.carboidratosCalorias =
        double.parse(model.carboidratosCalorias.toStringAsFixed(0));
    model.proteinasCalorias =
        double.parse(model.proteinasCalorias.toStringAsFixed(0));
    model.gordurasCalorias =
        double.parse(model.gordurasCalorias.toStringAsFixed(0));
  }

  // Verificar se a soma das porcentagens é 100
  bool validarSomaPorcentagens(MacronutrientesModel model) {
    int somaPercentuais = model.carboidratosPorcentagem +
        model.proteinasPorcentagem +
        model.gordurasPorcentagem;

    return somaPercentuais == 100;
  }
}
