import 'package:core/core.dart';

import '../constants/plantis_environment_config.dart';

/// Setup das boxes específicas do Plantis usando diretamente o core
class PlantisBoxesSetup {
  /// Registra todas as boxes específicas do Plantis
  static Future<void> registerPlantisBoxes() async {
    print('🔧 [PlantisBoxesSetup] Iniciando registro de boxes do Plantis...');
    final boxRegistry = GetIt.I<IBoxRegistryService>();

    // ✅ IMPORTANTE: Marcar como persistent: true para garantir que as boxes
    // sejam abertas pelo BoxRegistry e registradas corretamente
    // Mesmo que já estejam abertas pelos local data sources, isso garante
    // compatibilidade com UnifiedSync e evita erros de tipo
    final plantisBoxes = [
      const BoxConfiguration(
        name: PlantisBoxes.main,
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: PlantisBoxes.reminders,
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: PlantisBoxes.careLogs,
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: PlantisBoxes.backups,
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'plants',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'spaces',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'tasks',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'comments',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'comentarios',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'users',
        appId: 'plantis',
        persistent: true,
      ),
      const BoxConfiguration(
        name: 'subscriptions',
        appId: 'plantis',
        persistent: true,
      ),
    ];

    print(
      '🔧 [PlantisBoxesSetup] Registrando ${plantisBoxes.length} boxes...',
    );

    for (final config in plantisBoxes) {
      final result = await boxRegistry.registerBox(config);
      result.fold(
        (failure) {
          print(
            '❌ [PlantisBoxesSetup] ERRO ao registrar box "${config.name}": ${failure.message}',
          );
        },
        (_) {
          print('✅ [PlantisBoxesSetup] Box "${config.name}" registrada com sucesso');
        },
      );
    }

    print('✅ [PlantisBoxesSetup] Registro de boxes do Plantis concluído');
  }
}
