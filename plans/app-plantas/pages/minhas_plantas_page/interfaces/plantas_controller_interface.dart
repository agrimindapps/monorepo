// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_model.dart';

/// Interface que define os métodos essenciais que um controller de plantas deve ter
/// Permite que MinhasPlantasController seja usado nos widgets existentes
/// sem depender da herança problemática de PlantasController
abstract class IPlantasController {
  // Getters reativos obrigatórios
  Rx<List<PlantaModel>> get plantas;
  Rx<List<PlantaModel>> get plantasComTarefas;
  Rx<List<EspacoModel>> get espacos;
  RxBool get isLoading;
  RxString get searchText;

  // Métodos essenciais para widgets
  String getNomeEspaco(String? espacoId);
  PlantaModel? getPlanta(String plantaId);
  Future<List<Map<String, dynamic>>> getTarefasPendentes(String plantaId);

  // Métodos de controle
  Future<void> forcarRecarregamento();
  void filtrarPlantas();
  void limparBusca();
}
