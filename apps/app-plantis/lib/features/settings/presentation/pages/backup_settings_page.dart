import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/settings_providers.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsNotifierProvider);

    return Scaffold(
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
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveLayout(
        child: Consumer(
          builder: (context, ref, child) {
            // Verificação de Premium simplificada por enquanto
            const isPremium = false; // TODO: Implementar verificação de premium

            if (!isPremium) {
              return _buildPremiumRequired(context, theme);
            }

            return _buildBackupSettings(context, theme, settingsState);
          },
        ),
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 64,
              color: PlantisColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Recurso Premium',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PlantisColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'O backup na nuvem está disponível apenas para usuários Premium.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Assinar Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings(
    BuildContext context,
    ThemeData theme,
    SettingsState settingsState,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações de Backup',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Backup Automático'),
                  subtitle: const Text('Backup automático dos dados'),
                  value: settingsState.settings.backup.autoBackupEnabled,
                  onChanged: (value) {
                    // TODO: Implementar toggle de backup automático
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text('Fazer Backup Agora'),
                  subtitle: const Text('Sincronizar dados com a nuvem'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implementar backup manual
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup em desenvolvimento'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Restaurar Backup'),
                  subtitle: const Text('Restaurar dados da nuvem'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implementar restauração
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Restauração em desenvolvimento'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status do Backup',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: Text('Último Backup'),
                  subtitle: Text('Nunca realizado'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.storage,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Espaço Utilizado'),
                  subtitle: const Text('0 KB de 1 GB'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}