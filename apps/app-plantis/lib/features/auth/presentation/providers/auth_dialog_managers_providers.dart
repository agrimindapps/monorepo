import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// Injects SharedPreferences from GetIt to ensure singleton pattern
@riverpod
CredentialsPersistenceManager credentialsPersistenceManager(
  CredentialsPersistenceManagerRef ref,
) {
  final prefs = GetIt.instance<SharedPreferences>();
  return CredentialsPersistenceManager(prefs: prefs);
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
