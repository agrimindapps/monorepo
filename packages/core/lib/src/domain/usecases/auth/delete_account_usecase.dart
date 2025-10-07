import '../../../infrastructure/services/account_deletion_service.dart';
import '../../../shared/utils/result.dart';
import '../base_usecase.dart';

/// A use case for account deletion, following the Clean Architecture principles.
///
/// This use case coordinates the account deletion process through the [AccountDeletionService].
class DeleteAccountUseCase
    implements ResultUseCase<AccountDeletionResult, NoParams> {
  final AccountDeletionService _accountDeletionService;

  /// Creates a new instance of [DeleteAccountUseCase].
  ///
  /// [_accountDeletionService] The service responsible for handling the account deletion logic.
  const DeleteAccountUseCase({
    required AccountDeletionService accountDeletionService,
  }) : _accountDeletionService = accountDeletionService;

  @override
  Future<Result<AccountDeletionResult>> call(NoParams params) async {
    return await _accountDeletionService.deleteAccount();
  }
}

/// A use case to get a preview of the account deletion.
///
/// This allows showing the user what will be deleted before confirming the action.
class GetAccountDeletionPreviewUseCase
    implements ResultUseCase<Map<String, dynamic>, NoParams> {
  final AccountDeletionService _accountDeletionService;

  /// Creates a new instance of [GetAccountDeletionPreviewUseCase].
  ///
  /// [_accountDeletionService] The service responsible for providing the deletion preview.
  const GetAccountDeletionPreviewUseCase({
    required AccountDeletionService accountDeletionService,
  }) : _accountDeletionService = accountDeletionService;

  @override
  Future<Result<Map<String, dynamic>>> call(NoParams params) async {
    return await _accountDeletionService.getAccountDeletionPreview();
  }
}
