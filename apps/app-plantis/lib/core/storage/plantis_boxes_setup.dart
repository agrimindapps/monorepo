import 'package:core/core.dart';

import '../constants/plantis_environment_config.dart';

/// Setup das boxes específicas do Plantis usando diretamente o core
class PlantisBoxesSetup {
  /// Registra todas as boxes específicas do Plantis
  static Future<void> registerPlantisBoxes() async {
    final boxRegistry = GetIt.I<IBoxRegistryService>();

    final plantisBoxes = [
      BoxConfiguration.basic(name: PlantisBoxes.main, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.reminders, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.careLogs, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.backups, appId: 'plantis'),
      BoxConfiguration.basic(name: 'plants', appId: 'plantis'),
      BoxConfiguration.basic(name: 'spaces', appId: 'plantis'),
      BoxConfiguration.basic(name: 'tasks', appId: 'plantis'),
      BoxConfiguration.basic(name: 'comments', appId: 'plantis'),
      BoxConfiguration.basic(name: 'comentarios', appId: 'plantis'),
      BoxConfiguration.basic(name: 'users', appId: 'plantis'),
      BoxConfiguration.basic(name: 'subscriptions', appId: 'plantis'),
    ];

    for (final config in plantisBoxes) {
      final result = await boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print(
          'Warning: Failed to register plantis box "${config.name}": ${result.fold((f) => f.message, (_) => '')}',
        );
      }
    }
  }
}
