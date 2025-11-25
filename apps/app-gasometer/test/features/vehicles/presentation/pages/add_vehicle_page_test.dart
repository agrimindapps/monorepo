import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/vehicles/presentation/pages/add_vehicle_page.dart';
import 'package:gasometer_drift/features/vehicles/presentation/providers/vehicles_notifier.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:core/core.dart' hide AuthState, AuthStatus, UserEntity;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockVehiclesNotifier extends VehiclesNotifier {
  @override
  Future<List<VehicleEntity>> build() async {
    return [];
  }

  @override
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle) async {
    return vehicle;
  }

  @override
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}

  @override
  Future<VehicleEntity?> getVehicleById(String id) async => null;
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
  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const AddVehiclePage(),
      ),
    );
  }

  testWidgets('AddVehiclePage renders correctly', (tester) async {
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith(() => MockVehiclesNotifier()),
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    expect(find.text('Veículos'), findsOneWidget);
    expect(find.text('Marca *'), findsOneWidget);
    expect(find.text('Modelo *'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets(
      'AddVehiclePage shows validation errors and focuses on first error',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith(() => MockVehiclesNotifier()),
        authProvider.overrideWith(() => MockAuth()),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle();

    // Tap save without filling anything
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Expect validation error
    expect(find.text('Marca é obrigatória'), findsOneWidget);

    // Check focus
    // Find the TextField that corresponds to 'Marca'
    final textFields = find.byType(TextField);
    TextField? brandTextField;

    for (final widget in tester.widgetList<TextField>(textFields)) {
      if (widget.decoration?.labelText?.contains('Marca') == true) {
        brandTextField = widget;
        break;
      }
    }

    expect(brandTextField, isNotNull);
    expect(brandTextField!.focusNode?.hasFocus, isTrue);
  });
}
