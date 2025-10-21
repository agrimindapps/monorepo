// Project imports:
import '../model/atividade_fisica_model.dart';

class AtividadeFisicaRepository {
  List<AtividadeFisicaModel> obterTodasAtividades() {
    return [
      AtividadeFisicaModel(
          id: 1, text: 'Caminhada leve (3-4 km/h)', value: 3.5),
      AtividadeFisicaModel(
          id: 2, text: 'Caminhada rápida (5-6 km/h)', value: 5.5),
      AtividadeFisicaModel(
          id: 3, text: 'Corrida moderada (8-10 km/h)', value: 11.0),
      AtividadeFisicaModel(
          id: 4, text: 'Corrida intensa (12-14 km/h)', value: 15.0),
      AtividadeFisicaModel(id: 5, text: 'Ciclismo leve', value: 6.0),
      AtividadeFisicaModel(id: 6, text: 'Ciclismo intenso', value: 13.0),
      AtividadeFisicaModel(id: 7, text: 'Natação moderada', value: 9.0),
      AtividadeFisicaModel(id: 8, text: 'Musculação', value: 7.0),
    ];
  }

  List<Map<String, dynamic>> obterTodasAtividadesComoMap() {
    return obterTodasAtividades().map((e) => e.toMap()).toList();
  }
}
