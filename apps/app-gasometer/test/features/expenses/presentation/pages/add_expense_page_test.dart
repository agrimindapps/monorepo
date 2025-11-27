import 'package:gasometer_drift/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:gasometer_drift/features/auth/presentation/state/auth_state.dart';
import 'package:gasometer_drift/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer_drift/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:core/core.dart'
    hide AuthState, AuthStatus, UserEntity, FirebaseStorageService;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
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
