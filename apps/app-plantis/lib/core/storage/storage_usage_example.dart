import 'package:core/core.dart';

import '../constants/plantis_environment_config.dart';

/// Exemplo de como usar diretamente o ILocalStorageRepository do core
/// em vez do wrapper PlantisStorageService
class StorageUsageExample {
  /// Exemplo: Salvar uma planta diretamente usando o core
  static Future<void> savePlantExample() async {
    final storage = GetIt.I<ILocalStorageRepository>();

    final plantData = {'id': 'plant-123', 'name': 'Rosa Vermelha'};

    final result = await storage.save<Map<String, dynamic>>(
      key: 'plant-123',
      data: plantData,
      box: PlantisBoxes.plants,
    );
    result.fold(
      (failure) => print('Erro ao salvar: ${failure.message}'),
      (_) => print('Planta salva com sucesso!'),
    );
  }

  /// Exemplo: Recuperar uma planta diretamente usando o core
  static Future<void> getPlantExample() async {
    final storage = GetIt.I<ILocalStorageRepository>();

    final result = await storage.get<Map<String, dynamic>>(
      key: 'plant-123',
      box: PlantisBoxes.plants,
    );
    result.fold(
      (failure) => print('Erro ao recuperar: ${failure.message}'),
      (plant) => print('Planta recuperada: ${plant?['name']}'),
    );
  }

  /// Exemplo: Listar todas as plantas usando o core
  static Future<void> listPlantsExample() async {
    final storage = GetIt.I<ILocalStorageRepository>();

    final result = await storage.getValues<Map<String, dynamic>>(
      box: PlantisBoxes.plants,
    );
    result.fold(
      (Failure failure) => print('Erro ao listar: ${failure.message}'),
      (List<Map<String, dynamic>> plants) =>
          print('${plants.length} plantas encontradas'),
    );
  }

  /// Exemplo: Deletar uma planta usando o core
  static Future<void> deletePlantExample() async {
    final storage = GetIt.I<ILocalStorageRepository>();

    final result = await storage.remove(
      key: 'plant-123',
      box: PlantisBoxes.plants,
    );
    result.fold(
      (Failure failure) => print('Erro ao deletar: ${failure.message}'),
      (_) => print('Planta deletada com sucesso!'),
    );
  }
}
