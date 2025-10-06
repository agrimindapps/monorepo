import '../../../infrastructure/services/account_deletion_service.dart';
import '../../../shared/utils/result.dart';
import '../base_usecase.dart';

/// Use Case para exclusão de conta seguindo Clean Architecture
/// Coordena a exclusão através do AccountDeletionService
class DeleteAccountUseCase
    implements ResultUseCase<AccountDeletionResult, NoParams> {
  final AccountDeletionService _accountDeletionService;

  const DeleteAccountUseCase({
    required AccountDeletionService accountDeletionService,
  }) : _accountDeletionService = accountDeletionService;

  @override
  Future<Result<AccountDeletionResult>> call(NoParams params) async {
    return await _accountDeletionService.deleteAccount();
  }
}

/// Use Case para obter preview da exclusão de conta
/// Permite mostrar ao usuário o que será excluído antes da confirmação
class GetAccountDeletionPreviewUseCase
    implements ResultUseCase<Map<String, dynamic>, NoParams> {
  final AccountDeletionService _accountDeletionService;

  const GetAccountDeletionPreviewUseCase({
    required AccountDeletionService accountDeletionService,
  }) : _accountDeletionService = accountDeletionService;

  @override
  Future<Result<Map<String, dynamic>>> call(NoParams params) async {
    return await _accountDeletionService.getAccountDeletionPreview();
  }
}
