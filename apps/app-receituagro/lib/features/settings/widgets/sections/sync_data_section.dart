import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/auth_provider.dart';
import '../../constants/settings_design_tokens.dart';

/// Seção simplificada de sincronização de dados na ProfilePage
/// Mostra como um item de lista simples com ícone de sincronização
class SyncDataSection extends ConsumerStatefulWidget {
  const SyncDataSection({super.key});

  @override
  ConsumerState<SyncDataSection> createState() => _SyncDataSectionState();
}

class _SyncDataSectionState extends ConsumerState<SyncDataSection> {
  bool _isSyncing = false;
  String _lastSyncText = 'Há 2 horas';

  /// Executa sincronização manual
  Future<void> _performManualSync() async {
    if (_isSyncing) return;

    // Get AuthProvider from DI (ChangeNotifier - not yet migrated to Riverpod)
    final authProvider = di.sl<ReceitaAgroAuthProvider>();

    if (!authProvider.isAuthenticated) {
      _showMessage('Faça login para sincronizar seus dados', isError: true);
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      // Usar sincronização real do AuthProvider
      final success = await authProvider.forceSyncUserData();

      if (mounted) {
        setState(() {
          _lastSyncText = success ? 'Agora mesmo' : _lastSyncText;
          _isSyncing = false;
        });

        if (success) {
          _showMessage('Sincronização concluída com sucesso!');
        } else {
          _showMessage('Falha na sincronização. Tente novamente.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        _showMessage('Erro na sincronização: $e', isError: true);
      }
    }
  }

  /// Mostra mensagem para o usuário
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get AuthProvider from DI (ChangeNotifier - not yet migrated to Riverpod)
    final authProvider = di.sl<ReceitaAgroAuthProvider>();

    // Listen to changes using ListenableBuilder
    return ListenableBuilder(
      listenable: authProvider,
      builder: (context, child) {
        // Só mostra seção para usuários autenticados
        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
          return const SizedBox.shrink();
        }

        return _buildSyncCard(context, theme);
      },
    );
  }

  Widget _buildSyncCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _isSyncing ? null : _performManualSync,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sync,
                  color: SettingsDesignTokens.primaryColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Título e subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sincronia de dados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Última sincronização: $_lastSyncText',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ícone de ação (sync)
              _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SettingsDesignTokens.primaryColor,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.sync,
                      size: 20,
                      color: SettingsDesignTokens.primaryColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}