import 'package:gasometer_drift/core/di/injection.dart' as local_di;
import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/odometer/domain/repositories/odometer_repository.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/add_odometer_reading.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/update_odometer_reading.dart';
import 'package:gasometer_drift/features/odometer/presentation/pages/add_odometer_page.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:core/core.dart' hide AuthState, AuthStatus, UserEntity;
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

class MockAddOdometerReading extends AddOdometerReadingUseCase {
  MockAddOdometerReading() : super(MockOdometerRepository());
}

class MockUpdateOdometerReading extends UpdateOdometerReadingUseCase {
  MockUpdateOdometerReading() : super(MockOdometerRepository());
}

class MockOdometerRepository implements OdometerRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
    getIt.registerLazySingleton<AddOdometerReadingUseCase>(() => MockAddOdometerReading());
    getIt.registerLazySingleton<UpdateOdometerReadingUseCase>(() => MockUpdateOdometerReading());
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const AddOdometerPage(vehicleId: 'test_vehicle_id'),
      ),
    );
  }

  testWidgets('AddOdometerPage renders correctly', (tester) async {
    // Set a large screen size to avoid overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.text('Odômetro'), findsWidgets);
    expect(find.text('Salvar'), findsOneWidget);
    
    // Reset screen size
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('AddOdometerPage shows validation errors and focuses on first error', (tester) async {
    // Set a large screen size to avoid overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    // Tap save without filling anything
    await tester.tap(find.text('Salvar'));
    
    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Expect validation error
    // We look for any text containing "obrigatório"
    expect(find.textContaining('obrigatório'), findsWidgets);

    // Check focus
    final textFields = find.byType(TextField);
    // We expect at least one text field (Odometer)
    expect(textFields, findsWidgets);
    
    final firstTextField = tester.widget<TextField>(textFields.first);
    
    // Verify it has focus
    expect(firstTextField.focusNode?.hasFocus, isTrue);
    
    // Reset screen size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
