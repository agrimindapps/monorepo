import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/models/backup_model.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../features/premium/presentation/providers/premium_provider.dart';
import '../../../../presentation/widgets/settings_item.dart';
import '../../../../presentation/widgets/settings_section.dart';
import '../providers/backup_settings_provider.dart';
import '../widgets/backup_list_item.dart';
import '../widgets/restore_options_dialog.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<BackupSettingsProvider>(
      create: (context) => BackupSettingsProvider(
        backupService: context.read<BackupService>(),
        connectivity: context.read<Connectivity>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Backup na Nuvem',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: ResponsiveLayout(
          child: Consumer<PremiumProvider>(
            builder: (context, premiumProvider, child) {
            // Verificação de segurança: usar PremiumProvider real
            if (!premiumProvider.isPremium) {
              return _buildPremiumRequired(context);
            }

            return Consumer<BackupSettingsProvider>(
              builder: (context, provider, child) {
                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: PlantisColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status e ação rápida
                        _buildQuickActionCard(context, provider),
                        const SizedBox(height: 24),

                        // Configurações de backup
                        _buildBackupSettings(context, provider),
                        const SizedBox(height: 24),

                        // Lista de backups
                        _buildBackupsList(context, provider),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            );
            },
          ),
        ),
      ),
    );
  }

  /// Card com status e botão de backup rápido
  Widget _buildQuickActionCard(BuildContext context, BackupSettingsProvider provider) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_upload,
                    color: PlantisColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Automático',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Seus dados são protegidos na nuvem',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status do último backup
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: provider.lastBackupStatusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: provider.lastBackupStatusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    provider.lastBackupStatusIcon,
                    color: provider.lastBackupStatusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.lastBackupStatusText,
                      style: TextStyle(
                        color: provider.lastBackupStatusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progresso do backup
            if (provider.isCreatingBackup) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: provider.backupProgress,
                    backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(PlantisColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Criando backup...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(provider.backupProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PlantisColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Progresso da restauração
            if (provider.isRestoringBackup) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: provider.restoreProgress,
                    backgroundColor: PlantisColors.leaf.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(PlantisColors.leaf),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          provider.restoreStatusMessage ?? 'Restaurando backup...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(provider.restoreProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PlantisColors.leaf,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Botão de backup manual
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.canCreateBackup && !provider.isRestoringBackup ? () {
                  provider.createBackup();
                } : null,
                icon: provider.isCreatingBackup 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  provider.isCreatingBackup 
                      ? 'Criando Backup...' 
                      : provider.isRestoringBackup
                          ? 'Restaurando...'
                          : 'Fazer Backup Agora',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de configurações de backup
  Widget _buildBackupSettings(BuildContext context, BackupSettingsProvider provider) {
    return SettingsSection(
      title: 'Configurações',
      children: [
        SettingsItem(
          icon: Icons.schedule,
          title: 'Backup Automático',
          subtitle: provider.settings.autoBackupEnabled 
              ? 'Ativo - ${provider.settings.frequency.displayName}'
              : 'Desativado',
          iconColor: PlantisColors.primary,
          isFirst: true,
          trailing: Switch(
            value: provider.settings.autoBackupEnabled,
            onChanged: (value) {
              final newSettings = provider.settings.copyWith(
                autoBackupEnabled: value,
              );
              provider.updateSettings(newSettings);
            },
            activeColor: PlantisColors.primary,
          ),
          onTap: () {
            _showFrequencyDialog(context, provider);
          },
        ),
        SettingsItem(
          icon: Icons.wifi,
          title: 'Apenas no Wi-Fi',
          subtitle: provider.settings.wifiOnlyEnabled 
              ? 'Backup apenas quando conectado ao Wi-Fi'
              : 'Usar qualquer conexão de internet',
          iconColor: PlantisColors.secondary,
          trailing: Switch(
            value: provider.settings.wifiOnlyEnabled,
            onChanged: (value) {
              final newSettings = provider.settings.copyWith(
                wifiOnlyEnabled: value,
              );
              provider.updateSettings(newSettings);
            },
            activeColor: PlantisColors.primary,
          ),
        ),
        SettingsItem(
          icon: Icons.storage,
          title: 'Backups a Manter',
          subtitle: 'Manter os ${provider.settings.maxBackupsToKeep} backups mais recentes',
          iconColor: PlantisColors.accent,
          isLast: true,
          onTap: () {
            _showMaxBackupsDialog(context, provider);
          },
        ),
      ],
    );
  }

  /// Lista de backups disponíveis
  Widget _buildBackupsList(BuildContext context, BackupSettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backups Disponíveis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.backups.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum backup encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie seu primeiro backup para proteger seus dados',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...provider.backups.map((backup) => BackupListItem(
                backup: backup,
                onRestore: () => _showRestoreDialog(context, provider, backup),
                onDelete: () => _showDeleteDialog(context, provider, backup),
              )),
      ],
    );
  }

  /// Tela para usuários não premium
  Widget _buildPremiumRequired(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: PlantisColors.primaryGradient,
              ),
              child: const Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Backup na Nuvem',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Proteja seus dados com backup automático na nuvem',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PlantisColors.sun.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PlantisColors.sun.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: PlantisColors.sun,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Funcionalidade Premium Exclusiva',
                      style: TextStyle(
                        color: PlantisColors.sun,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/premium'),
              icon: const Icon(Icons.upgrade),
              label: const Text('Atualizar para Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog para escolher frequência de backup
  void _showFrequencyDialog(BuildContext context, BackupSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequência do Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BackupFrequency.values.map((frequency) {
            return RadioListTile<BackupFrequency>(
              title: Text(frequency.displayName),
              value: frequency,
              groupValue: provider.settings.frequency,
              onChanged: (value) {
                if (value != null) {
                  final newSettings = provider.settings.copyWith(frequency: value);
                  provider.updateSettings(newSettings);
                  Navigator.of(context).pop();
                }
              },
              activeColor: PlantisColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Dialog para escolher número máximo de backups
  void _showMaxBackupsDialog(BuildContext context, BackupSettingsProvider provider) {
    int selectedValue = provider.settings.maxBackupsToKeep;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Máximo de Backups'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 5, 10, 20].map((count) {
            return RadioListTile<int>(
              title: Text('$count backups'),
              subtitle: count == 3 
                  ? const Text('Recomendado para uso básico')
                  : count == 5
                      ? const Text('Padrão')
                      : null,
              value: count,
              groupValue: selectedValue,
              onChanged: (value) {
                if (value != null) {
                  selectedValue = value;
                  final newSettings = provider.settings.copyWith(
                    maxBackupsToKeep: value,
                  );
                  provider.updateSettings(newSettings);
                  Navigator.of(context).pop();
                }
              },
              activeColor: PlantisColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Dialog de confirmação de restauração
  void _showRestoreDialog(BuildContext context, BackupSettingsProvider provider, BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => RestoreOptionsDialog(
        backup: backup,
        onRestore: (options) {
          Navigator.of(context).pop();
          provider.restoreBackup(backup.id, options);
        },
      ),
    );
  }

  /// Dialog de confirmação de exclusão
  void _showDeleteDialog(BuildContext context, BackupSettingsProvider provider, BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Deletar Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja deletar este backup?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    backup.fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('Data: ${backup.formattedDate}'),
                  Text('Tamanho: ${backup.formattedSize}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteBackup(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}