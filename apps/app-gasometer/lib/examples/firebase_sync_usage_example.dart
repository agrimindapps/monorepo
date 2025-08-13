import 'package:hive/hive.dart';
import '../features/vehicles/data/models/vehicle_model.dart';

/// Example of how to use the new Firebase-sync enabled models
/// 
/// This demonstrates:
/// - Creating models with sync support
/// - Local Hive storage with automatic sync fields
/// - Firebase integration ready
/// - Conflict resolution support
class FirebaseSyncUsageExample {
  
  static Future<void> demonstrateFirebaseSyncUsage() async {
    print('🚀 Firebase Sync Usage Example\n');

    // 1. Create a new vehicle with sync support
    print('📝 Creating new vehicle...');
    final newVehicle = VehicleModel.create(
      userId: 'user_123',
      marca: 'Toyota',
      modelo: 'Corolla',
      ano: 2023,
      placa: 'ABC-1234',
      odometroInicial: 0.0,
      combustivel: 1, // Flex
      cor: 'Branco',
    );

    print('✅ Vehicle created:');
    print('  - ID: ${newVehicle.id}');
    print('  - User ID: ${newVehicle.userId}');
    print('  - Module: ${newVehicle.moduleName}');
    print('  - Is Dirty (needs sync): ${newVehicle.isDirty}');
    print('  - Collection: ${newVehicle.collectionName}');
    print('  - Valid for sync: ${newVehicle.isValidForSync}');

    // 2. Save to Hive (local storage)
    print('\n💾 Saving to local Hive storage...');
    final vehiclesBox = await Hive.openBox<VehicleModel>('vehicles_sync');
    await vehiclesBox.add(newVehicle);
    print('✅ Saved to Hive successfully');

    // 3. Demonstrate Firebase map conversion
    print('\n🔥 Firebase integration example:');
    final firebaseMap = newVehicle.toFirebaseMap();
    print('  - Firebase map created with ${firebaseMap.keys.length} fields');
    print('  - Firebase path: ${newVehicle.getFirebasePath()}');
    print('  - Timestamp fields: ${newVehicle.firebaseTimestampFields.keys.join(', ')}');

    // Show some Firebase fields
    print('  - Firebase fields:');
    firebaseMap.forEach((key, value) {
      if (!key.contains('_at') && value != null) {
        print('    $key: $value');
      }
    });

    // 4. Simulate creating from Firebase data
    print('\n📥 Simulating Firebase to local conversion...');
    final mockFirebaseData = {
      'id': 'firebase_vehicle_456',
      'user_id': 'user_123',
      'module_name': 'gasometer',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_dirty': false,
      'is_deleted': false,
      'version': 1,
      'marca': 'Honda',
      'modelo': 'Civic',
      'ano': 2022,
      'placa': 'XYZ-9876',
      'odometro_inicial': 5000.0,
      'combustivel': 0,
      'cor': 'Preto',
      'vendido': false,
      'valor_venda': 0.0,
      'odometro_atual': 15000.0,
    };

    final firebaseVehicle = VehicleModel.fromFirebaseMap(mockFirebaseData);
    print('✅ Vehicle created from Firebase data:');
    print('  - ${firebaseVehicle.marca} ${firebaseVehicle.modelo} ${firebaseVehicle.ano}');
    print('  - Synced: ${!firebaseVehicle.isDirty}');

    // 5. Demonstrate update with sync tracking
    print('\n🔄 Updating vehicle (triggers sync flag)...');
    final updatedVehicle = newVehicle.copyWith(
      odometroAtual: 1500.0,
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    print('✅ Vehicle updated:');
    print('  - New odometer: ${updatedVehicle.odometroAtual}');
    print('  - Needs sync: ${updatedVehicle.isDirty}');
    print('  - Version: ${updatedVehicle.version}');

    // 6. Demonstrate conflict resolution
    print('\n⚡ Conflict resolution example...');
    final localVersion = updatedVehicle.copyWith(
      marca: 'Toyota Local',
      version: 2,
      updatedAt: DateTime.now(),
    );

    final remoteVersion = updatedVehicle.copyWith(
      marca: 'Toyota Remote',
      version: 1,
      updatedAt: DateTime.now().subtract(Duration(minutes: 5)),
    );

    final resolved = localVersion.resolveConflictWith(remoteVersion);
    print('✅ Conflict resolved:');
    print('  - Winner: ${resolved.marca} (version ${resolved.version})');
    print('  - Can merge: ${localVersion.canMergeWith(remoteVersion)}');

    // 7. Demonstrate sync state management
    print('\n🔄 Sync state management...');
    
    // Mark as synced
    final syncedVehicle = updatedVehicle.markAsSynced();
    print('✅ Marked as synced:');
    print('  - Needs sync: ${syncedVehicle.needsSync}');
    print('  - Last sync: ${syncedVehicle.lastSyncAt}');
    print('  - Is local only: ${syncedVehicle.isLocalOnly}');

    // Mark as dirty again
    final dirtyVehicle = syncedVehicle.markAsDirty();
    print('✅ Marked as dirty:');
    print('  - Needs sync: ${dirtyVehicle.needsSync}');

    // 8. Show query methods
    print('\n🔍 Query capabilities...');
    final allVehicles = vehiclesBox.values.toList();
    final unsyncedVehicles = allVehicles.where((v) => v.needsSync).toList();
    final deletedVehicles = allVehicles.where((v) => v.isDeleted).toList();
    
    print('✅ Query results:');
    print('  - Total vehicles: ${allVehicles.length}');
    print('  - Unsynced vehicles: ${unsyncedVehicles.length}');
    print('  - Deleted vehicles: ${deletedVehicles.length}');

    // 9. Legacy compatibility
    print('\n🔄 Legacy compatibility...');
    final legacyMap = newVehicle.toMap(); // Still works
    final legacyJson = newVehicle.toJson(); // Still works
    final fromLegacyMap = VehicleModel.fromMap(legacyMap); // Still works
    
    print('✅ Legacy methods working:');
    print('  - toMap(): ${legacyMap.keys.length} fields');
    print('  - fromMap(): ${fromLegacyMap.marca} ${fromLegacyMap.modelo}');

    // Close box
    await vehiclesBox.close();

    print('\n🎉 Firebase sync integration completed successfully!');
    print('\n📋 Features demonstrated:');
    print('  ✅ Automatic sync field tracking');
    print('  ✅ Firebase map conversion');
    print('  ✅ Conflict resolution');
    print('  ✅ State management (dirty/clean)');
    print('  ✅ User/module partitioning');
    print('  ✅ Legacy compatibility');
    print('  ✅ Type-safe operations');
  }

  /// Demonstrate how to implement a sync service
  static Future<void> demonstrateSyncService() async {
    print('\n🔄 Sync Service Example\n');

    final box = await Hive.openBox<VehicleModel>('vehicles_sync');

    // Get items that need sync
    final unsyncedItems = box.values.where((v) => v.needsSync && !v.isDeleted).toList();
    final deletedItems = box.values.where((v) => v.isDeleted && v.needsSync).toList();

    print('📊 Sync Status:');
    print('  - Items to upload: ${unsyncedItems.length}');
    print('  - Items to delete: ${deletedItems.length}');

    // Simulate sync process
    for (final item in unsyncedItems) {
      print('  📤 Uploading: ${item.marca} ${item.modelo}');
      
      // Here you would:
      // 1. Convert to Firebase map: item.toFirebaseMap()
      // 2. Upload to Firebase
      // 3. Mark as synced on success
      
      final syncedItem = item.markAsSynced();
      await box.put(item.key, syncedItem);
    }

    for (final item in deletedItems) {
      print('  🗑️ Deleting from Firebase: ${item.marca} ${item.modelo}');
      
      // Here you would:
      // 1. Delete from Firebase
      // 2. Remove from local storage or mark as synced
      
      await box.delete(item.key);
    }

    await box.close();
    print('✅ Sync simulation completed');
  }
}