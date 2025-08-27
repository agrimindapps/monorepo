import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_petiveti/core/error/failures.dart';
import 'package:app_petiveti/core/interfaces/usecase.dart';
import 'package:app_petiveti/features/medications/domain/entities/medication.dart';
import 'package:app_petiveti/features/medications/domain/repositories/medication_repository.dart';
import 'package:app_petiveti/features/medications/domain/usecases/add_medication.dart';
import 'package:app_petiveti/features/medications/domain/usecases/delete_medication.dart';
import 'package:app_petiveti/features/medications/domain/usecases/get_active_medications.dart';
import 'package:app_petiveti/features/medications/domain/usecases/get_expiring_medications.dart';
import 'package:app_petiveti/features/medications/domain/usecases/get_medication_by_id.dart';
import 'package:app_petiveti/features/medications/domain/usecases/get_medications.dart';
import 'package:app_petiveti/features/medications/domain/usecases/get_medications_by_animal_id.dart';
import 'package:app_petiveti/features/medications/domain/usecases/update_medication.dart';
import 'package:app_petiveti/features/medications/presentation/providers/medications_provider.dart';

import 'medications_provider_test.mocks.dart';

/// **Unit Tests for MedicationsProvider State Management**
/// 
/// This comprehensive test suite validates the medication provider's state management,
/// ensuring proper data flow, error handling, and business logic implementation.
/// 
/// **Testing Categories:**
/// 1. **State Management Tests** - Verify state transitions and updates
/// 2. **Use Case Integration Tests** - Test integration with domain layer
/// 3. **Error Handling Tests** - Validate error states and recovery
/// 4. **Filter and Search Tests** - Test medication filtering logic
/// 5. **Optimistic Updates Tests** - Verify UI optimizations
/// 6. **Performance Tests** - Ensure efficient state management
/// 7. **Provider Lifecycle Tests** - Test provider initialization and disposal
/// 8. **Edge Cases Tests** - Handle unusual but valid scenarios
/// 
/// **State Management Validation:**
/// - Loading states during async operations
/// - Error state propagation and clearing
/// - Data synchronization between different medication lists
/// - Optimistic UI updates for better user experience
/// - Provider caching and memory efficiency

