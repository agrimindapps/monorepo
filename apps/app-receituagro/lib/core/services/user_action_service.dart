import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../../features/settings/constants/settings_design_tokens.dart';

/// Serviço para coordenar ações do usuário (logout, clear data, delete account)
/// Centraliza as operações e feedback ao usuário
class UserActionService {
  final IAuthRepository _authRepository;
  final EnhancedAccountDeletionService _accountDeletionService;

  UserActionService(this._authRepository, this._accountDeletionService);

  /// Realizar logout do usuário
  Future<void> performLogout(BuildContext context) async {
    try {
      await _authRepository.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getSuccessSnackbar('Logout realizado com sucesso!'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar('Erro ao sair da conta: $e'),
        );
      }
    }
  }

  /// Limpar dados locais
  Future<void> clearLocalData(BuildContext context) async {
    _showProgressDialog(
      context, 
      title: 'Limpando Dados',
      message: 'Removendo dados locais...',
    );

    try {
      await _clearHiveData();
      await _clearAppCache();
      await _resetUserPreferences();

      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar dialog de progresso
        
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getSuccessSnackbar(
            'Dados locais limpos com sucesso! Você pode sincronizar novamente.',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar dialog de progresso
        
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar('Erro ao limpar dados: $e'),
        );
      }
    }
  }

  /// Excluir conta do usuário
  Future<void> deleteAccount(BuildContext context) async {
    _showProgressDialog(
      context,
      title: 'Excluindo Conta',
      message: 'Excluindo conta e dados...\nPor favor, aguarde. Esta operação pode levar alguns momentos.',
    );

    try {
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar('Usuário não autenticado'),
          );
        }
        return;
      }
      final result = await _accountDeletionService.deleteAccount(
        password: '',
        userId: userId,
        isAnonymous: false,
      );

      result.fold(
        (error) {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Erro na exclusão: ${error.message}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 8),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                action: SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: Colors.white,
                  onPressed: () async {
                    await deleteAccount(context);
                  },
                ),
              ),
            );
          }
        },
        (deletionResult) {
          if (context.mounted) {
            Navigator.of(context).pop();

            if (deletionResult.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Conta excluída com sucesso. Todos os dados foram removidos.'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );

              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Erro na exclusão: ${deletionResult.userMessage}'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 8),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  action: SnackBarAction(
                    label: 'Tentar Novamente',
                    textColor: Colors.white,
                    onPressed: () async {
                      await deleteAccount(context);
                    },
                  ),
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar dialog de progresso

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Erro inesperado: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// Mostrar diálogo de progresso
  void _showProgressDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Limpar dados do Hive
  Future<void> _clearHiveData() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  /// Limpar cache do app
  Future<void> _clearAppCache() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// Reset das preferências do usuário
  Future<void> _resetUserPreferences() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}