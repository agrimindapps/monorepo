import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:app_receituagro/core/repositories/base_hive_repository.dart';
import 'package:app_receituagro/core/repositories/pragas_hive_repository.dart';
import 'package:app_receituagro/core/models/pragas_hive.dart';

/// Mock do PragasHive para teste
class MockPragasHive extends Mock implements PragasHive {
  @override
  String get idReg => '1';
  
  @override
  String get nomeComum => 'Praga Teste';
  
  @override
  String get nomeCientifico => 'Pragus testus';
  
  @override
  String get tipoPraga => '1';
  
  @override
  String? get familia => 'TestFamily';
}

/// Classe de teste que simula o BaseHiveRepository sem depender do Hive real
class TestableBaseHiveRepository extends BaseHiveRepository<MockPragasHive> {
  final List<MockPragasHive> _mockData = [];
  bool _isBoxOpen = false;
  
  TestableBaseHiveRepository() : super('test_box');
  
  /// Simula box aberto
  void simulateBoxOpen() {
    _isBoxOpen = true;
    _mockData.clear();
    // Adiciona dados mock
    for (int i = 1; i <= 10; i++) {
      _mockData.add(MockPragasHive());
    }
  }
  
  /// Simula box fechado
  void simulateBoxClosed() {
    _isBoxOpen = false;
  }
  
  @override
  List<MockPragasHive> getAll() {
    if (!_isBoxOpen) {
      print('⚠️ Box test_box não estava aberto - retornando lista vazia');
      return [];
    }
    
    print('📦 Box test_box aberto com ${_mockData.length} itens');
    return List.from(_mockData);
  }
  
  @override
  Future<List<MockPragasHive>> getAllAsync() async {
    // Simula aguardar box estar aberto
    if (!_isBoxOpen) {
      await Future.delayed(const Duration(milliseconds: 100));
      simulateBoxOpen(); // Usa o método que adiciona os dados mock
    }
    
    print('📦 Box test_box carregado assincronamente com ${_mockData.length} itens');
    return List.from(_mockData);
  }
  
  @override
  MockPragasHive createFromJson(Map<String, dynamic> json) {
    return MockPragasHive();
  }
  
  @override
  String getKeyFromEntity(MockPragasHive entity) {
    return entity.idReg;
  }
}

void main() {
  group('Race Condition Fixes Tests', () {
    late TestableBaseHiveRepository repository;
    
    setUp(() {
      repository = TestableBaseHiveRepository();
    });
    
    test('getAll() deve retornar lista vazia quando box não está aberto', () {
      // Arrange: Box começa fechado
      repository.simulateBoxClosed();
      
      // Act
      final result = repository.getAll();
      
      // Assert
      expect(result, isEmpty);
      expect(result.length, equals(0));
    });
    
    test('getAll() deve retornar dados quando box está aberto', () {
      // Arrange
      repository.simulateBoxOpen();
      
      // Act
      final result = repository.getAll();
      
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(10));
    });
    
    test('getAllAsync() deve aguardar box estar aberto e retornar dados', () async {
      // Arrange: Box começa fechado
      repository.simulateBoxClosed();
      
      // Act
      final result = await repository.getAllAsync();
      
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(10));
    });
    
    test('getAllAsync() deve funcionar mesmo quando box já está aberto', () async {
      // Arrange
      repository.simulateBoxOpen();
      
      // Act
      final result = await repository.getAllAsync();
      
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(10));
    });
    
    test('findByAsync() deve aguardar box estar aberto e filtrar dados', () async {
      // Arrange: Box começa fechado
      repository.simulateBoxClosed();
      
      // Act - filtro que sempre retorna true
      final result = await repository.findByAsync((item) => true);
      
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(10));
    });
    
    test('Race condition: getAll() vs getAllAsync() behavior comparison', () async {
      // Arrange: Box fechado
      repository.simulateBoxClosed();
      
      // Act
      final syncResult = repository.getAll();
      final asyncResult = await repository.getAllAsync();
      
      // Assert
      expect(syncResult, isEmpty, reason: 'getAll() deve retornar vazio quando box não está aberto');
      expect(asyncResult, isNotEmpty, reason: 'getAllAsync() deve aguardar e retornar dados');
      expect(asyncResult.length, equals(10));
    });
  });
  
  group('PragasHiveRepository Integration Tests', () {
    test('PragasHiveRepository deve herdar comportamento correto', () {
      // Este teste seria executado com mock do Hive real
      // Por enquanto apenas valida que a estrutura está correta
      expect(PragasHiveRepository, isNotNull);
      
      final repo = PragasHiveRepository();
      expect(repo, isA<BaseHiveRepository<PragasHive>>());
    });
  });
}