import 'package:core/core.dart';

import '../constants/plantis_environment_config.dart';

/// Setup das boxes específicas do Plantis usando diretamente o core
class PlantisBoxesSetup {
  /// Registra todas as boxes específicas do Plantis
  static Future<void> registerPlantisBoxes() async {
    final boxRegistry = GetIt.I<IBoxRegistryService>();

    final plantisBoxes = [
      BoxConfiguration.basic(name: PlantisBoxes.main, appId: 'plantis'),
      // PlantisBoxes.plants removida - agora usa apenas UnifiedSyncManager 'plants'
      // PlantisBoxes.spaces removida - agora usa apenas UnifiedSyncManager 'spaces'
      // PlantisBoxes.tasks removida - agora usa apenas UnifiedSyncManager 'tasks'
      BoxConfiguration.basic(name: PlantisBoxes.reminders, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.care_logs, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.backups, appId: 'plantis'),
      // PlantisBoxes.comentarios removida - duplicada, usa apenas UnifiedSyncManager

      // UnifiedSyncManager boxes (usadas pelo sistema de sincronização)
      BoxConfiguration.basic(name: 'plants', appId: 'plantis'),
      BoxConfiguration.basic(name: 'spaces', appId: 'plantis'),
      BoxConfiguration.basic(name: 'tasks', appId: 'plantis'),
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
