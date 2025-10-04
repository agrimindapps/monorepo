import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO: Replace with Riverpod providers
// import '../notifiers/data_migration_notifier.dart';

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
  final Function(DataMigrationResult result) onMigrationComplete;
  
  /// Callback when migration is canceled by user
  final VoidCallback onMigrationCanceled;
  
  /// Callback when migration encounters an error
  final Function(String error)? onMigrationError;
  
  /// Whether to automatically detect conflicts on widget build
  final bool autoDetectConflicts;
  
  /// Whether to show progress dialog during migration
  final bool showProgressDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace Consumer<DataMigrationProvider> with Riverpod provider
    // final provider = ref.watch(dataMigrationProviderNotifier);
    
    // Placeholder implementation without provider dependencies
    return const SizedBox.shrink();
    
    // TODO: Implement with Riverpod providers
    // Auto-detect conflicts if enabled and not already detecting
    // if (autoDetectConflicts && !provider.isDetectingConflicts && provider.conflictResult == null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _detectConflicts(context, provider);
    //   });
    // }

    // Show conflict dialog if conflicts are detected
    // if (provider.hasConflict && provider.conflictResult != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _handleConflictDetected(context, provider);
    //   });
    // }

    // Handle migration completion
    // if (provider.migrationSuccessful && provider.migrationResult != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     onMigrationComplete(provider.migrationResult!);
    //   });
    // }

    // Handle errors
    // if (provider.hasError) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _handleError(context, provider);
    //   });
    // }

    // Show loading indicator during conflict detection
    // if (provider.isDetectingConflicts) {
    //   return const Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         CircularProgressIndicator(),
    //         SizedBox(height: 16),
    //         Text('Verificando dados existentes...'),
    //       ],
    //     ),
    //   );
    // }

    // Return empty container when not active
    // return const SizedBox.shrink();
  }

  // TODO: Implement with Riverpod providers
  // Future<void> _detectConflicts(BuildContext context, DataMigrationProvider provider) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('🔍 Auto-detecting conflicts for migration');
  //     }

  //     final success = await provider.detectConflicts(
  //       anonymousUserId: anonymousUserId,
  //       accountUserId: accountUserId,
  //     );

  //     if (!success && provider.hasError) {
  //       _handleError(context, provider);
  //     }

  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ Error in auto-conflict detection: $e');
  //     }
  //     onMigrationError?.call('Erro ao detectar conflitos: $e');
  //   }
  // }

  // TODO: Implement with Riverpod providers
  // Future<void> _handleConflictDetected(BuildContext context, DataMigrationProvider provider) async {
  //   try {
  //     if (kDebugMode) {
  //       debugPrint('⚠️ Handling detected conflict');
  //     }

  //     // Show conflict resolution dialog
  //     final choice = await provider.showConflictDialog(context);
      
  //     if (choice == null || choice == DataResolutionChoice.cancel) {
  //       if (kDebugMode) {
  //         debugPrint('🚫 User canceled migration');
  //       }
  //       onMigrationCanceled();
  //       return;
  //     }

  //     // Handle user's choice
  //     await _executeUserChoice(context, provider, choice);

  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ Error handling conflict: $e');
  //     }
  //     onMigrationError?.call('Erro ao processar conflito: $e');
  //   }
  // }

  // Future<void> _executeUserChoice(
  //   BuildContext context, 
  //   DataMigrationProvider provider, 
  //   DataResolutionChoice choice,
  // ) async {
  //   try {
  //     if (choice == DataResolutionChoice.keepAnonymousData) {
  //       // Guide user to create new account
  //       await _handleKeepAnonymousDataChoice(context);
  //       return;
  //     }

  //     // Show progress dialog if enabled
  //     if (showProgressDialog) {
  //       // Start migration execution in background
  //       _executeMigration(provider, choice);
        
  //       // Show progress dialog
  //       await provider.showProgressDialog(
  //         context: context,
  //         operationTitle: 'Processando migração de dados',
  //         allowCancel: false,
  //       );
  //     } else {
  //       // Execute migration without progress dialog
  //       final success = await provider.executeResolution(choice: choice);
  //       if (!success) {
  //         _handleError(context, provider);
  //       }
  //     }

  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ Error executing user choice: $e');
  //     }
  //     onMigrationError?.call('Erro ao executar escolha: $e');
  //   }
  // }

  // Future<void> _executeMigration(
  //   DataMigrationProvider provider, 
  //   DataResolutionChoice choice,
  // ) async {
  //   await provider.executeResolution(choice: choice);
  // }

  Future<void> _handleKeepAnonymousDataChoice(BuildContext context) async {
    try {
      if (kDebugMode) {
        debugPrint('📝 Handling keep anonymous data choice');
      }

      // Show dialog guiding user to create new account
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Criar Nova Conta'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Para manter seus dados anônimos, você precisará criar uma nova conta.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Após criar a conta, seus dados atuais serão vinculados à nova conta.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onMigrationCanceled();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAccountCreation(context);
              },
              child: const Text('Criar Conta'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling keep anonymous data: $e');
      }
      onMigrationError?.call('Erro ao processar opção: $e');
    }
  }

  void _navigateToAccountCreation(BuildContext context) {
    // Navigate to account creation screen
    // This would typically navigate to a sign-up page
    // Implementation depends on your app's navigation structure
    
    if (kDebugMode) {
      debugPrint('🚀 Navigating to account creation');
    }
    
    // Example: Navigator.pushNamed(context, '/sign-up');
    // For now, we'll call the completion callback with a special result
    onMigrationComplete(const DataMigrationResult(
      success: true,
      choiceExecuted: DataResolutionChoice.keepAnonymousData,
      message: 'Redirecionando para criação de nova conta',
    ));
  }

  // TODO: Implement with Riverpod providers
  // void _handleError(BuildContext context, DataMigrationProvider provider) {
  //   final error = provider.error?.message ?? 'Erro desconhecido durante migração';
    
  //   if (kDebugMode) {
  //     debugPrint('❌ Handling migration error: $error');
  //   }

  //   onMigrationError?.call(error);
    
  //   // Also show error dialog to user
  //   showDialog<void>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Erro na Migração'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(Icons.error, color: Colors.red, size: 48),
  //           const SizedBox(height: 16),
  //           Text(error),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             provider.resetState();
  //             onMigrationCanceled();
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Static method to easily integrate into authentication flow
  static Widget integrate({
    required BuildContext context,
    required String anonymousUserId,
    required String accountUserId,
    required Function(DataMigrationResult) onComplete,
    required VoidCallback onCanceled,
    Function(String)? onError,
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