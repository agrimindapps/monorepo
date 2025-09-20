import '../../../domain/entities/export_request.dart';
import '../../../../plants/domain/repositories/plants_repository.dart';
import '../../../../plants/domain/repositories/plant_comments_repository.dart';
import '../../../../tasks/domain/repositories/tasks_repository.dart';
import '../../../../plants/domain/repositories/spaces_repository.dart';

abstract class PlantsExportDataSource {
  Future<List<PlantExportData>> getUserPlantsData(String userId);
  Future<List<TaskExportData>> getUserTasksData(String userId);
  Future<List<SpaceExportData>> getUserSpacesData(String userId);
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId);
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(String userId);
}

class PlantsExportLocalDataSource implements PlantsExportDataSource {
  final PlantsRepository _plantsRepository;
  final PlantCommentsRepository _commentsRepository;
  final TasksRepository _tasksRepository;
  final SpacesRepository _spacesRepository;

  PlantsExportLocalDataSource({
    required PlantsRepository plantsRepository,
    required PlantCommentsRepository commentsRepository,
    required TasksRepository tasksRepository,
    required SpacesRepository spacesRepository,
  }) : _plantsRepository = plantsRepository,
       _commentsRepository = commentsRepository,
       _tasksRepository = tasksRepository,
       _spacesRepository = spacesRepository;

  @override
  Future<List<PlantExportData>> getUserPlantsData(String userId) async {
    try {
      final plantsResult = await _plantsRepository.getPlants();
      
      return plantsResult.fold(
        (failure) => throw Exception('Erro ao buscar plantas: ${failure.message}'),
        (plants) => plants.map((plant) => PlantExportData(
          id: plant.id,
          name: plant.name,
          species: plant.species,
          spaceId: plant.spaceId,
          imageUrls: plant.imageUrls,
          plantingDate: plant.plantingDate,
          notes: plant.notes,
          config: plant.config != null ? PlantConfigExportData(
            wateringIntervalDays: plant.config!.wateringIntervalDays,
            fertilizingIntervalDays: plant.config!.fertilizingIntervalDays,
            pruningIntervalDays: plant.config!.pruningIntervalDays,
            lightRequirement: plant.config!.lightRequirement,
            waterAmount: plant.config!.waterAmount,
            soilType: plant.config!.soilType,
            enableWateringCare: plant.config!.enableWateringCare,
            lastWateringDate: plant.config!.lastWateringDate,
            enableFertilizerCare: plant.config!.enableFertilizerCare,
            lastFertilizerDate: plant.config!.lastFertilizerDate,
          ) : null,
          isFavorited: plant.isFavorited,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        )).toList(),
      );
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

  @override
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(String userId) async {
    try {
      // Mock data for demonstration
      return [
        PlantCommentExportData(
          id: '1',
          plantId: '1',
          plantName: 'Plantas Mock para Export',
          content: 'Comentário mock para demonstração do export LGPD',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PlantCommentExportData(
          id: '2',
          plantId: '1',
          plantName: 'Plantas Mock para Export',
          content: 'Outro comentário de exemplo para validar estrutura de exportação',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Erro ao buscar dados de comentários: ${e.toString()}');
    }
  }
}