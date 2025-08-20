// Project imports:
import 'rendimento_model.dart';

class LeguminosaModel extends RendimentoModel {
  double pesoPorVagem;
  int vagensPlanta;
  double plantas;
  double areaHectare;

  LeguminosaModel({
    required super.titulo,
    required super.descricao,
    required this.pesoPorVagem,
    required this.vagensPlanta,
    required this.plantas,
    required this.areaHectare,
  });

  @override
  double calcularRendimento() {
    // Implementar cálculo específico para leguminosas
    double rendimentoPorPlanta = pesoPorVagem * vagensPlanta;
    double rendimentoTotal = rendimentoPorPlanta * plantas * areaHectare;
    return rendimentoTotal;
  }
}
