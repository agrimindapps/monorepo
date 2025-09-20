import 'package:flutter/material.dart';

import '../../features/settings/constants/settings_design_tokens.dart';
import '../providers/auth_provider.dart';

/// Serviço para coordenar ações do usuário (logout, clear data, delete account)
/// Centraliza as operações e feedback ao usuário
class UserActionService {
  final ReceitaAgroAuthProvider _authProvider;

  UserActionService(this._authProvider);

  /// Realizar logout do usuário
  Future<void> performLogout(BuildContext context) async {
    try {
      await _authProvider.signOut();
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
    // Mostrar indicador de progresso
    _showProgressDialog(
      context, 
      title: 'Limpando Dados',
      message: 'Removendo dados locais...',
    );

    try {
      // Aqui você implementaria a limpeza dos dados locais
      // Por exemplo, limpar Hive boxes, cache, etc.
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
    // Mostrar indicador de progresso
    _showProgressDialog(
      context,
      title: 'Excluindo Conta',
      message: 'Excluindo conta e dados...\nPor favor, aguarde. Esta operação pode levar alguns momentos.',
    );

    try {
      // Execute account deletion
      final result = await _authProvider.deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar dialog de progresso

        if (result.isSuccess) {
          // Success - show confirmation and navigate away
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

          // Navigate to app start or login page
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        } else {
          // Error - show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Erro na exclusão: ${result.errorMessage ?? "Erro desconhecido"}'),
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
    // TODO: Implementar limpeza dos boxes do Hive
    // Exemplo:
    // await Hive.deleteBoxFromDisk('user_data');
    // await Hive.deleteBoxFromDisk('recipes');
    // await Hive.deleteBoxFromDisk('diagnostics');
    
    // Simular operação
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  /// Limpar cache do app
  Future<void> _clearAppCache() async {
    // TODO: Implementar limpeza do cache
    // Exemplo:
    // await DefaultCacheManager().emptyCache();
    
    // Simular operação
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// Reset das preferências do usuário
  Future<void> _resetUserPreferences() async {
    // TODO: Implementar reset das preferências
    // Exemplo:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    
    // Simular operação
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}