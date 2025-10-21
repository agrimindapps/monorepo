// Project imports:
import '../model/exercicio_model.dart';

class ExercicioRepository {
  final List<ExercicioModel> _atividades = [
    ExercicioModel(
      id: 1,
      nome: 'Caminhada leve (3-4 km/h)',
      caloriasMinuto: 3.5,
      descricao: 'Caminhada em ritmo leve',
    ),
    ExercicioModel(
      id: 2,
      nome: 'Caminhada rápida (5-6 km/h)',
      caloriasMinuto: 6.0,
      descricao: 'Caminhada em ritmo acelerado',
    ),
    ExercicioModel(
      id: 3,
      nome: 'Corrida moderada (8-10 km/h)',
      caloriasMinuto: 11.0,
      descricao: 'Corrida em ritmo moderado',
    ),
    ExercicioModel(
      id: 4,
      nome: 'Corrida intensa (12-14 km/h)',
      caloriasMinuto: 15.0,
      descricao: 'Corrida em ritmo intenso',
    ),
    ExercicioModel(
      id: 5,
      nome: 'Ciclismo leve',
      caloriasMinuto: 6.0,
      descricao: 'Ciclismo em ritmo leve',
    ),
    ExercicioModel(
      id: 6,
      nome: 'Ciclismo intenso',
      caloriasMinuto: 13.0,
      descricao: 'Ciclismo em ritmo intenso',
    ),
    ExercicioModel(
      id: 7,
      nome: 'Natação moderada',
      caloriasMinuto: 9.0,
      descricao: 'Natação em ritmo moderado',
    ),
    ExercicioModel(
      id: 8,
      nome: 'Musculação',
      caloriasMinuto: 7.0,
      descricao: 'Exercícios de musculação',
    ),
  ];

  List<ExercicioModel> obterTodasAtividades() => _atividades;

  List<Map<String, dynamic>> obterTodasAtividadesComoMap() {
    return _atividades.map((e) => e.toMap()).toList();
  }

  ExercicioModel? obterAtividadePorId(int id) {
    try {
      return _atividades.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
