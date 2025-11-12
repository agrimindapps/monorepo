import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../managers/clear_data_dialog_manager.dart';
import '../managers/logout_dialog_manager.dart';
import 'account_providers.dart';

part 'dialog_managers_providers.g.dart';

/// ✅ REFACTORED: Providers para Dialog Managers
/// Segue DIP: Injeta dependências via Riverpod
///
/// ANTES: account_actions_section usava GetIt direto
/// DEPOIS: Providers centralizam injeção de dependências
///
/// BENEFITS:
/// ✅ DIP: Dependências injetadas, não criadas direto
/// ✅ Testable: Fácil overriding em testes
/// ✅ Centralized: Todas as dependências em um lugar
/// ✅ Type-Safe: Riverpod garante tipos

@riverpod
ClearDataDialogManager clearDataDialogManager(ClearDataDialogManagerRef ref) {
  final clearDataUseCase = ref.watch(clearDataUseCaseProvider);
  return ClearDataDialogManager(clearDataUseCase: clearDataUseCase);
}

@riverpod
LogoutDialogManager logoutDialogManager(LogoutDialogManagerRef ref) {
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  return LogoutDialogManager(logoutUseCase: logoutUseCase);
}