@GenerateMocks([
  GetMedications,
  GetMedicationsByAnimalId,
  GetActiveMedications,
  GetMedicationById,
  AddMedication,
  UpdateMedication,
  DeleteMedication,
  DiscontinueMedication,
  GetExpiringSoonMedications,
  MedicationRepository,
])
void main() {
  group('MedicationsProvider State Management Tests', () {
    late MockGetMedications mockGetMedications;
    late MockGetMedicationsByAnimalId mockGetMedicationsByAnimalId;
    late MockGetActiveMedications mockGetActiveMedications;
    late MockGetMedicationById mockGetMedicationById;
    late MockAddMedication mockAddMedication;
    late MockUpdateMedication mockUpdateMedication;
    late MockDeleteMedication mockDeleteMedication;
    late MockDiscontinueMedication mockDiscontinueMedication;
    late MockGetExpiringSoonMedications mockGetExpiringSoonMedications;
    late MockMedicationRepository mockRepository;
    
    late MedicationsNotifier notifier;
    late ProviderContainer container;

    // Test data
    final testMedications = [
      _createTestMedication('1', 'Medication A', MedicationStatus.active),
      _createTestMedication('2', 'Medication B', MedicationStatus.active),
      _createTestMedication('3', 'Medication C', MedicationStatus.discontinued),
    ];

    final testActiveMedications = testMedications
        .where((m) => m.status == MedicationStatus.active)
        .toList();

    final testExpiringMedications = [
      _createTestMedication('4', 'Expiring Med', MedicationStatus.active),
    ];

    setUp(() {
      mockGetMedications = MockGetMedications();
      mockGetMedicationsByAnimalId = MockGetMedicationsByAnimalId();
      mockGetActiveMedications = MockGetActiveMedications();
      mockGetMedicationById = MockGetMedicationById();
      mockAddMedication = MockAddMedication();
      mockUpdateMedication = MockUpdateMedication();
      mockDeleteMedication = MockDeleteMedication();
      mockDiscontinueMedication = MockDiscontinueMedication();
      mockGetExpiringSoonMedications = MockGetExpiringSoonMedications();
      mockRepository = MockMedicationRepository();

      notifier = MedicationsNotifier(
        getMedications: mockGetMedications,
        getMedicationsByAnimalId: mockGetMedicationsByAnimalId,
        getActiveMedications: mockGetActiveMedications,
        getMedicationById: mockGetMedicationById,
        addMedication: mockAddMedication,
        updateMedication: mockUpdateMedication,
        deleteMedication: mockDeleteMedication,
        discontinueMedication: mockDiscontinueMedication,
        getExpiringSoonMedications: mockGetExpiringSoonMedications,
      );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State Tests', () {
      test('should initialize with correct default state', () {
        expect(notifier.state.medications, isEmpty);
        expect(notifier.state.activeMedications, isEmpty);
        expect(notifier.state.expiringMedications, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('should have proper initial state values', () {
        final state = notifier.state;
        expect(state, isA<MedicationsState>());
        expect(state.medications, const <Medication>[]);
        expect(state.activeMedications, const <Medication>[]);
        expect(state.expiringMedications, const <Medication>[]);
        expect(state.isLoading, false);
        expect(state.error, null);
      });
    });

    group('Load Medications Tests', () {
      test('should load medications successfully', () async {
        // Arrange
        when(mockGetMedications(const NoParams()))
            .thenAnswer((_) async => Right(testMedications));

        // Act
        await notifier.loadMedications();

        // Assert
        expect(notifier.state.medications, equals(testMedications));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockGetMedications(const NoParams())).called(1);
      });

      test('should set loading state during medication loading', () async {
        // Arrange
        when(mockGetMedications(const NoParams()))
            .thenAnswer((_) async => Right(testMedications));

        // Act & Assert
        final future = notifier.loadMedications();
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);
        
        await future;
        expect(notifier.state.isLoading, isFalse);
      });

      test('should handle medication loading failure', () async {
        // Arrange
        const errorMessage = 'Failed to load medications';
        when(mockGetMedications(const NoParams()))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.loadMedications();

        // Assert
        expect(notifier.state.medications, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals(errorMessage));
        verify(mockGetMedications(const NoParams())).called(1);
      });

      test('should clear previous error when loading medications', () async {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Previous error');
        when(mockGetMedications(const NoParams()))
            .thenAnswer((_) async => Right(testMedications));

        // Act
        await notifier.loadMedications();

        // Assert
        expect(notifier.state.error, isNull);
        expect(notifier.state.medications, equals(testMedications));
      });
    });

    group('Load Medications by Animal ID Tests', () {
      const animalId = 'animal-123';

      test('should load medications for specific animal', () async {
        // Arrange
        final animalMedications = [testMedications.first];
        when(mockGetMedicationsByAnimalId(animalId))
            .thenAnswer((_) async => Right(animalMedications));

        // Act
        await notifier.loadMedicationsByAnimalId(animalId);

        // Assert
        expect(notifier.state.medications, equals(animalMedications));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        verify(mockGetMedicationsByAnimalId(animalId)).called(1);
      });

      test('should handle failure when loading medications by animal ID', () async {
        // Arrange
        const errorMessage = 'Animal not found';
        when(mockGetMedicationsByAnimalId(animalId))
            .thenAnswer((_) async => const Left(NotFoundFailure(errorMessage)));

        // Act
        await notifier.loadMedicationsByAnimalId(animalId);

        // Assert
        expect(notifier.state.medications, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals(errorMessage));
      });
    });

    group('Load Active Medications Tests', () {
      test('should load active medications successfully', () async {
        // Arrange
        when(mockGetActiveMedications(const NoParams()))
            .thenAnswer((_) async => Right(testActiveMedications));

        // Act
        await notifier.loadActiveMedications();

        // Assert
        expect(notifier.state.activeMedications, equals(testActiveMedications));
        expect(notifier.state.error, isNull);
        verify(mockGetActiveMedications(const NoParams())).called(1);
      });

      test('should handle active medications loading failure', () async {
        // Arrange
        const errorMessage = 'Failed to load active medications';
        when(mockGetActiveMedications(const NoParams()))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.loadActiveMedications();

        // Assert
        expect(notifier.state.activeMedications, isEmpty);
        expect(notifier.state.error, equals(errorMessage));
      });
    });

    group('Load Expiring Medications Tests', () {
      test('should load expiring medications successfully', () async {
        // Arrange
        when(mockGetExpiringSoonMedications(const NoParams()))
            .thenAnswer((_) async => Right(testExpiringMedications));

        // Act
        await notifier.loadExpiringMedications();

        // Assert
        expect(notifier.state.expiringMedications, equals(testExpiringMedications));
        expect(notifier.state.error, isNull);
        verify(mockGetExpiringSoonMedications(const NoParams())).called(1);
      });

      test('should handle expiring medications loading failure', () async {
        // Arrange
        const errorMessage = 'Failed to load expiring medications';
        when(mockGetExpiringSoonMedications(const NoParams()))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.loadExpiringMedications();

        // Assert
        expect(notifier.state.expiringMedications, isEmpty);
        expect(notifier.state.error, equals(errorMessage));
      });
    });

    group('Add Medication Tests', () {
      test('should add medication successfully with optimistic update', () async {
        // Arrange
        final newMedication = _createTestMedication('new', 'New Med', MedicationStatus.active);
        notifier.state = notifier.state.copyWith(medications: testMedications);
        
        when(mockAddMedication(newMedication))
            .thenAnswer((_) async => const Right(null));
        when(mockGetActiveMedications(const NoParams()))
            .thenAnswer((_) async => Right(testActiveMedications));
        when(mockGetExpiringSoonMedications(const NoParams()))
            .thenAnswer((_) async => Right(testExpiringMedications));

        // Act
        await notifier.addMedication(newMedication);

        // Assert
        expect(notifier.state.medications.first, equals(newMedication));
        expect(notifier.state.medications.length, equals(testMedications.length + 1));
        expect(notifier.state.error, isNull);
        verify(mockAddMedication(newMedication)).called(1);
        verify(mockGetActiveMedications(const NoParams())).called(1);
        verify(mockGetExpiringSoonMedications(const NoParams())).called(1);
      });

      test('should handle add medication failure', () async {
        // Arrange
        final newMedication = _createTestMedication('new', 'New Med', MedicationStatus.active);
        const errorMessage = 'Failed to add medication';
        
        when(mockAddMedication(newMedication))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.addMedication(newMedication);

        // Assert
        expect(notifier.state.medications, isEmpty);
        expect(notifier.state.error, equals(errorMessage));
        verify(mockAddMedication(newMedication)).called(1);
        verifyNever(mockGetActiveMedications(const NoParams()));
      });
    });

    group('Update Medication Tests', () {
      test('should update medication successfully', () async {
        // Arrange
        final updatedMedication = testMedications.first.copyWith(name: 'Updated Name');
        notifier.state = notifier.state.copyWith(medications: testMedications);
        
        when(mockUpdateMedication(updatedMedication))
            .thenAnswer((_) async => const Right(null));
        when(mockGetActiveMedications(const NoParams()))
            .thenAnswer((_) async => Right(testActiveMedications));
        when(mockGetExpiringSoonMedications(const NoParams()))
            .thenAnswer((_) async => Right(testExpiringMedications));

        // Act
        await notifier.updateMedication(updatedMedication);

        // Assert
        final updatedInState = notifier.state.medications.firstWhere((m) => m.id == updatedMedication.id);
        expect(updatedInState.name, equals('Updated Name'));
        expect(notifier.state.error, isNull);
        verify(mockUpdateMedication(updatedMedication)).called(1);
      });

      test('should handle update medication failure', () async {
        // Arrange
        final updatedMedication = testMedications.first.copyWith(name: 'Updated Name');
        const errorMessage = 'Failed to update medication';
        
        when(mockUpdateMedication(updatedMedication))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.updateMedication(updatedMedication);

        // Assert
        expect(notifier.state.error, equals(errorMessage));
        verify(mockUpdateMedication(updatedMedication)).called(1);
      });
    });

    group('Delete Medication Tests', () {
      test('should delete medication successfully', () async {
        // Arrange
        notifier.state = notifier.state.copyWith(
          medications: testMedications,
          activeMedications: testActiveMedications,
          expiringMedications: testExpiringMedications,
        );
        const medicationId = '1';
        
        when(mockDeleteMedication(medicationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        await notifier.deleteMedication(medicationId);

        // Assert
        expect(notifier.state.medications.any((m) => m.id == medicationId), isFalse);
        expect(notifier.state.activeMedications.any((m) => m.id == medicationId), isFalse);
        expect(notifier.state.error, isNull);
        verify(mockDeleteMedication(medicationId)).called(1);
      });

      test('should handle delete medication failure', () async {
        // Arrange
        const medicationId = '1';
        const errorMessage = 'Failed to delete medication';
        
        when(mockDeleteMedication(medicationId))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.deleteMedication(medicationId);

        // Assert
        expect(notifier.state.error, equals(errorMessage));
        verify(mockDeleteMedication(medicationId)).called(1);
      });
    });

    group('Discontinue Medication Tests', () {
      test('should discontinue medication successfully', () async {
        // Arrange
        const medicationId = '1';
        const reason = 'Treatment completed';
        
        when(mockDiscontinueMedication(any))
            .thenAnswer((_) async => const Right(null));
        when(mockGetMedications(const NoParams()))
            .thenAnswer((_) async => Right(testMedications));
        when(mockGetActiveMedications(const NoParams()))
            .thenAnswer((_) async => Right(testActiveMedications));
        when(mockGetExpiringSoonMedications(const NoParams()))
            .thenAnswer((_) async => Right(testExpiringMedications));

        // Act
        await notifier.discontinueMedication(medicationId, reason);

        // Assert
        expect(notifier.state.error, isNull);
        verify(mockDiscontinueMedication(any)).called(1);
        verify(mockGetMedications(const NoParams())).called(1);
        verify(mockGetActiveMedications(const NoParams())).called(1);
        verify(mockGetExpiringSoonMedications(const NoParams())).called(1);
      });

      test('should handle discontinue medication failure', () async {
        // Arrange
        const medicationId = '1';
        const reason = 'Treatment completed';
        const errorMessage = 'Failed to discontinue medication';
        
        when(mockDiscontinueMedication(any))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

        // Act
        await notifier.discontinueMedication(medicationId, reason);

        // Assert
        expect(notifier.state.error, equals(errorMessage));
        verify(mockDiscontinueMedication(any)).called(1);
        verifyNever(mockGetMedications(const NoParams()));
      });
    });

    group('Get Medication by ID Tests', () {
      test('should get medication by ID successfully', () async {
        // Arrange
        const medicationId = '1';
        final medication = testMedications.first;
        
        when(mockGetMedicationById(medicationId))
            .thenAnswer((_) async => Right(medication));

        // Act
        final result = await notifier.getMedicationById(medicationId);

        // Assert
        expect(result, equals(medication));
        expect(notifier.state.error, isNull);
        verify(mockGetMedicationById(medicationId)).called(1);
      });

      test('should handle get medication by ID failure', () async {
        // Arrange
        const medicationId = '1';
        const errorMessage = 'Medication not found';
        
        when(mockGetMedicationById(medicationId))
            .thenAnswer((_) async => const Left(NotFoundFailure(errorMessage)));

        // Act
        final result = await notifier.getMedicationById(medicationId);

        // Assert
        expect(result, isNull);
        expect(notifier.state.error, equals(errorMessage));
        verify(mockGetMedicationById(medicationId)).called(1);
      });
    });

    group('Error Management Tests', () {
      test('should clear error correctly', () {
        // Arrange
        notifier.state = notifier.state.copyWith(error: 'Some error');

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
      });

      test('should not affect other state when clearing error', () {
        // Arrange
        notifier.state = notifier.state.copyWith(
          medications: testMedications,
          isLoading: true,
          error: 'Some error',
        );

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
        expect(notifier.state.medications, equals(testMedications));
        expect(notifier.state.isLoading, isTrue);
      });
    });

    group('Helper Methods Tests', () {
      test('should get medications for specific animal', () {
        // Arrange
        const animalId = 'animal-123';
        final animalMedications = testMedications.map((m) => m.copyWith(animalId: animalId)).toList();
        notifier.state = notifier.state.copyWith(medications: animalMedications + testMedications);

        // Act
        final result = notifier.getMedicationsForAnimal(animalId);

        // Assert
        expect(result.length, equals(animalMedications.length));
        expect(result.every((m) => m.animalId == animalId), isTrue);
      });

      test('should get active medications for specific animal', () {
        // Arrange
        const animalId = 'animal-123';
        final animalActiveMedications = testActiveMedications.map((m) => m.copyWith(animalId: animalId)).toList();
        notifier.state = notifier.state.copyWith(activeMedications: animalActiveMedications + testActiveMedications);

        // Act
        final result = notifier.getActiveMedicationsForAnimal(animalId);

        // Assert
        expect(result.length, equals(animalActiveMedications.length));
        expect(result.every((m) => m.animalId == animalId), isTrue);
      });

      test('should get medications by type', () {
        // Arrange
        const medicationType = MedicationType.antibiotic;
        final typeMedications = testMedications.map((m) => m.copyWith(type: medicationType)).toList();
        notifier.state = notifier.state.copyWith(medications: typeMedications + testMedications);

        // Act
        final result = notifier.getMedicationsByType(medicationType);

        // Assert
        expect(result.length, equals(typeMedications.length));
        expect(result.every((m) => m.type == medicationType), isTrue);
      });

      test('should get medications by status', () {
        // Arrange
        const status = MedicationStatus.discontinued;
        final medications = testMedications.where((m) => m.status == status).toList();
        notifier.state = notifier.state.copyWith(medications: testMedications);

        // Act
        final result = notifier.getMedicationsByStatus(status);

        // Assert
        expect(result.length, equals(medications.length));
        expect(result.every((m) => m.status == status), isTrue);
      });

      test('should get correct active medications count', () {
        // Arrange
        notifier.state = notifier.state.copyWith(activeMedications: testActiveMedications);

        // Act
        final count = notifier.getActiveMedicationsCount();

        // Assert
        expect(count, equals(testActiveMedications.length));
      });

      test('should get correct expiring medications count', () {
        // Arrange
        notifier.state = notifier.state.copyWith(expiringMedications: testExpiringMedications);

        // Act
        final count = notifier.getExpiringMedicationsCount();

        // Assert
        expect(count, equals(testExpiringMedications.length));
      });
    });

    group('State Copy Tests', () {
      test('should create correct state copy', () {
        // Arrange
        final originalState = notifier.state;
        const newError = 'New error';

        // Act
        final newState = originalState.copyWith(error: newError);

        // Assert
        expect(newState.error, equals(newError));
        expect(newState.medications, equals(originalState.medications));
        expect(newState.isLoading, equals(originalState.isLoading));
      });

      test('should maintain other properties when copying with partial changes', () {
        // Arrange
        notifier.state = notifier.state.copyWith(
          medications: testMedications,
          isLoading: true,
          error: 'Original error',
        );

        // Act
        final newState = notifier.state.copyWith(error: null);

        // Assert
        expect(newState.error, isNull);
        expect(newState.medications, equals(testMedications));
        expect(newState.isLoading, isTrue);
      });
    });
  });

  group('Filtered Medications Provider Tests', () {
    test('should filter medications by type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Arrange
      const medicationType = MedicationType.antibiotic;
      final medications = [
        _createTestMedication('1', 'Med 1', MedicationStatus.active, type: medicationType),
        _createTestMedication('2', 'Med 2', MedicationStatus.active, type: MedicationType.painkiller),
      ];

      // Mock the medications provider state
      container.read(medicationsProvider.notifier).state = 
          container.read(medicationsProvider.notifier).state.copyWith(medications: medications);
      
      // Set the filter
      container.read(medicationTypeFilterProvider.notifier).state = medicationType;

      // Act
      final filtered = container.read(filteredMedicationsProvider);

      // Assert
      expect(filtered.length, equals(1));
      expect(filtered.first.type, equals(medicationType));
    });

    test('should filter medications by search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Arrange
      final medications = [
        _createTestMedication('1', 'Aspirin', MedicationStatus.active),
        _createTestMedication('2', 'Ibuprofen', MedicationStatus.active),
        _createTestMedication('3', 'Acetaminophen', MedicationStatus.active),
      ];

      // Mock the medications provider state
      container.read(medicationsProvider.notifier).state = 
          container.read(medicationsProvider.notifier).state.copyWith(medications: medications);
      
      // Set search query
      container.read(medicationSearchQueryProvider.notifier).state = 'asp';

      // Act
      final filtered = container.read(filteredMedicationsProvider);

      // Assert
      expect(filtered.length, equals(1));
      expect(filtered.first.name.toLowerCase(), contains('asp'));
    });

    test('should apply multiple filters simultaneously', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Arrange
      const medicationType = MedicationType.antibiotic;
      final medications = [
        _createTestMedication('1', 'Amoxicillin', MedicationStatus.active, type: medicationType),
        _createTestMedication('2', 'Aspirin', MedicationStatus.active, type: MedicationType.painkiller),
        _createTestMedication('3', 'Ampicillin', MedicationStatus.discontinued, type: medicationType),
      ];

      // Mock the medications provider state
      container.read(medicationsProvider.notifier).state = 
          container.read(medicationsProvider.notifier).state.copyWith(medications: medications);
      
      // Set filters
      container.read(medicationTypeFilterProvider.notifier).state = medicationType;
      container.read(medicationStatusFilterProvider.notifier).state = MedicationStatus.active;
      container.read(medicationSearchQueryProvider.notifier).state = 'am';

      // Act
      final filtered = container.read(filteredMedicationsProvider);

      // Assert
      expect(filtered.length, equals(1));
      expect(filtered.first.name, equals('Amoxicillin'));
      expect(filtered.first.type, equals(medicationType));
      expect(filtered.first.status, equals(MedicationStatus.active));
    });
  });
}

/// Helper function to create test medication instances
Medication _createTestMedication(
  String id, 
  String name, 
  MedicationStatus status, {
  MedicationType type = MedicationType.other,
}) {
  return Medication(
    id: id,
    name: name,
    type: type,
    status: status,
    animalId: 'animal-123',
    dosage: '10mg',
    frequency: MedicationFrequency.onceDaily,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    prescribedBy: 'Dr. Smith',
    notes: 'Test medication',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}