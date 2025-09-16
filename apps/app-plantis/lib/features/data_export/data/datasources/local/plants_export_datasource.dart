import '../../../domain/entities/export_request.dart';

abstract class PlantsExportDataSource {
  Future<List<PlantExportData>> getUserPlantsData(String userId);
  Future<List<TaskExportData>> getUserTasksData(String userId);
  Future<List<SpaceExportData>> getUserSpacesData(String userId);
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId);
}

class PlantsExportLocalDataSource implements PlantsExportDataSource {

  PlantsExportLocalDataSource();

  @override
  Future<List<PlantExportData>> getUserPlantsData(String userId) async {
    try {
      // Mock data for now - in real implementation, integrate with actual data sources
      return [
        PlantExportData(
          id: '1',
          name: 'Plantas Mock para Export',
          species: 'Teste Species',
          spaceId: null,
          imageUrls: const [],
          plantingDate: DateTime.now(),
          notes: 'Dados mock para demonstração',
          config: null,
          isFavorited: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Erro ao buscar dados de plantas: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskExportData>> getUserTasksData(String userId) async {
    try {
      // Mock data for demonstration
      return [
        TaskExportData(
          id: '1',
          title: 'Regar plantas mock',
          description: 'Tarefa de exemplo para demonstração',
          plantId: '1',
          plantName: 'Plantas Mock para Export',
          type: 'watering',
          status: 'pending',
          priority: 'medium',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          completedAt: null,
          completionNotes: null,
          isRecurring: true,
          recurringIntervalDays: 7,
          nextDueDate: DateTime.now().add(const Duration(days: 8)),
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Erro ao buscar dados de tarefas: ${e.toString()}');
    }
  }

  @override
  Future<List<SpaceExportData>> getUserSpacesData(String userId) async {
    try {
      // Mock data for demonstration
      return [
        SpaceExportData(
          id: '1',
          name: 'Espaço Mock',
          description: 'Espaço de exemplo para demonstração do export LGPD',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Erro ao buscar dados de espaços: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId) async {
    try {
      // Mock data for demonstration
      return [
        PlantPhotoExportData(
          plantId: '1',
          plantName: 'Plantas Mock para Export',
          photoUrls: const ['mock_photo_url_1.jpg', 'mock_photo_url_2.jpg'],
          takenAt: DateTime.now(),
          caption: 'Fotos mock para demonstração',
        ),
      ];
    } catch (e) {
      throw Exception('Erro ao buscar dados de fotos: ${e.toString()}');
    }
  }
}