import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';

/// Exemplo de uso da nova infraestrutura Hive do Core
/// Demonstra como usar HiveManager, BaseHiveRepository e CoreHiveStorageService

// Modelo de exemplo para teste
@HiveType(typeId: 200)
class TestEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  TestEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  String toString() => 'TestEntity(id: $id, name: $name, createdAt: $createdAt)';
}

// Adapter para o modelo de teste
class TestEntityAdapter extends TypeAdapter<TestEntity> {
  @override
  final int typeId = 200;

  @override
  TestEntity read(BinaryReader reader) {
    return TestEntity(
      id: reader.readString(),
      name: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, TestEntity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

// Repository específico usando BaseHiveRepository
class TestEntityRepository extends BaseHiveRepository<TestEntity> {
  TestEntityRepository(IHiveManager hiveManager)
      : super(hiveManager: hiveManager, boxName: 'test_entities');

  /// Busca entidade por nome
  Future<Result<TestEntity?>> findByName(String name) async {
    return await findFirst((entity) => entity.name == name);
  }

  /// Busca entidades criadas hoje
  Future<Result<List<TestEntity>>> findCreatedToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await findBy((entity) => 
        entity.createdAt.isAfter(startOfDay) && 
        entity.createdAt.isBefore(endOfDay));
  }
}

/// Classe para demonstrar o uso da infraestrutura
class CoreHiveUsageExample {
  late final CoreHiveStorageService _storageService;
  late final TestEntityRepository _repository;
  
  CoreHiveUsageExample() {
    _storageService = CoreHiveStorageService();
    _repository = TestEntityRepository(HiveManager.instance);
  }

  /// Inicializa a infraestrutura
  Future<Result<void>> initialize() async {
    try {
      debugPrint('🚀 Inicializando Core Hive Infrastructure...');

      // 1. Registra adapter
      final hiveManager = HiveManager.instance;
      final adapterResult = await hiveManager.registerAdapter(TestEntityAdapter());
      if (adapterResult.isError) {
        debugPrint('❌ Falha ao registrar adapter: ${adapterResult.error}');
        return adapterResult;
      }

      // 2. Inicializa storage service
      final initResult = await _storageService.initialize({
        'appName': 'receituagro_test',
      });
      if (initResult.isError) {
        debugPrint('❌ Falha ao inicializar storage: ${initResult.error}');
        return initResult;
      }

      debugPrint('✅ Core Hive Infrastructure inicializada com sucesso!');
      return Result.success(null);

    } catch (e) {
      debugPrint('❌ Erro na inicialização: $e');
      return Result.error(UnknownError(message: 'Erro na inicialização: $e', originalError: e, stackTrace: StackTrace.current));
    }
  }

  /// Demonstra operações CRUD básicas
  Future<void> demonstrateCRUD() async {
    debugPrint('\n📝 Demonstrando operações CRUD...');

    // CREATE
    final entity1 = TestEntity(
      id: 'test_001',
      name: 'Primeiro Teste',
      createdAt: DateTime.now(),
    );

    final entity2 = TestEntity(
      id: 'test_002', 
      name: 'Segundo Teste',
      createdAt: DateTime.now(),
    );

    final saveResult1 = await _repository.save(entity1, key: entity1.id);
    final saveResult2 = await _repository.save(entity2, key: entity2.id);

    if (saveResult1.isSuccess && saveResult2.isSuccess) {
      debugPrint('✅ Entidades salvas com sucesso');
    }

    // READ
    final allResult = await _repository.getAll();
    if (allResult.isSuccess) {
      final entities = allResult.data!;
      debugPrint('📖 Total de entidades: ${entities.length}');
      for (final entity in entities) {
        debugPrint('   - $entity');
      }
    }

    // FIND
    final findResult = await _repository.findByName('Primeiro Teste');
    if (findResult.isSuccess && findResult.data != null) {
      debugPrint('🔍 Encontrado por nome: ${findResult.data}');
    }

    // UPDATE
    final updatedEntity = TestEntity(
      id: 'test_001',
      name: 'Primeiro Teste (Atualizado)',
      createdAt: entity1.createdAt,
    );
    
    final updateResult = await _repository.save(updatedEntity, key: updatedEntity.id);
    if (updateResult.isSuccess) {
      debugPrint('🔄 Entidade atualizada com sucesso');
    }

    // DELETE
    final deleteResult = await _repository.deleteByKey('test_002');
    if (deleteResult.isSuccess) {
      debugPrint('🗑️ Entidade deletada com sucesso');
    }

    // COUNT
    final countResult = await _repository.count();
    if (countResult.isSuccess) {
      debugPrint('📊 Total após operações: ${countResult.data}');
    }
  }

  /// Demonstra funcionalidades do storage service
  Future<void> demonstrateStorageService() async {
    debugPrint('\n🔧 Demonstrando Storage Service...');

    // Health Check
    final healthResult = await _storageService.healthCheck();
    if (healthResult.isSuccess) {
      final healthData = healthResult.data!;
      debugPrint('💚 Health Check: ${healthData['status']}');
      debugPrint('   Boxes abertas: ${healthData['openBoxesCount']}');
    }

    // Statistics
    final statsResult = await _storageService.getStatistics();
    if (statsResult.isSuccess) {
      final statsData = statsResult.data!;
      debugPrint('📈 Estatísticas:');
      debugPrint('   Total de boxes: ${statsData['totalBoxes']}');
      debugPrint('   Total de itens: ${statsData['totalItems']}');
    }

    // List Boxes
    final boxesResult = await _storageService.listBoxes();
    if (boxesResult.isSuccess) {
      debugPrint('📦 Boxes abertas: ${boxesResult.data}');
    }

    // Box Statistics
    if (boxesResult.isSuccess && boxesResult.data!.isNotEmpty) {
      final boxName = boxesResult.data!.first;
      final boxStatsResult = await _storageService.getBoxStatistics(boxName);
      if (boxStatsResult.isSuccess) {
        final boxStatsData = boxStatsResult.data!;
        debugPrint('📊 Estatísticas da box "$boxName":');
        debugPrint('   Itens: ${boxStatsData['itemCount']}');
        debugPrint('   Vazia: ${boxStatsData['isEmpty']}');
      }
    }

    // Maintenance
    final maintenanceResult = await _storageService.performMaintenance();
    if (maintenanceResult.isSuccess) {
      debugPrint('🧹 Manutenção executada com sucesso');
    }
  }

  /// Limpa os dados de teste
  Future<void> cleanup() async {
    debugPrint('\n🧹 Limpando dados de teste...');
    
    final clearResult = await _repository.clear();
    if (clearResult.isSuccess) {
      debugPrint('✅ Dados de teste limpos');
    }
  }

  /// Executa todos os testes
  Future<void> runFullTest() async {
    final initResult = await initialize();
    if (initResult.isError) {
      debugPrint('❌ Falha na inicialização, abortando testes');
      return;
    }

    await demonstrateCRUD();
    await demonstrateStorageService();
    await cleanup();

    debugPrint('\n🎉 Teste da Core Hive Infrastructure concluído!');
  }
}