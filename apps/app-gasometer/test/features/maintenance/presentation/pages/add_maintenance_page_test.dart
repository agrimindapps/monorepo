import 'package:gasometer_drift/core/di/injection.dart' as local_di;
import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer_drift/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/add_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/update_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/presentation/pages/add_maintenance_page.dart';
import 'package:gasometer_drift/features/receipt/domain/repositories/receipt_repository.dart';
import 'package:gasometer_drift/features/receipt/domain/services/receipt_image_service.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:core/core.dart' hide AuthState, AuthStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Manual Mocks
class MockGetVehicleById extends GetVehicleById {
  MockGetVehicleById() : super(MockVehicleRepository());
  
  @override
  Future<Either<Failure, VehicleEntity>> call(GetVehicleByIdParams params) async {
    return Right(VehicleEntity(
      id: 'test_vehicle_id',
      userId: 'test_user',
      name: 'Test Car',
      brand: 'Test Brand',
      model: 'Test Model',
      year: 2020,
      color: 'White',
      licensePlate: 'ABC1234',
      type: VehicleType.car,
      supportedFuels: [],
      currentOdometer: 10000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

class MockVehicleRepository implements VehicleRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReceiptImageService extends ReceiptImageService {
  MockReceiptImageService() : super(MockReceiptRepository(), MockStorageService());
}

class MockReceiptRepository implements ReceiptRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockStorageService implements StorageService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAddMaintenanceRecord extends AddMaintenanceRecord {
  MockAddMaintenanceRecord() : super(MockMaintenanceRepository());
}

class MockUpdateMaintenanceRecord extends UpdateMaintenanceRecord {
  MockUpdateMaintenanceRecord() : super(MockMaintenanceRepository());
}

class MockMaintenanceRepository implements MaintenanceRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final getIt = local_di.getIt;

  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<GetVehicleById>(() => MockGetVehicleById());
    getIt.registerLazySingleton<ReceiptImageService>(() => MockReceiptImageService());
    getIt.registerLazySingleton<AddMaintenanceRecord>(() => MockAddMaintenanceRecord());
    getIt.registerLazySingleton<UpdateMaintenanceRecord>(() => MockUpdateMaintenanceRecord());
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const AddMaintenancePage(vehicleId: 'test_vehicle_id'),
      ),
    );
  }

  testWidgets('AddMaintenancePage renders correctly', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(ref)..state = const AuthState(status: AuthStatus.authenticated, userId: 'test_user')),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.text('Manutenção'), findsOneWidget);
    expect(find.text('Tipo de Manutenção *'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets('AddMaintenancePage shows validation errors and focuses on first error', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(ref)..state = const AuthState(status: AuthStatus.authenticated, userId: 'test_user')),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    // Tap save without filling anything
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Expect validation error
    expect(find.text('Tipo de manutenção é obrigatório'), findsOneWidget);

    // Check focus
    final textFields = find.byType(TextFormField);
    final firstTextField = tester.widget<TextFormField>(textFields.first);
    
    // Verify it is the Title field
    expect(firstTextField.decoration?.labelText, contains('Tipo de Manutenção'));
    
    // Verify it has focus
    expect(firstTextField.focusNode?.hasFocus, isTrue);
  });
}
