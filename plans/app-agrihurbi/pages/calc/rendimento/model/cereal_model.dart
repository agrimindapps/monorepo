// Project imports:
import 'rendimento_model.dart';

class CerealModel extends RendimentoModel {
  double pesoHectolitrico;
  double impurezas;
  double umidade;
  double hectares;

  CerealModel({
    required super.titulo,
    required super.descricao,
    required this.pesoHectolitrico,
    required this.impurezas,
    required this.umidade,
    required this.hectares,
  });

  @override
  double calcularRendimento() {
    // Implementar cálculo específico para cereais
    double rendimentoBase = pesoHectolitrico * (1 - (impurezas / 100));
    double rendimentoFinal = rendimentoBase * (1 - (umidade / 100)) * hectares;
    return rendimentoFinal;
  }
}
