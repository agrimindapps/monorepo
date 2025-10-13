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
    ref.watch(settingsNotifierProvider);

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
        child: _buildPremiumRequired(context, theme),
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
}
