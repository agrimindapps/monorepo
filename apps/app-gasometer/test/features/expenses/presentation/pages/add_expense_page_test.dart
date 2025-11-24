import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/add_expense.dart';
import 'package:gasometer_drift/features/expenses/domain/usecases/update_expense.dart';
import 'package:gasometer_drift/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:gasometer_drift/features/receipt/domain/services/receipt_image_service.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:gasometer_drift/core/interfaces/i_expenses_repository.dart';
import 'package:gasometer_drift/core/services/storage/firebase_storage_service.dart'
    as app_storage;
import 'package:gasometer_drift/features/image/domain/services/image_sync_service.dart';
import 'package:core/core.dart'
    hide AuthState, AuthStatus, UserEntity, FirebaseStorageService;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

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

class MockAddExpenseUseCase extends AddExpenseUseCase {
  MockAddExpenseUseCase() : super(MockExpenseRepository());
}

class MockUpdateExpenseUseCase extends UpdateExpenseUseCase {
  MockUpdateExpenseUseCase() : super(MockExpenseRepository());
}

class MockExpenseRepository extends Mock implements IExpensesRepository {}

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
  final getIt = GetIt.instance;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<GetVehicleById>(() => MockGetVehicleById());
    getIt.registerLazySingleton<ReceiptImageService>(
        () => MockReceiptImageService());
    getIt.registerLazySingleton<AddExpenseUseCase>(
        () => MockAddExpenseUseCase());
    getIt.registerLazySingleton<UpdateExpenseUseCase>(
        () => MockUpdateExpenseUseCase());
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const AddExpensePage(vehicleId: 'test_vehicle_id'),
      ),
    );
  }

  testWidgets('AddExpensePage renders correctly', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.text('Despesa'), findsOneWidget);
    expect(find.text('Descrição da Despesa *'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets(
      'AddExpensePage shows validation errors and focuses on first error',
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
    expect(find.text('Descrição é obrigatória'), findsOneWidget);

    // Check focus
    final textFields = find.byType(TextField);
    final firstTextField = tester.widget<TextField>(textFields.first);

    expect(firstTextField.decoration?.labelText, contains('Descrição'));
    expect(firstTextField.focusNode?.hasFocus, isTrue);
  });
}
