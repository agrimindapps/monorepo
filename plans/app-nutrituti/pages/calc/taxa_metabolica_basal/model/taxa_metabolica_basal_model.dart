// Project imports:
import '../utils/constants.dart';

class TaxaMetabolicaBasalModel {
  double peso;
  double altura;
  int idade;
  int generoSelecionado;
  int nivelAtividadeSelecionado;
  double resultadoTMB;
  double resultadoTEE;
  bool calculado;

  TaxaMetabolicaBasalModel({
    this.peso = 0,
    this.altura = 0,
    this.idade = 0,
    this.generoSelecionado = 1,
    this.nivelAtividadeSelecionado = 1,
    this.resultadoTMB = 0,
    this.resultadoTEE = 0,
    this.calculado = false,
  });

  void limpar() {
    peso = 0;
    altura = 0;
    idade = 0;
    generoSelecionado = 1;
    nivelAtividadeSelecionado = 1;
    resultadoTMB = 0;
    resultadoTEE = 0;
    calculado = false;
  }

  double get nivelAtividadeFator {
    final nivelAtividade = TMBConstants.niveisAtividade.firstWhere(
      (nivel) => nivel['id'] == nivelAtividadeSelecionado,
      orElse: () => TMBConstants.niveisAtividade[0],
    );
    return nivelAtividade['fator'];
  }

  void calcular() {
    if (generoSelecionado == 1) {
      // Masculino
      resultadoTMB = 13.397 * peso + 4.799 * altura - 5.677 * idade + 88.362;
    } else {
      // Feminino
      resultadoTMB = 9.247 * peso + 3.098 * altura - 4.330 * idade + 447.593;
    }

    resultadoTEE = resultadoTMB * nivelAtividadeFator;

    // Arredondamento para inteiros
    resultadoTMB = resultadoTMB.roundToDouble();
    resultadoTEE = resultadoTEE.roundToDouble();

    calculado = true;
  }
}
