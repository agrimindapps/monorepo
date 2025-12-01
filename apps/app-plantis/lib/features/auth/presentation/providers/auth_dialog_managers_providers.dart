import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../managers/auth_dialog_manager.dart';
import '../managers/auth_submission_manager.dart';
import '../managers/credentials_persistence_manager.dart';
import '../managers/email_checker_manager.dart';
import '../managers/forgot_password_dialog_manager.dart';

part 'auth_dialog_managers_providers.g.dart';

/// Provides AuthDialogManager instance
@riverpod
AuthDialogManager authDialogManager(Ref ref) {
  return AuthDialogManager();
}

/// Provides CredentialsPersistenceManager instance
/// Injects SharedPreferences to ensure singleton pattern
@riverpod
CredentialsPersistenceManager credentialsPersistenceManager(
  Ref ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CredentialsPersistenceManager(prefs: prefs);
}

/// Provides AuthSubmissionManager instance
@riverpod
AuthSubmissionManager authSubmissionManager(Ref ref) {
  return AuthSubmissionManager(ref: ref);
}

/// Provides ForgotPasswordDialogManager instance
@riverpod
ForgotPasswordDialogManager forgotPasswordDialogManager(
  Ref ref,
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
EmailCheckerManager emailCheckerManager(Ref ref) {
  return EmailCheckerManager();
}
