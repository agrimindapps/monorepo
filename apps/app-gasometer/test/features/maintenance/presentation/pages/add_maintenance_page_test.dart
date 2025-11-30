import 'package:core/core.dart'
    hide AuthState, AuthStatus, UserEntity, FirebaseStorageService;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/maintenance/presentation/pages/add_maintenance_page.dart';

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
      child: const MaterialApp(
        home: AddMaintenancePage(vehicleId: 'test_vehicle_id'),
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
