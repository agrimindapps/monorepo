// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

import '../../../../database/gasometer_database.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import 'vehicle_drift_sync_adapter.dart';

/// POC - Proof of Concept para VehicleDriftSyncAdapter
///
/// Demonstra o ciclo completo de sincronização:
/// 1. Criar veículo local (Drift)
/// 2. Push para Firestore
/// 3. Pull mudanças remotas
/// 4. Conflict resolution
///
/// **Uso:**
/// ```dart
/// final poc = VehicleSyncPOC(
///   adapter: getIt<VehicleDriftSyncAdapter>(),
///   userId: 'user-123',
/// );
///
/// await poc.runFullCycle();
/// ```
class VehicleSyncPOC {
  VehicleSyncPOC({
    required this.adapter,
    required this.userId,
  });

  final VehicleDriftSyncAdapter adapter;
  final String userId;

  /// Executa ciclo completo de testes
  Future<void> runFullCycle() async {
    print('='.padRight(80, '='));
    print('POC: VehicleDriftSyncAdapter - Full Sync Cycle');
    print('='.padRight(80, '='));
    print('');

    // 1. Test: Create local vehicle
    print('▶ Test 1: Creating local vehicle...');
    final entity = await _createLocalVehicle();
    print('✓ Vehicle created: ${entity.brand} ${entity.model} (${entity.id})');
    print('');

    // 2. Test: Validate entity
    print('▶ Test 2: Validating entity...');
    final validationResult = adapter.validateForSync(entity);
    validationResult.fold(
      (failure) => print('✗ Validation failed: ${failure.message}'),
      (_) => print('✓ Entity is valid for sync'),
    );
    print('');

    // 3. Test: Push to Firestore
    print('▶ Test 3: Pushing dirty records to Firestore...');
    final pushResult = await adapter.pushDirtyRecords(userId);
    pushResult.fold(
      (failure) => print('✗ Push failed: ${failure.message}'),
      (result) {
        print('✓ Push successful:');
        print('  - Records pushed: ${result.recordsPushed}');
        print('  - Records failed: ${result.recordsFailed}');
        print('  - Duration: ${result.duration.inMilliseconds}ms');
        if (result.errors.isNotEmpty) {
          print('  - Errors: ${result.errors.join(", ")}');
        }
      },
    );
    print('');

    // 4. Test: Pull remote changes
    print('▶ Test 4: Pulling remote changes...');
    final pullResult = await adapter.pullRemoteChanges(userId);
    pullResult.fold(
      (failure) => print('✗ Pull failed: ${failure.message}'),
      (result) {
        print('✓ Pull successful:');
        print('  - Records pulled: ${result.recordsPulled}');
        print('  - Records updated: ${result.recordsUpdated}');
        print('  - Conflicts resolved: ${result.conflictsResolved}');
        print('  - Duration: ${result.duration.inMilliseconds}ms');
        if (result.warnings.isNotEmpty) {
          print('  - Warnings: ${result.warnings.join(", ")}');
        }
      },
    );
    print('');

    // 5. Test: Watch active vehicles (stream)
    print('▶ Test 5: Watching active vehicles (stream)...');
    final subscription = adapter.watchActiveVehicles(userId).listen((vehicles) {
      print('✓ Stream update: ${vehicles.length} active vehicles');
      for (final vehicle in vehicles) {
        print('  - ${vehicle.brand} ${vehicle.model} (${vehicle.year})');
      }
    });

    // Wait for stream updates
    await Future<void>.delayed(const Duration(seconds: 2));
    await subscription.cancel();
    print('');

    // 6. Test: License plate uniqueness check
    print('▶ Test 6: Checking license plate uniqueness...');
    final plateExists = await adapter.licensePlateExists(
      userId,
      entity.licensePlate,
    );
    print(
      plateExists
          ? '✓ License plate exists in database'
          : '✗ License plate not found',
    );
    print('');

    print('='.padRight(80, '='));
    print('POC completed successfully!');
    print('='.padRight(80, '='));
  }

  /// Cria veículo local para testes
  Future<VehicleEntity> _createLocalVehicle() async {
    final entity = VehicleEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Fusca 1974',
      brand: 'Volkswagen',
      model: 'Fusca',
      year: 1974,
      color: 'Azul',
      licensePlate: 'ABC-1234',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: 85000.0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
      version: 1,
      userId: userId,
      moduleName: 'gasometer',
    );

    // Insert into Drift
    final companion = adapter.toCompanion(entity);
    await adapter.db.into(adapter.db.vehicles).insert(companion);

    return entity;
  }

  /// Test: Simulate conflict scenario
  Future<void> testConflictResolution() async {
    print('▶ Test: Conflict Resolution Scenario...');

    // Create local version
    final localEntity = VehicleEntity(
      id: 'conflict-test-1',
      name: 'Local Version',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      color: 'Prata',
      licensePlate: 'XYZ-5678',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: 50000.0,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      isDirty: true,
      version: 2,
      userId: userId,
      moduleName: 'gasometer',
    );

    // Create remote version (newer version)
    final remoteEntity = VehicleEntity(
      id: 'conflict-test-1',
      name: 'Remote Version',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      color: 'Vermelho', // Different color
      licensePlate: 'XYZ-5678',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: 52000.0, // Different odometer
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isDirty: false,
      version: 3, // Newer version
      userId: userId,
      moduleName: 'gasometer',
    );

    // Resolve conflict
    final resolved = adapter.resolveConflict(localEntity, remoteEntity);

    print('✓ Conflict resolved:');
    print('  - Winner: ${resolved.version > localEntity.version ? "Remote" : "Local"}');
    print('  - Final version: ${resolved.version}');
    print('  - Final color: ${resolved.color}');
    print('  - Final odometer: ${resolved.currentOdometer}');
    print('');
  }

  /// Test: Error handling (invalid data)
  Future<void> testErrorHandling() async {
    print('▶ Test: Error Handling...');

    // Invalid entity (empty brand)
    final invalidEntity = VehicleEntity(
      id: 'invalid-test',
      name: 'Invalid',
      brand: '', // Empty brand (invalid)
      model: 'Test',
      year: 2020,
      color: 'Branco',
      licensePlate: 'INV-0000',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: 0.0,
      isActive: true,
      createdAt: DateTime.now(),
      isDirty: true,
      version: 1,
      userId: userId,
      moduleName: 'gasometer',
    );

    final validationResult = adapter.validateForSync(invalidEntity);
    validationResult.fold(
      (failure) {
        print('✓ Validation correctly failed: ${failure.message}');
      },
      (_) {
        print('✗ Validation should have failed but passed!');
      },
    );
    print('');
  }
}

/// Helper para executar POC standalone
Future<void> runVehicleSyncPOC({
  required GasometerDatabase db,
  required FirebaseFirestore firestore,
  required ConnectivityService connectivityService,
  required String userId,
}) async {
  final adapter = VehicleDriftSyncAdapter(
    db,
    firestore,
    connectivityService,
  );

  final poc = VehicleSyncPOC(
    adapter: adapter,
    userId: userId,
  );

  // Run all tests
  await poc.runFullCycle();
  await poc.testConflictResolution();
  await poc.testErrorHandling();
}
