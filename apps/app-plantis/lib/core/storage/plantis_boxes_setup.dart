import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

import '../constants/plantis_environment_config.dart';

/// Setup das boxes específicas do Plantis usando diretamente o core
class PlantisBoxesSetup {
  /// Registra todas as boxes específicas do Plantis
  static Future<void> registerPlantisBoxes() async {
    final boxRegistry = GetIt.I<IBoxRegistryService>();
    
    final plantisBoxes = [
      BoxConfiguration.basic(
        name: PlantisBoxes.main,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.plants,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.spaces,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.tasks,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.reminders,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.care_logs,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.backups,
        appId: 'plantis',
      ),
    ];

    for (final config in plantisBoxes) {
      final result = await boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print('Warning: Failed to register plantis box "${config.name}": ${result.fold((f) => f.message, (_) => '')}');
      }
    }
  }
}