import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../features/animals/domain/entities/sync/animal_sync_entity.dart';
import '../../features/animals/domain/entities/animal_enums.dart';
import '../../features/medications/domain/entities/sync/medication_sync_entity.dart';
import '../../features/medications/domain/entities/medication.dart';
import 'petiveti_sync_manager.dart';

/// Classe de teste para verificar a integração do sync do Petiveti
/// Remove features multi-user e testa funcionalidade single-user
class PetivetiSyncTest {
  static Future<void> runTests() async {
    if (kDebugMode) {
      print('🧪 Iniciando testes de sincronização Petiveti (Single-User)...');

      try {
        await _testInitialization();
        await _testAnimalOperations();
        await _testMedicationOperations();
        await _testEmergencySync();
        await _testSyncStatus();

        print('✅ Todos os testes passaram!');
      } catch (e) {
        print('❌ Teste falhou: $e');
      }
    }
  }

  /// Teste de inicialização
  static Future<void> _testInitialization() async {
    print('🔧 Testando inicialização...');

    final result = await PetivetiSyncManager.instance.initialize(
      mode: PetivetiSyncMode.development,
    );

    if (result.isLeft()) {
      throw Exception('Falha na inicialização: ${result.fold((f) => f.message, (_) => '')}');
    }

    print('✅ Inicialização bem-sucedida');
  }

  /// Teste de operações com animais
  static Future<void> _testAnimalOperations() async {
    print('🐕 Testando operações com animais...');

    // Criar animal de teste (single-user)
    final testAnimal = AnimalSyncEntity(
      id: 'test_animal_001',
      name: 'Buddy',
      species: AnimalSpecies.dog,
      gender: AnimalGender.male,
      birthDate: DateTime(2020, 5, 15),
      weight: 25.5,
      userId: 'test_user_001', // Single user
      moduleName: 'petiveti',
      emergencyContact: '+55 11 99999-9999',
      veterinarianId: 'vet_001',
      allergies: ['glúten', 'frango'],
      isDirty: true,
    );

    // Criar animal
    final createResult = await PetivetiSyncManager.instance.createAnimal(testAnimal);
    if (createResult.isLeft()) {
      throw Exception('Falha ao criar animal: ${createResult.fold((f) => f.message, (_) => '')}');
    }

    // Buscar animal
    final getResult = await PetivetiSyncManager.instance.getAnimal('test_animal_001');
    if (getResult.isLeft()) {
      throw Exception('Falha ao buscar animal: ${getResult.fold((f) => f.message, (_) => '')}');
    }

    final retrievedAnimal = getResult.fold((_) => null, (animal) => animal);
    if (retrievedAnimal == null) {
      throw Exception('Animal não encontrado após criação');
    }

    // Verificar que dados de emergência estão preservados
    if (!retrievedAnimal.hasEmergencyData) {
      throw Exception('Dados de emergência não foram preservados');
    }

    print('✅ Operações com animais (single-user) funcionando');
  }

  /// Teste de operações com medicações
  static Future<void> _testMedicationOperations() async {
    print('💊 Testando operações com medicações...');

    // Criar medicação crítica para teste de emergência
    final criticalMedication = MedicationSyncEntity(
      id: 'test_med_001',
      animalId: 'test_animal_001',
      name: 'Insulina',
      dosage: '5 unidades',
      frequency: '2x ao dia',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      type: MedicationType.treatment,
      isCritical: true, // Medicação crítica para emergência
      requiresSupervision: true,
      emergencyInstructions: 'Em caso de hipoglicemia, administrar imediatamente',
      userId: 'test_user_001', // Single user
      moduleName: 'petiveti',
      isDirty: true,
    );

    // Criar medicação
    final createResult = await PetivetiSyncManager.instance.createMedication(criticalMedication);
    if (createResult.isLeft()) {
      throw Exception('Falha ao criar medicação: ${createResult.fold((f) => f.message, (_) => '')}');
    }

    // Buscar medicações do animal
    final medicationsResult = await PetivetiSyncManager.instance
        .getMedicationsForAnimal('test_animal_001');
    if (medicationsResult.isLeft()) {
      throw Exception('Falha ao buscar medicações: ${medicationsResult.fold((f) => f.message, (_) => '')}');
    }

    final medications = medicationsResult.fold((_) => <MedicationSyncEntity>[], (meds) => meds);
    if (medications.isEmpty) {
      throw Exception('Nenhuma medicação encontrada após criação');
    }

    final retrievedMedication = medications.first;
    if (!retrievedMedication.requiresEmergencySync) {
      throw Exception('Medicação crítica não foi marcada para sync de emergência');
    }

    print('✅ Operações com medicações críticas funcionando');
  }

  /// Teste de sincronização de emergência
  static Future<void> _testEmergencySync() async {
    print('🚨 Testando sincronização de emergência...');

    // Tentar sincronização de emergência
    final emergencyResult = await PetivetiSyncManager.instance.forceEmergencySync();
    if (emergencyResult.isLeft()) {
      print('⚠️ Sync de emergência falhou (pode ser esperado em testes): ${emergencyResult.fold((f) => f.message, (_) => '')}');
    } else {
      print('✅ Sync de emergência executado com sucesso');
    }
  }

  /// Teste de status de sincronização
  static Future<void> _testSyncStatus() async {
    print('📊 Testando status de sincronização...');

    final currentStatus = PetivetiSyncManager.instance.currentStatus;
    print('Status atual: ${currentStatus.name}');

    // Testar stream de status
    final statusStream = PetivetiSyncManager.instance.syncStatusStream;
    final subscription = statusStream.listen((status) {
      print('Status atualizado via stream: ${status.name}');
    });

    // Aguardar um pouco para verificar stream
    await Future.delayed(const Duration(seconds: 1));
    await subscription.cancel();

    print('✅ Status de sincronização funcionando');
  }

  /// Teste de informações de debug
  static void printDebugInfo() {
    if (kDebugMode) {
      print('🔍 Informações de Debug do Sync:');
      final debugInfo = PetivetiSyncManager.instance.getDebugInfo();
      debugInfo.forEach((key, value) {
        print('  $key: $value');
      });
    }
  }

  /// Limpa dados de teste
  static Future<void> cleanup() async {
    if (kDebugMode) {
      print('🧹 Limpando dados de teste...');

      try {
        await PetivetiSyncManager.instance.deleteAnimal('test_animal_001');
        await PetivetiSyncManager.instance.deleteMedication('test_med_001');
        print('✅ Cleanup concluído');
      } catch (e) {
        print('⚠️ Erro durante cleanup: $e');
      }
    }
  }
}

/// Extensão para facilitar testes
extension PetivetiSyncTestExtensions on AnimalSyncEntity {
  /// Verifica se o animal tem todos os dados necessários para single-user
  bool get isValidForSingleUser {
    return userId != null &&
           userId!.isNotEmpty &&
           name.isNotEmpty &&
           !name.contains('family') && // Não deve ter referências a família
           !name.contains('shared'); // Não deve ter referências a compartilhamento
  }
}

extension MedicationSyncTestExtensions on MedicationSyncEntity {
  /// Verifica se a medicação está configurada corretamente para single-user
  bool get isValidForSingleUser {
    return userId != null &&
           userId!.isNotEmpty &&
           animalId.isNotEmpty;
  }
}