import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../managers/auth_dialog_manager.dart';
import '../managers/auth_submission_manager.dart';
import '../managers/credentials_persistence_manager.dart';
import '../managers/email_checker_manager.dart';
import '../managers/forgot_password_dialog_manager.dart';

part 'auth_dialog_managers_providers.g.dart';

/// Provides AuthDialogManager instance
@riverpod
AuthDialogManager authDialogManager(AuthDialogManagerRef ref) {
  return AuthDialogManager();
}

/// Provides CredentialsPersistenceManager instance
@riverpod
CredentialsPersistenceManager credentialsPersistenceManager(
  CredentialsPersistenceManagerRef ref,
) {
  return CredentialsPersistenceManager();
}

/// Provides AuthSubmissionManager instance
@riverpod
AuthSubmissionManager authSubmissionManager(AuthSubmissionManagerRef ref) {
  return AuthSubmissionManager(ref: ref);
}

/// Provides ForgotPasswordDialogManager instance
@riverpod
ForgotPasswordDialogManager forgotPasswordDialogManager(
  ForgotPasswordDialogManagerRef ref,
) {
  return ForgotPasswordDialogManager(
    onError: (message) {
      // Error handling can be provided via callbacks
    },
    onSuccess: (message) {
      // Success handling can be provided via callbacks
    },
  );
}

/// Provides EmailCheckerManager instance
@riverpod
EmailCheckerManager emailCheckerManager(EmailCheckerManagerRef ref) {
  return EmailCheckerManager();
}
