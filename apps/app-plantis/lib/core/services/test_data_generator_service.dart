import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../../features/tasks/domain/usecases/add_task_usecase.dart';

class TestDataGeneratorService {
  final AddPlantUseCase addPlantUseCase;
  final AddTaskUseCase addTaskUseCase;
  final _uuid = const Uuid();
  final _random = Random();

  TestDataGeneratorService({
    required this.addPlantUseCase,
    required this.addTaskUseCase,
  });

  final List<String> _plantNames = [
    'Rosa Vermelha',
    'Samambaia Boston',
    'Suculenta Jade',
    'Violeta Africana',
    'Cacto Mandacaru',
    'Monstera Deliciosa',
    'Espada de São Jorge',
    'Hortelã',
    'Alecrim',
    'Manjericão',
    'Lavanda',
    'Girassol',
    'Orquídea Branca',
    'Tulipa Rosa',
    'Lírio da Paz',
  ];

  final List<String> _species = [
    'Rosa rubiginosa',
    'Nephrolepis exaltata',
    'Crassula ovata',
    'Saintpaulia ionantha',
    'Cereus jamacaru',
    'Monstera deliciosa',
    'Sansevieria trifasciata',
    'Mentha spicata',
    'Rosmarinus officinalis',
    'Ocimum basilicum',
    'Lavandula angustifolia',
    'Helianthus annuus',
    'Phalaenopsis amabilis',
    'Tulipa gesneriana',
    'Spathiphyllum wallisii',
  ];

  final List<String> _notes = [
    'Planta muito bonita e perfumada',
    'Precisa de bastante umidade',
    'Ideal para ambientes internos',
    'Cresce rapidamente',
    'Resistente e fácil de cuidar',
    'Perfeita para iniciantes',
    'Flores aparecem na primavera',
    'Ótima para purificar o ar',
    'Folhas grandes e vistosas',
    'Precisa de luz indireta',
  ];

  Future<void> generateTestData() async {
    final plants = <Plant>[];
    
    // Gerar 8-12 plantas
    final plantsCount = 8 + _random.nextInt(5);
    
    for (int i = 0; i < plantsCount; i++) {
      final plantIndex = _random.nextInt(_plantNames.length);
      final now = DateTime.now();
      final plantingDate = now.subtract(Duration(days: _random.nextInt(365)));
      
      final plantParams = AddPlantParams(
        name: _plantNames[plantIndex],
        species: _species[plantIndex],
        plantingDate: plantingDate,
        notes: _random.nextBool() ? _notes[_random.nextInt(_notes.length)] : null,
        config: _generatePlantConfig(),
      );
      
      final result = await addPlantUseCase(plantParams);
      result.fold(
        (failure) => print('Erro ao criar planta: ${failure.message}'),
        (plant) => plants.add(plant),
      );
    }
    
    // Gerar tarefas para as plantas criadas
    for (final plant in plants) {
      await _generateTasksForPlant(plant);
    }
  }

  PlantConfig _generatePlantConfig() {
    return PlantConfig(
      wateringIntervalDays: _random.nextBool() ? 2 + _random.nextInt(6) : null,
      fertilizingIntervalDays: _random.nextBool() ? 15 + _random.nextInt(16) : null,
      pruningIntervalDays: _random.nextBool() ? 30 + _random.nextInt(31) : null,
      lightRequirement: ['low', 'medium', 'high'][_random.nextInt(3)],
      waterAmount: ['little', 'moderate', 'plenty'][_random.nextInt(3)],
      soilType: _random.nextBool() ? 'Terra vegetal' : null,
      idealTemperature: _random.nextBool() ? 18.0 + _random.nextInt(15) : null,
      idealHumidity: _random.nextBool() ? 40.0 + _random.nextInt(41) : null,
    );
  }

  Future<void> _generateTasksForPlant(Plant plant) async {
    final now = DateTime.now();
    final config = plant.config;
    
    // Gerar tarefas baseadas na configuração da planta
    if (config?.hasWateringSchedule == true) {
      await _createTask(
        plant: plant,
        type: task_entity.TaskType.watering,
        dueDate: now.add(Duration(days: _random.nextInt(3))),
      );
    }
    
    if (config?.hasFertilizingSchedule == true) {
      await _createTask(
        plant: plant,
        type: task_entity.TaskType.fertilizing,
        dueDate: now.add(Duration(days: 1 + _random.nextInt(7))),
      );
    }
    
    if (config?.hasPruningSchedule == true) {
      await _createTask(
        plant: plant,
        type: task_entity.TaskType.pruning,
        dueDate: now.add(Duration(days: 5 + _random.nextInt(10))),
      );
    }
    
    // Algumas tarefas aleatórias
    if (_random.nextBool()) {
      await _createTask(
        plant: plant,
        type: task_entity.TaskType.pestInspection,
        dueDate: now.add(Duration(days: _random.nextInt(14))),
      );
    }
    
    if (_random.nextBool()) {
      await _createTask(
        plant: plant,
        type: task_entity.TaskType.cleaning,
        dueDate: now.add(Duration(days: _random.nextInt(7))),
      );
    }
  }

  Future<void> _createTask({
    required Plant plant,
    required task_entity.TaskType type,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    
    final task = task_entity.Task(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      title: '${type.displayName} ${plant.name}',
      description: 'Tarefa gerada automaticamente para teste',
      plantId: plant.id,
      plantName: plant.name,
      type: type,
      dueDate: dueDate,
      priority: [
        task_entity.TaskPriority.low,
        task_entity.TaskPriority.medium,
        task_entity.TaskPriority.high,
      ][_random.nextInt(3)],
      isDirty: true,
    );
    
    final result = await addTaskUseCase(AddTaskParams(task: task));
    result.fold(
      (failure) => print('Erro ao criar tarefa: ${failure.message}'),
      (task) => print('Tarefa criada: ${task.title}'),
    );
  }
}