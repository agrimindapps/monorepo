import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/logout_usecase.dart';
import '../managers/clear_data_dialog_manager.dart';
import '../managers/logout_dialog_manager.dart';
import 'account_providers.dart';

part 'dialog_managers_providers.g.dart';

/// ✅ REFACTORED: Providers para Dialog Managers
/// Segue DIP: Injeta dependências via Riverpod
///
/// BENEFITS:
/// ✅ DIP: Dependências injetadas, não criadas direto
/// ✅ Testable: Fácil overriding em testes
/// ✅ Centralized: Todas as dependências em um lugar
/// ✅ Type-Safe: Riverpod garante tipos

@riverpod
ClearDataDialogManager clearDataDialogManager(Ref ref) {
  final clearDataUseCase = ref.watch(clearDataUseCaseProvider);
  return ClearDataDialogManager(clearDataUseCase: clearDataUseCase);
}

@riverpod
LogoutDialogManager logoutDialogManager(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  final logoutUseCase = LogoutUseCase(repository);
  return LogoutDialogManager(logoutUseCase: logoutUseCase);
}
