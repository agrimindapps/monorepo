import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/cache/cache_manager.dart';

void main() {
  group('MemoryCacheManager', () {
    late MemoryCacheManager<String, String> cache;

    setUp(() {
      cache = MemoryCacheManager<String, String>(
        maxSize: 3,
        defaultTtl: const Duration(milliseconds: 100),
      );
    });

    test('deve armazenar e recuperar valores', () {
      cache.put('key1', 'value1');
      expect(cache.get('key1'), equals('value1'));
    });

    test('deve retornar null para chaves inexistentes', () {
      expect(cache.get('inexistente'), isNull);
    });

    test('deve respeitar TTL', () async {
      cache.put('key1', 'value1', ttl: const Duration(milliseconds: 50));
      expect(cache.get('key1'), equals('value1'));
      
      await Future.delayed(const Duration(milliseconds: 60));
      expect(cache.get('key1'), isNull);
    });

    test('deve remover valores', () {
      cache.put('key1', 'value1');
      expect(cache.get('key1'), equals('value1'));
      
      cache.remove('key1');
      expect(cache.get('key1'), isNull);
    });

    test('deve limpar todos os valores', () {
      cache.put('key1', 'value1');
      cache.put('key2', 'value2');
      expect(cache.size, equals(2));
      
      cache.clear();
      expect(cache.size, equals(0));
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNull);
    });

    test('deve respeitar tamanho máximo (LRU)', () {
      cache.put('key1', 'value1');
      cache.put('key2', 'value2');
      cache.put('key3', 'value3');
      expect(cache.size, equals(3));
      
      // Adicionar mais um deve remover o mais antigo
      cache.put('key4', 'value4');
      expect(cache.size, equals(3));
      expect(cache.get('key1'), isNull); // Removido por ser o mais antigo
      expect(cache.get('key4'), equals('value4'));
    });

    test('deve verificar se contém chave', () {
      cache.put('key1', 'value1');
      expect(cache.containsKey('key1'), isTrue);
      expect(cache.containsKey('key2'), isFalse);
    });

    test('deve retornar estatísticas', () {
      cache.put('key1', 'value1');
      cache.put('key2', 'value2');
      
      final stats = cache.getStats();
      expect(stats['totalEntries'], equals(2));
      expect(stats['validEntries'], equals(2));
      expect(stats['maxSize'], equals(3));
    });

    test('deve limpar entradas expiradas automaticamente', () async {
      cache.put('key1', 'value1', ttl: const Duration(milliseconds: 50));
      cache.put('key2', 'value2', ttl: const Duration(seconds: 1));
      expect(cache.size, equals(2));
      
      await Future.delayed(const Duration(milliseconds: 60));
      
      // Acessar um valor válido deve limpar os expirados
      expect(cache.get('key2'), equals('value2'));
      expect(cache.size, equals(1));
    });
  });

  group('CachedRepository Mixin', () {
    late TestCachedRepository repository;

    setUp(() {
      repository = TestCachedRepository();
    });

    test('deve cachear e recuperar entidades', () {
      final entity = TestEntity('1', 'Test');
      repository.cacheEntity('entity_1', entity);
      
      final cached = repository.getCachedEntity('entity_1');
      expect(cached, equals(entity));
    });

    test('deve cachear e recuperar listas', () {
      final entities = [
        TestEntity('1', 'Test1'),
        TestEntity('2', 'Test2'),
      ];
      repository.cacheList('list_1', entities);
      
      final cached = repository.getCachedList('list_1');
      expect(cached, equals(entities));
      expect(cached?.length, equals(2));
    });

    test('deve invalidar cache específico', () {
      final entity = TestEntity('1', 'Test');
      repository.cacheEntity('entity_1', entity);
      expect(repository.getCachedEntity('entity_1'), equals(entity));
      
      repository.invalidateCache('entity_1');
      expect(repository.getCachedEntity('entity_1'), isNull);
    });

    test('deve limpar todo o cache', () {
      repository.cacheEntity('entity_1', TestEntity('1', 'Test1'));
      repository.cacheList('list_1', [TestEntity('2', 'Test2')]);
      
      repository.clearAllCache();
      
      expect(repository.getCachedEntity('entity_1'), isNull);
      expect(repository.getCachedList('list_1'), isNull);
    });

    test('deve gerar chaves de cache corretas', () {
      expect(repository.entityCacheKey('123'), equals('entity_123'));
      expect(repository.vehicleCacheKey('456', 'expenses'), equals('vehicle_456_expenses'));
      expect(repository.typeCacheKey('maintenance', 'list'), equals('type_maintenance_list'));
    });

    test('deve retornar estatísticas de cache', () {
      repository.cacheEntity('entity_1', TestEntity('1', 'Test'));
      repository.cacheList('list_1', [TestEntity('2', 'Test2')]);
      
      final stats = repository.getCacheStats();
      expect(stats, containsPair('entityCache', anything));
      expect(stats, containsPair('listCache', anything));
    });
  });
}

// Classes auxiliares para teste
class TestEntity {
  final String id;
  final String name;

  TestEntity(this.id, this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestEntity && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class TestCachedRepository with CachedRepository<TestEntity> {
  TestCachedRepository() {
    initializeCache();
  }
}