import 'package:gasometer_drift/core/di/injection.dart' as local_di;
import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/add_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/update_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/presentation/pages/add_maintenance_page.dart';
import 'package:gasometer_drift/features/receipt/domain/services/receipt_image_service.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:gasometer_drift/core/services/storage/firebase_storage_service.dart'
    as app_storage;
import 'package:gasometer_drift/features/image/domain/services/image_sync_service.dart';
import 'package:core/core.dart'
    hide AuthState, AuthStatus, UserEntity, FirebaseStorageService;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Manual Mocks
class MockGetVehicleById extends GetVehicleById {
  MockGetVehicleById() : super(MockVehicleRepository());

  @override
  Future<Either<Failure, VehicleEntity>> call(
      GetVehicleByIdParams params) async {
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

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockImageCompressionService extends Mock
    implements ImageCompressionService {}

class MockFirebaseStorageService extends Mock
    implements app_storage.FirebaseStorageService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockImageSyncService extends Mock implements ImageSyncService {}

class MockReceiptImageService extends ReceiptImageService {
  MockReceiptImageService()
      : super(
          MockImageCompressionService(),
          MockFirebaseStorageService(),
          MockConnectivityService(),
          MockImageSyncService(),
        );
}

class MockAddMaintenanceRecord extends AddMaintenanceRecord {
  MockAddMaintenanceRecord() : super(MockMaintenanceRepository());
}

class MockUpdateMaintenanceRecord extends UpdateMaintenanceRecord {
  MockUpdateMaintenanceRecord() : super(MockMaintenanceRepository());
}

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

class MockAuth extends Auth {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      currentUser: UserEntity(
        id: 'test_user',
        email: 'test@test.com',
        displayName: 'Test User',
        type: UserType.registered,
        isEmailVerified: true,
        createdAt: DateTime(2024),
      ),
      isAuthenticated: true,
    );
  }
}

void main() {
  final getIt = local_di.getIt;

  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<GetVehicleById>(() => MockGetVehicleById());
    getIt.registerLazySingleton<ReceiptImageService>(
        () => MockReceiptImageService());
    getIt.registerLazySingleton<AddMaintenanceRecord>(
        () => MockAddMaintenanceRecord());
    getIt.registerLazySingleton<UpdateMaintenanceRecord>(
        () => MockUpdateMaintenanceRecord());
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
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.text('Manutenção'), findsOneWidget);
    expect(find.text('Tipo de Manutenção *'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets(
      'AddMaintenancePage shows validation errors and focuses on first error',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => MockAuth()),
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
    final textFieldFinder =
        find.descendant(of: textFields.first, matching: find.byType(TextField));
    final textField = tester.widget<TextField>(textFieldFinder);

    // Verify it is the Title field
    expect(textField.decoration?.labelText, contains('Tipo de Manutenção'));

    // Verify it has focus
    expect(textField.focusNode?.hasFocus, isTrue);
  });
}
