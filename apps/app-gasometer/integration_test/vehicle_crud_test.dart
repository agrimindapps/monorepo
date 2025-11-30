/// Integration Test - Vehicle CRUD (Create, Read, Delete)
/// 
/// Este teste E2E simula um usuário real:
/// 1. Faz login
/// 2. Cadastra um veículo de teste
/// 3. Verifica se o veículo aparece na lista
/// 4. Exclui o veículo
/// 5. Verifica se foi removido
/// 
/// Para rodar: 
/// flutter test integration_test/vehicle_crud_test.dart
/// 
/// Para rodar em dispositivo real:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/vehicle_crud_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vehicle CRUD E2E Test', () {
    testWidgets('Cadastrar veículo, verificar na lista e excluir', (
      WidgetTester tester,
    ) async {
      // Inicia o app
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ========== PASSO 1: LOGIN ==========
      await _performLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ========== PASSO 2: NAVEGAR PARA VEÍCULOS ==========
      // O app já deve estar na página de veículos após login bem-sucedido
      // Aguarda a lista carregar
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ========== PASSO 3: ADICIONAR VEÍCULO ==========
      await _addTestVehicle(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ========== PASSO 4: VERIFICAR SE O VEÍCULO FOI CRIADO ==========
      expect(find.text('Test Brand'), findsOneWidget);
      expect(find.text('Test Model'), findsOneWidget);

      // ========== PASSO 5: EXCLUIR O VEÍCULO ==========
      await _deleteTestVehicle(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ========== PASSO 6: VERIFICAR SE O VEÍCULO FOI REMOVIDO ==========
      expect(find.text('Test Brand'), findsNothing);
      expect(find.text('Test Model'), findsNothing);
    });
  });
}

/// Realiza o login com credenciais de teste
Future<void> _performLogin(WidgetTester tester) async {
  // Procura pelo campo de email usando a Key
  final emailField = find.byKey(const Key('login_email_field'));
  if (emailField.evaluate().isNotEmpty) {
    await tester.enterText(emailField, 'lucineiy@hotmail.com');
    await tester.pumpAndSettle();

    // Procura pelo campo de senha usando a Key
    final passwordField = find.byKey(const Key('login_password_field'));
    await tester.enterText(passwordField, 'QWEqwe@123');
    await tester.pumpAndSettle();

    // Clica no botão de login usando a Key
    final loginButton = find.byKey(const Key('login_submit_button'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}

/// Adiciona um veículo de teste
Future<void> _addTestVehicle(WidgetTester tester) async {
  // Clica no FAB para adicionar veículo
  final addButton = find.byType(FloatingActionButton);
  expect(addButton, findsOneWidget);
  await tester.tap(addButton);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Preenche os campos obrigatórios usando Keys

  // Marca
  final brandField = find.byKey(const Key('vehicle_brand_field'));
  await tester.enterText(brandField, 'Test Brand');
  await tester.pumpAndSettle();

  // Modelo
  final modelField = find.byKey(const Key('vehicle_model_field'));
  await tester.enterText(modelField, 'Test Model');
  await tester.pumpAndSettle();

  // Ano - Dropdown
  final yearDropdown = find.byKey(const Key('vehicle_year_dropdown'));
  await tester.tap(yearDropdown);
  await tester.pumpAndSettle();
  // Seleciona 2023
  final year2023 = find.text('2023').last;
  await tester.tap(year2023);
  await tester.pumpAndSettle();

  // Cor
  final colorField = find.byKey(const Key('vehicle_color_field'));
  await tester.enterText(colorField, 'Branco');
  await tester.pumpAndSettle();

  // Combustível - Seleciona Gasolina
  final gasolinaChip = find.byKey(const Key('fuel_type_gasolina'));
  await tester.tap(gasolinaChip);
  await tester.pumpAndSettle();

  // Scroll para ver campos de documentação
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0, -300),
  );
  await tester.pumpAndSettle();

  // Odômetro
  final odometerField = find.byKey(const Key('vehicle_odometer_field'));
  await tester.enterText(odometerField, '50000');
  await tester.pumpAndSettle();

  // Placa
  final plateField = find.byKey(const Key('vehicle_plate_field'));
  await tester.enterText(plateField, 'ABC1D23');
  await tester.pumpAndSettle();

  // Salvar
  final saveButton = find.byKey(const Key('vehicle_save_button'));
  await tester.tap(saveButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Exclui o veículo de teste
Future<void> _deleteTestVehicle(WidgetTester tester) async {
  // Procura pelo botão de excluir no card do veículo
  final deleteButton = find.byKey(const Key('vehicle_delete_button'));
  await tester.tap(deleteButton.first);
  await tester.pumpAndSettle();

  // Confirma exclusão no dialog
  final confirmButton = find.byKey(const Key('confirm_delete_button'));
  await tester.tap(confirmButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
