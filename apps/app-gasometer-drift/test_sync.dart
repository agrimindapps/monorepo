import 'package:gasometer/core/di/injection_container_modular.dart';
import 'package:gasometer/features/odometer/data/sync/odometer_drift_sync_adapter.dart';

void main() async {
  print('🚀 Starting sync test...');

  try {
    // Initialize dependencies
    await ModularInjectionContainer.init();

    print('✅ Dependencies initialized');

    // Get the odometer sync adapter
    final odometerAdapter =
        ModularInjectionContainer.instance<OdometerDriftSyncAdapter>();
    print('✅ OdometerDriftSyncAdapter obtained: ${odometerAdapter.hashCode}');

    // Test push dirty records with a test user ID
    const testUserId = 'test_user_123';
    print('🔄 Calling pushDirtyRecords for user: $testUserId');

    final result = await odometerAdapter.pushDirtyRecords(testUserId);
    print('✅ Push result: $result');
  } catch (e, stackTrace) {
    print('❌ Error during sync test: $e');
    print('Stack trace: $stackTrace');
  }
}
