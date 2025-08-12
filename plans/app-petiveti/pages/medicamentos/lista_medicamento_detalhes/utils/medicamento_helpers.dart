// Project imports:
import 'medicamento_constants.dart';

class MedicamentoHelpers {
  static bool temCalculadoraDosagem(String tipo) {
    return MedicamentoConstants.tiposComCalculadora.contains(tipo);
  }

  static String obterAdministracaoTipica(String tipo) {
    return MedicamentoConstants.administracaoTipica[tipo] ?? '';
  }

  static double calcularDosagem(String tipo, double peso) {
    final dosageBase = MedicamentoConstants.dosagensBase[tipo];
    if (dosageBase == null) return 0;
    return peso * dosageBase;
  }

  static String formatarResultadoDosagem(double dosagem, String unidade) {
    return 'Dosagem sugerida: ${dosagem.toStringAsFixed(1)} $unidade';
  }

  static bool isValidPeso(String pesoText) {
    final peso = double.tryParse(pesoText);
    return peso != null && peso > 0;
  }

  static String obterMensagemErroCalculo() {
    return 'Por favor, insira um peso válido.';
  }

  static String obterMensagemCalculoIndisponivel() {
    return 'Cálculo não disponível para este tipo de medicamento.';
  }

  static bool isTextScaleFactorValid(double factor) {
    return factor >= MedicamentoConstants.textScaleFactorMin &&
           factor <= MedicamentoConstants.textScaleFactorMax;
  }

  static double incrementarTextScale(double currentFactor) {
    final newFactor = currentFactor + MedicamentoConstants.textScaleFactorIncrement;
    return newFactor <= MedicamentoConstants.textScaleFactorMax 
        ? newFactor 
        : currentFactor;
  }

  static double decrementarTextScale(double currentFactor) {
    final newFactor = currentFactor - MedicamentoConstants.textScaleFactorIncrement;
    return newFactor >= MedicamentoConstants.textScaleFactorMin 
        ? newFactor 
        : currentFactor;
  }
}
