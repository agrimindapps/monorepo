import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/auth/presentation/providers/auth_providers.dart'
    as auth_providers;
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart'
    as gasometer_auth;
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/add_vehicle.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/delete_vehicle.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_all_vehicles.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/search_vehicles.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/update_vehicle.dart';
import 'package:gasometer_drift/features/vehicles/presentation/providers/vehicle_services_providers.dart';
import 'package:gasometer_drift/features/vehicles/presentation/providers/vehicles_notifier.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGetAllVehicles extends Mock implements GetAllVehicles {}

class MockAddVehicle extends Mock implements AddVehicle {}

class MockUpdateVehicle extends Mock implements UpdateVehicle {}

class MockDeleteVehicle extends Mock implements DeleteVehicle {}

class MockGetVehicleById extends Mock implements GetVehicleById {}

class MockSearchVehicles extends Mock implements SearchVehicles {}

class MockUserEntity extends Mock implements gasometer_auth.UserEntity {}

// Fakes
class FakeVehicleEntity extends Fake implements VehicleEntity {}

class FakeAddVehicleParams extends Fake implements AddVehicleParams {}

class FakeUpdateVehicleParams extends Fake implements UpdateVehicleParams {}

class FakeDeleteVehicleParams extends Fake implements DeleteVehicleParams {}

void main() {
  late MockGetAllVehicles mockGetAllVehicles;
  late MockAddVehicle mockAddVehicle;
  late MockUpdateVehicle mockUpdateVehicle;
  late MockDeleteVehicle mockDeleteVehicle;
  late MockGetVehicleById mockGetVehicleById;
  late MockSearchVehicles mockSearchVehicles;
  late MockUserEntity mockUser;

  setUpAll(() {
    registerFallbackValue(FakeVehicleEntity());
    registerFallbackValue(FakeAddVehicleParams());
    registerFallbackValue(FakeUpdateVehicleParams());
    registerFallbackValue(FakeDeleteVehicleParams());
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetAllVehicles = MockGetAllVehicles();
    mockAddVehicle = MockAddVehicle();
    mockUpdateVehicle = MockUpdateVehicle();
    mockDeleteVehicle = MockDeleteVehicle();
    mockGetVehicleById = MockGetVehicleById();
    mockSearchVehicles = MockSearchVehicles();
    mockUser = MockUserEntity();

    when(() => mockUser.id).thenReturn('user-123');
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        auth_providers.currentUserProvider.overrideWithValue(mockUser),
        getAllVehiclesProvider.overrideWithValue(mockGetAllVehicles),
        addVehicleProvider.overrideWithValue(mockAddVehicle),
        updateVehicleProvider.overrideWithValue(mockUpdateVehicle),
        deleteVehicleProvider.overrideWithValue(mockDeleteVehicle),
        getVehicleByIdProvider.overrideWithValue(mockGetVehicleById),
        searchVehiclesProvider.overrideWithValue(mockSearchVehicles),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final tVehicle = VehicleEntity(
    id: '1',
    userId: 'user-123',
    name: 'My Car',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2020,
    color: 'Black',
    licensePlate: 'ABC-1234',
    type: VehicleType.car,
    supportedFuels: const [FuelType.gasoline],
    currentOdometer: 10000,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    metadata: const {},
  );

  group('VehiclesNotifier', () {
    test('build should load vehicles when user is authenticated', () async {
      // Arrange
      when(() => mockGetAllVehicles.call())
          .thenAnswer((_) async => Right([tVehicle]));

      final container = createContainer();

      // Act
      final result = await container.read(vehiclesNotifierProvider.future);

      // Assert
      expect(result, [tVehicle]);
      verify(() => mockGetAllVehicles.call()).called(1);
    });

    test('addVehicle should add vehicle and update state', () async {
      // Arrange
      when(() => mockGetAllVehicles.call())
          .thenAnswer((_) async => const Right([]));
      when(() => mockAddVehicle.call(any()))
          .thenAnswer((_) async => Right(tVehicle));

      final container = createContainer();
      // Initialize
      await container.read(vehiclesNotifierProvider.future);

      // Act
      await container
          .read(vehiclesNotifierProvider.notifier)
          .addVehicle(tVehicle);

      // Assert
      final state = await container.read(vehiclesNotifierProvider.future);
      expect(state, contains(tVehicle));
      verify(() => mockAddVehicle.call(any())).called(1);
    });

    test('deleteVehicle should remove vehicle from state', () async {
      // Arrange
      when(() => mockGetAllVehicles.call())
          .thenAnswer((_) async => Right([tVehicle]));
      when(() => mockDeleteVehicle.call(any()))
          .thenAnswer((_) async => const Right(unit));

      final container = createContainer();
      // Initialize
      await container.read(vehiclesNotifierProvider.future);

      // Act
      await container
          .read(vehiclesNotifierProvider.notifier)
          .deleteVehicle(tVehicle.id);

      // Assert
      final state = await container.read(vehiclesNotifierProvider.future);
      expect(state, isEmpty);
      verify(() => mockDeleteVehicle.call(any())).called(1);
    });
  });
}
