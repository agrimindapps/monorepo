import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget that handles the integration of data migration into the authentication flow
///
/// This widget should be used during the login process to detect and handle
/// conflicts between anonymous and account data. It provides a seamless
/// user experience for resolving data conflicts.
class MigrationIntegrationHandler extends ConsumerWidget {
  const MigrationIntegrationHandler({
    super.key,
    required this.anonymousUserId,
    required this.accountUserId,
    required this.onMigrationComplete,
    required this.onMigrationCanceled,
    this.onMigrationError,
    this.autoDetectConflicts = true,
    this.showProgressDialog = true,
  });

  /// The anonymous user ID to migrate from
  final String anonymousUserId;

  /// The account user ID to migrate to
  final String accountUserId;

  /// Callback when migration is completed successfully
  final void Function(DataMigrationResult result) onMigrationComplete;

  /// Callback when migration is canceled by user
  final VoidCallback onMigrationCanceled;

  /// Callback when migration encounters an error
  final void Function(String error)? onMigrationError;

  /// Whether to automatically detect conflicts on widget build
  final bool autoDetectConflicts;

  /// Whether to show progress dialog during migration
  final bool showProgressDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }

  /// Static method to easily integrate into authentication flow
  static Widget integrate({
    required BuildContext context,
    required String anonymousUserId,
    required String accountUserId,
    required void Function(DataMigrationResult) onComplete,
    required VoidCallback onCanceled,
    void Function(String)? onError,
  }) {
    return MigrationIntegrationHandler(
      anonymousUserId: anonymousUserId,
      accountUserId: accountUserId,
      onMigrationComplete: onComplete,
      onMigrationCanceled: onCanceled,
      onMigrationError: onError,
      autoDetectConflicts: true,
      showProgressDialog: true,
    );
  }
}
