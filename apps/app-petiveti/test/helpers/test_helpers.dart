import 'package:app_petiveti/core/cache/cache_service.dart';
import 'package:app_petiveti/core/notifications/notification_service.dart';
import 'package:app_petiveti/core/performance/performance_service.dart';
import 'package:app_petiveti/core/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helpers para configuração de testes
class TestHelpers {
  /// Configura o ambiente de teste
  static Future<void> setupTestEnvironment() async {
    // Reset GetIt
    await GetIt.instance.reset();
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Registrar mocks para dependências
    _registerTestMocks();
  }

  /// Limpa o ambiente após os testes
  static Future<void> tearDownTestEnvironment() async {
    await GetIt.instance.reset();
  }

  /// Registra mocks para dependências principais
  static void _registerTestMocks() {
    final getIt = GetIt.instance;
    
    // Mock HiveService
    getIt.registerLazySingleton<HiveService>(
      () => MockHiveService(),
    );
    
    // Mock CacheService
    getIt.registerLazySingleton<CacheService>(
      () => MockCacheService(),
    );
    
    // Mock PerformanceService
    getIt.registerLazySingleton<PerformanceService>(
      () => MockPerformanceService(),
    );
    
    // Mock NotificationService
    getIt.registerLazySingleton<NotificationService>(
      () => MockNotificationService(),
    );
  }

  /// Cria um widget de teste com MaterialApp
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Cria dados de teste para animais
  static Map<String, dynamic> createTestAnimalData({
    String? id,
    String? name,
    String? species,
    String? breed,
  }) {
    return {
      'id': id ?? 'test_animal_001',
      'nome': name ?? 'Rex',
      'especie': species ?? 'Cão',
      'raca': breed ?? 'Labrador',
      'sexo': 'Macho',
      'idade': 3,
      'peso': 25.5,
      'cor': 'Dourado',
      'observacoes': 'Animal dócil e bem cuidado',
      'isAtivo': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Cria dados de teste para medicamentos
  static Map<String, dynamic> createTestMedicationData({
    String? id,
    String? animalId,
    String? name,
  }) {
    return {
      'id': id ?? 'test_medication_001',
      'animalId': animalId ?? 'test_animal_001',
      'name': name ?? 'Amoxicilina',
      'dosage': '250mg',
      'frequency': '2x/dia',
      'startDate': DateTime.now().toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'type': 'antibiotic',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Cria dados de teste para consultas
  static Map<String, dynamic> createTestAppointmentData({
    String? id,
    String? animalId,
    String? title,
  }) {
    return {
      'id': id ?? 'test_appointment_001',
      'animalId': animalId ?? 'test_animal_001',
      'title': title ?? 'Consulta de rotina',
      'description': 'Check-up geral do animal',
      'dateTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'veterinarianName': 'Dr. João Silva',
      'clinicName': 'Clínica Veterinária Central',
      'type': 'checkup',
      'status': 'scheduled',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Cria dados de teste para vacinas
  static Map<String, dynamic> createTestVaccineData({
    String? id,
    String? animalId,
    String? name,
  }) {
    return {
      'id': id ?? 'test_vaccine_001',
      'animalId': animalId ?? 'test_animal_001',
      'name': name ?? 'V10',
      'description': 'Vacina múltipla',
      'applicationDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'nextDoseDate': DateTime.now().add(const Duration(days: 335)).toIso8601String(),
      'veterinarianName': 'Dr. Maria Santos',
      'clinicName': 'Clínica Veterinária Central',
      'batch': 'ABC123',
      'status': 'applied',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Cria dados de teste para controle de peso
  static Map<String, dynamic> createTestWeightData({
    String? id,
    String? animalId,
    double? weight,
  }) {
    return {
      'id': id ?? 'test_weight_001',
      'animalId': animalId ?? 'test_animal_001',
      'weight': weight ?? 25.5,
      'date': DateTime.now().toIso8601String(),
      'bodyConditionScore': 5,
      'notes': 'Peso ideal para a raça',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Cria dados de teste para despesas
  static Map<String, dynamic> createTestExpenseData({
    String? id,
    String? animalId,
    double? amount,
  }) {
    return {
      'id': id ?? 'test_expense_001',
      'animalId': animalId ?? 'test_animal_001',
      'userId': 'test_user_001',
      'title': 'Consulta veterinária',
      'description': 'Check-up de rotina',
      'amount': amount ?? 150.0,
      'category': 'consultation',
      'paymentMethod': 'creditCard',
      'expenseDate': DateTime.now().toIso8601String(),
      'veterinaryClinic': 'Clínica Veterinária Central',
      'veterinarianName': 'Dr. João Silva',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Aguarda que futures sejam processadas
  static Future<void> waitForFutures() async {
    await Future.delayed(Duration.zero);
  }

  /// Simula delay de rede
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 100));
  }
}

/// Matchers customizados para testes
class TestMatchers {
  /// Verifica se é uma data válida
  static Matcher isValidDate() => predicate<String>(
    (value) {
      try {
        DateTime.parse(value);
        return true;
      } catch (e) {
        return false;
      }
    },
    'is a valid ISO date string',
  );

  /// Verifica se é um ID válido
  static Matcher isValidId() => predicate<String>(
    (value) => value.isNotEmpty && value.length >= 3,
    'is a valid ID',
  );

  /// Verifica se é um peso válido
  static Matcher isValidWeight() => predicate<double>(
    (value) => value > 0 && value < 200,
    'is a valid weight',
  );

  /// Verifica se é um valor monetário válido
  static Matcher isValidAmount() => predicate<double>(
    (value) => value >= 0,
    'is a valid monetary amount',
  );
}

/// Extensões para facilitar testes
extension TestWidgetTesterExtensions on WidgetTester {
  /// Encontra widget por key
  Future<void> tapByKey(String key) async {
    await tap(find.byKey(Key(key)));
    await pump();
  }

  /// Entra texto em um campo
  Future<void> enterTextInField(String key, String text) async {
    await enterText(find.byKey(Key(key)), text);
    await pump();
  }

  /// Espera por um widget aparecer
  Future<void> waitForWidget(Finder finder, {Duration timeout = const Duration(seconds: 5)}) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      await pump();
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException('Widget not found within timeout', timeout);
  }
}

/// Exception para timeout em testes
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}

// Mocks para serviços
class MockHiveService extends Mock implements HiveService {}
class MockCacheService extends Mock implements CacheService {}
class MockPerformanceService extends Mock implements PerformanceService {}
class MockNotificationService extends Mock implements NotificationService {}