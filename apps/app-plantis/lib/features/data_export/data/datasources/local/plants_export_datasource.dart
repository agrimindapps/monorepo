import '../../../../plants/domain/repositories/plant_comments_repository.dart';
import '../../../../plants/domain/repositories/plants_repository.dart';
import '../../../../plants/domain/repositories/spaces_repository.dart';
import '../../../../tasks/domain/repositories/tasks_repository.dart';
import '../../../domain/entities/export_request.dart';

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
        (failure) =>
            throw Exception('Erro ao buscar plantas: ${failure.message}'),
        (plants) => plants
            .map(
              (plant) => PlantExportData(
                id: plant.id,
                name: plant.name,
                species: plant.species,
                spaceId: plant.spaceId,
                imageUrls: plant.imageUrls,
                plantingDate: plant.plantingDate,
                notes: plant.notes,
                config: plant.config != null
                    ? PlantConfigExportData(
                        wateringIntervalDays:
                            plant.config!.wateringIntervalDays,
                        fertilizingIntervalDays:
                            plant.config!.fertilizingIntervalDays,
                        pruningIntervalDays: plant.config!.pruningIntervalDays,
                        lightRequirement: plant.config!.lightRequirement,
                        waterAmount: plant.config!.waterAmount,
                        soilType: plant.config!.soilType,
                        enableWateringCare: plant.config!.enableWateringCare,
                        lastWateringDate: plant.config!.lastWateringDate,
                        enableFertilizerCare:
                            plant.config!.enableFertilizerCare,
                        lastFertilizerDate: plant.config!.lastFertilizerDate,
                      )
                    : null,
                isFavorited: plant.isFavorited,
                createdAt: plant.createdAt,
                updatedAt: plant.updatedAt,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Erro ao buscar dados de plantas: ${e.toString()}');
    }
  }

  @override
  Future<List<TaskExportData>> getUserTasksData(String userId) async {
    try {
      final tasksResult = await _tasksRepository.getTasks();
      final plantsResult = await _plantsRepository.getPlants();

      return tasksResult.fold(
        (failure) =>
            throw Exception('Erro ao buscar tarefas: ${failure.message}'),
        (tasks) {
          // Create plant ID to name map for lookup
          final plantNameMap = <String, String>{};
          plantsResult.fold((_) => <String, String>{}, (plants) {
            for (final plant in plants) {
              plantNameMap[plant.id] = plant.name;
            }
          });

          return tasks
              .map(
                (task) => TaskExportData(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  plantId: task.plantId,
                  plantName:
                      plantNameMap[task.plantId] ?? 'Planta ID ${task.plantId}',
                  type: task.type.name,
                  status: task.status.name,
                  priority: task.priority.name,
                  dueDate: task.dueDate,
                  completedAt: task.completedAt,
                  completionNotes: task.completionNotes,
                  isRecurring: task.isRecurring,
                  recurringIntervalDays: task.recurringIntervalDays,
                  nextDueDate: task.nextDueDate,
                  createdAt: task.createdAt,
                ),
              )
              .toList();
        },
      );
    } catch (e) {
      throw Exception('Erro ao buscar dados de tarefas: ${e.toString()}');
    }
  }

  @override
  Future<List<SpaceExportData>> getUserSpacesData(String userId) async {
    try {
      final spacesResult = await _spacesRepository.getSpaces();

      return spacesResult.fold(
        (failure) =>
            throw Exception('Erro ao buscar espaços: ${failure.message}'),
        (spaces) => spaces
            .map(
              (space) => SpaceExportData(
                id: space.id,
                name: space.name,
                description: space.description,
                createdAt: space.createdAt,
                updatedAt: space.updatedAt,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Erro ao buscar dados de espaços: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(
    String userId,
  ) async {
    try {
      final plantsResult = await _plantsRepository.getPlants();

      return plantsResult.fold(
        (failure) =>
            throw Exception('Erro ao buscar fotos: ${failure.message}'),
        (plants) {
          final photoExports = <PlantPhotoExportData>[];

          for (final plant in plants) {
            if (plant.imageUrls.isNotEmpty) {
              photoExports.add(
                PlantPhotoExportData(
                  plantId: plant.id,
                  plantName: plant.name,
                  photoUrls: plant.imageUrls,
                  takenAt: plant.createdAt,
                  caption: plant.notes ?? 'Fotos de ${plant.name}',
                ),
              );
            }
          }

          return photoExports;
        },
      );
    } catch (e) {
      throw Exception('Erro ao buscar dados de fotos: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(
    String userId,
  ) async {
    try {
      final plantsResult = await _plantsRepository.getPlants();
      final allComments = <PlantCommentExportData>[];

      await plantsResult.fold(
        (failure) async =>
            throw Exception('Erro ao buscar plantas: ${failure.message}'),
        (plants) async {
          // Create plant ID to name map for lookup
          final plantNameMap = <String, String>{};
          for (final plant in plants) {
            plantNameMap[plant.id] = plant.name;
          }

          // Fetch comments for each plant
          for (final plant in plants) {
            final commentsResult = await _commentsRepository
                .getCommentsForPlant(plant.id);

            commentsResult.fold(
              (failure) {
                // Log error but continue with other plants
              },
              (comments) {
                for (final comment in comments) {
                  allComments.add(
                    PlantCommentExportData(
                      id: comment.id,
                      plantId: comment.plantId ?? plant.id,
                      plantName:
                          plantNameMap[comment.plantId ?? plant.id] ??
                          plant.name,
                      content: comment.conteudo,
                      createdAt: comment.createdAt ?? comment.dataCriacao,
                      updatedAt: comment.updatedAt ?? comment.dataAtualizacao,
                    ),
                  );
                }
              },
            );
          }
        },
      );

      return allComments;
    } catch (e) {
      throw Exception('Erro ao buscar dados de comentários: ${e.toString()}');
    }
  }
}
