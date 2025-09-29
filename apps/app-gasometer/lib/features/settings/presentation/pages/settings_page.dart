// ✅ REFACTORED IMPORTS: Cleaner, organized imports
import 'package:core/core.dart' hide AuthProvider;
// ✅ ThemeProvider now used from core package
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: Replace with Riverpod providers
// import 'package:provider/provider.dart' as provider;

// ThemeProvider now imported from core package (line 2)
import '../../../../core/theme/design_tokens.dart';
// TODO: Replace with Riverpod providers
// import '../providers/settings_provider.dart';
import '../widgets/account_section_widget.dart';
// Keep existing widgets for now to avoid breaking changes
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';
import 'database_inspector_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingPagePadding),
                      child: _buildContent(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Semantics(
                label: 'Seção de configurações',
                hint: 'Página principal para gerenciar preferências',
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Gerencie suas preferências',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // TODO: Replace with Riverpod ThemeProvider
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Semantics(
                label: 'Alterar tema',
                hint: 'Abre diálogo para escolher entre tema claro, escuro ou automático',
                button: true,
                onTap: () => _showThemeDialog(context),
                child: IconButton(
                  onPressed: () => _showThemeDialog(context),
                  icon: const Icon(
                    Icons.brightness_auto, // Placeholder default
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildAccountContentWithoutCard(context),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildNotificationSection(context),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildDevelopmentSection(context),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildSupportSection(context),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildInformationSection(context),
      ],
    );
  }

  /// Build account content without card wrapper
  Widget _buildAccountContentWithoutCard(BuildContext context) {
    return const AccountSectionWidget();
  }


  Widget _buildPremiumFeature(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: GasometerDesignTokens.getPremiumBackgroundWithOpacity(0.1),
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            color: GasometerDesignTokens.colorPremiumAccent,
            size: GasometerDesignTokens.iconSizeXs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildNotificationSection(BuildContext context) {
    return SettingsSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        // TODO: Replace with Riverpod SettingsProvider
        SettingsItem(
          icon: Icons.notifications_active,
          title: 'Notificações',
          subtitle: 'Receba lembretes e alertas do aplicativo',
          trailing: Semantics(
            label: 'Notificações',
            hint: 'Interruptor para ativar ou desativar todas as notificações',
            child: Switch(
              value: true, // Placeholder value
              onChanged: (value) {
                // TODO: Implement with Riverpod provider
                _showSnackBar(context, 'Funcionalidade sendo migrada para Riverpod');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    return SettingsSection(
      title: 'Desenvolvimento',
      icon: Icons.developer_mode,
      children: [
        SettingsItem(
          icon: Icons.storage,
          title: 'Inspetor de Banco',
          subtitle: 'Visualizar dados do Hive\nSharedPreferences',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const DatabaseInspectorPage(),
              ),
            );
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return SettingsSection(
      title: 'Suporte',
      icon: Icons.help,
      children: [
        SettingsItem(
          icon: Icons.help_outline,
          title: 'Central de Ajuda',
          subtitle: 'Perguntas frequentes e tutoriais',
          onTap: () {
            // Help center navigation pending
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          isFirst: true,
        ),
        SettingsItem(
          icon: Icons.email,
          title: 'Contato',
          subtitle: 'Entre em contato conosco',
          onTap: () {
            // Contact form implementation pending
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SettingsItem(
          icon: Icons.bug_report,
          title: 'Reportar Bug',
          subtitle: 'Relatar problemas ou sugestões',
          onTap: () {
            // Bug report form implementation pending
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SettingsItem(
          icon: Icons.star_rate,
          title: 'Avaliar o App',
          subtitle: 'Deixe sua avaliação na loja',
          onTap: () => _showRateAppDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInformationSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Informações',
      icon: Icons.info,
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.info_outline,
          title: 'Sobre o App',
          subtitle: 'Versão 1.0.0',
          onTap: () {
            // App info dialog implementation pending
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacityHint),
          ),
        ),
      ],
    );
  }


  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: GasometerDesignTokens.iconSizeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
              size: GasometerDesignTokens.iconSizeListItem,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático (Sistema)';
    }
  }

  void _showThemeDialog(BuildContext context) {
    // TODO: Implement with Riverpod ThemeProvider
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Funcionalidade sendo migrada para Riverpod'),
            SizedBox(height: 16),
            Text('Em breve você poderá alterar o tema novamente.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // TODO: Implement with Riverpod ThemeProvider
  // Widget _buildThemeOption(
  //   BuildContext context,
  //   ThemeProvider themeProvider,
  //   ThemeMode mode,
  //   String title,
  //   String subtitle,
  //   IconData icon,
  // ) {
  //   final isSelected = themeProvider.themeMode == mode;
    
  //   return InkWell(
  //     onTap: () {
  //       themeProvider.setThemeMode(mode);
  //       Navigator.of(context).pop();
  //     },
  //     borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: isSelected 
  //               ? Theme.of(context).colorScheme.primary
  //               : Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
  //           ),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //                     color: isSelected 
  //                       ? Theme.of(context).colorScheme.primary
  //                       : Theme.of(context).colorScheme.onSurface,
  //                   ),
  //                 ),
  //                 Text(
  //                   subtitle,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Theme.of(context).colorScheme.onSurface.withValues(alpha: GasometerDesignTokens.opacitySecondary),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (isSelected)
  //             Icon(
  //               Icons.check,
  //               color: Theme.of(context).colorScheme.primary,
  //               size: 20,
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }


  void _showRateAppDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.star_rate,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Avaliar o App',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Você está gostando do GasOMeter? Sua avaliação é muito importante para nós!',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
            // Star rating visual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 32,
                ),
              )),
            ),
            
            const SizedBox(height: 20),
            Text(
              'Avalie na loja de aplicativos e ajude outros usuários a descobrir o GasOMeter!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Talvez mais tarde',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleRateApp(context);
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Avaliar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRateApp(BuildContext context) async {
    // TODO: Replace with Riverpod SettingsProvider
    try {
      // final settingsProvider = ref.read(settingsProviderNotifier);
      // final success = await settingsProvider.handleAppRating(context);

      // Placeholder implementation
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        _showSnackBar(context, 'Funcionalidade sendo migrada para Riverpod');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Erro ao abrir a loja: $e');
      }
    }
  }
}

