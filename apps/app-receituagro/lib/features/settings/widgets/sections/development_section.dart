import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/settings_design_tokens.dart';
import '../../presentation/pages/data_inspector_page.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Development tools section (debug mode only)
/// Provides testing and debugging functionality
class DevelopmentSection extends StatelessWidget {
  const DevelopmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!EnvironmentConfig.isDebugMode) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Desenvolvimento',
          icon: SettingsDesignTokens.devIcon,
          showIcon: true,
        ),
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.analytics,
                iconColor: Colors.green.shade600,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                title: 'Testar Analytics',
                subtitle: 'Enviar evento de teste',
                onTap: () => _testAnalytics(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.bug_report,
                iconColor: Colors.green.shade600,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                title: 'Testar Crashlytics',
                subtitle: 'Enviar erro de teste',
                onTap: () => _testCrashlytics(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.verified_user,
                iconColor: Colors.green.shade600,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                title: 'Gerar Licença Teste',
                subtitle: 'Ativa licença premium por 30 dias',
                onTap: () => _generateTestLicense(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.no_accounts,
                iconColor: Colors.green.shade600,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                title: 'Remover Licença Teste',
                subtitle: 'Remove licença premium ativa',
                onTap: () => _removeTestLicense(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.storage,
                iconColor: Colors.green.shade600,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                title: 'Inspetor de Dados',
                subtitle: 'Visualizar e gerenciar dados locais',
                onTap: () => _openDataInspector(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _testAnalytics(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    
    try {
      final success = await provider.testAnalytics();
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getSuccessSnackbar(
              '📊 Evento de Analytics enviado com sucesso!',
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar(
              provider.error ?? 'Erro no Analytics',
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar('Erro no Analytics: $e'),
        );
      }
    }
  }

  Future<void> _testCrashlytics(BuildContext context) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Testar Crashlytics'),
          ],
        ),
        content: const Text(
          'Isso irá enviar um erro de teste para o Firebase Crashlytics. Continuar?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Testar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final provider = context.read<SettingsProvider>();
      
      try {
        final success = await provider.testCrashlytics();
        
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SettingsDesignTokens.getSuccessSnackbar(
                '🐛 Erro de teste enviado para Crashlytics!',
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SettingsDesignTokens.getErrorSnackbar(
                provider.error ?? 'Erro no Crashlytics',
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar('Erro no Crashlytics: $e'),
          );
        }
      }
    }
  }

  Future<void> _generateTestLicense(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    
    try {
      final success = await provider.generateTestLicense();
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getSuccessSnackbar(
              SettingsDesignTokens.testSubscriptionSuccess,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar(
              provider.error ?? SettingsDesignTokens.testSubscriptionError,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar('$e'),
        );
      }
    }
  }

  Future<void> _removeTestLicense(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Remover Licença Teste'),
          ],
        ),
        content: const Text(
          'Isso irá remover a licença premium de teste. Todas as funcionalidades premium serão desabilitadas. Continuar?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final provider = context.read<SettingsProvider>();
      
      try {
        final success = await provider.removeTestLicense();
        
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(SettingsDesignTokens.testSubscriptionRemoved),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SettingsDesignTokens.getErrorSnackbar(
                provider.error ?? SettingsDesignTokens.removeSubscriptionError,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar('$e'),
          );
        }
      }
    }
  }

  Future<void> _openDataInspector(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const DataInspectorPage(),
      ),
    );
  }
}