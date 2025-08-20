// Project imports:
import 'rendimento_model.dart';

class GraoModel extends RendimentoModel {
  double pesoMedio;
  int numeroGraos;
  double areaPlantada;
  double densidade;

  GraoModel({
    required super.titulo,
    required super.descricao,
    required this.pesoMedio,
    required this.numeroGraos,
    required this.areaPlantada,
    required this.densidade,
  });

  @override
  double calcularRendimento() {
    // Implementar cálculo específico para grãos
    double rendimentoPorPlanta = pesoMedio * numeroGraos;
    double rendimentoTotal = rendimentoPorPlanta * densidade * areaPlantada;
    return rendimentoTotal;
  }
}
