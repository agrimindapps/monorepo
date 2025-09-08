import 'package:core/core.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/services/data_cleaner_service.dart';
import '../../../../core/services/data_generator_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';
import '../widgets/account_section_widget.dart';
import '../providers/settings_provider.dart';
import 'database_inspector_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
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
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configurações',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Gerencie suas preferências',
                  style: const TextStyle(
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
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Semantics(
                  label: 'Alterar tema',
                  hint: 'Abre diálogo para escolher entre tema claro, escuro ou automático. Atualmente: ${_getThemeDescription(themeProvider.themeMode)}',
                  button: true,
                  onTap: () => _showThemeDialog(context, themeProvider),
                  child: IconButton(
                    onPressed: () => _showThemeDialog(context, themeProvider),
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                        ? Icons.brightness_2
                        : themeProvider.themeMode == ThemeMode.light
                          ? Icons.brightness_high
                          : Icons.brightness_auto,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const AccountSectionWidget(),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildAppearanceSection(context),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildNotificationSection(context),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildDevelopmentSection(context),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildSupportSection(context),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildInformationSection(context),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Conta',
      icon: Icons.person,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: GasometerDesignTokens.iconSizeXxl,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Faça login em sua conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse recursos avançados, sincronize seus\ndados e mantenha suas informações seguras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Navigate to login - feature pending
                    _showSnackBar(context, 'Funcionalidade em desenvolvimento');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: GasometerDesignTokens.iconSizeButton - 2),
                      SizedBox(width: 8),
                      Text('Fazer Login', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: GasometerDesignTokens.colorPremiumAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: GasometerDesignTokens.iconSizeListItem,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GasOMeter Premium',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Desbloqueie recursos avançados e tenha a\nmelhor experiência',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPremiumFeature(
                context,
                icon: Icons.bar_chart,
                title: 'Relatórios Avançados',
                subtitle: 'Análises detalhadas de consumo e economia',
              ),
            ],
          ),
        ),
      ],
    );
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return SettingsSection(
      title: 'Aparência',
      icon: Icons.palette,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return SettingsItem(
              icon: Icons.brightness_6,
              title: 'Tema',
              subtitle: _getThemeDescription(themeProvider.themeMode),
              onTap: () => _showThemeDialog(context, themeProvider),
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return SettingsSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return SettingsItem(
              icon: Icons.notification_important,
              title: 'Lembretes de Manutenção',
              subtitle: 'Receba notificações para manutenções pendentes',
              trailing: Semantics(
                label: settingsProvider.notificationsEnabled
                    ? 'Lembretes de manutenção ativados'
                    : 'Lembretes de manutenção desativados',
                hint: 'Interruptor para ativar ou desativar notificações de manutenções pendentes',
                child: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: settingsProvider.isLoading
                      ? null
                      : (value) => settingsProvider.toggleNotifications(value),
                ),
              ),
            );
          },
        ),
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return SettingsItem(
              icon: Icons.local_gas_station,
              title: 'Alertas de Combustível',
              subtitle: 'Notificações sobre consumo e economia',
              trailing: Semantics(
                label: settingsProvider.fuelAlertsEnabled
                    ? 'Alertas de combustível ativados'
                    : 'Alertas de combustível desativados',
                hint: 'Interruptor para ativar ou desativar notificações sobre consumo e economia de combustível',
                child: Switch(
                  value: settingsProvider.fuelAlertsEnabled,
                  onChanged: settingsProvider.isLoading
                      ? null
                      : (value) => settingsProvider.toggleFuelAlerts(value),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    return SettingsSection(
      title: 'Desenvolvimento',
      icon: Icons.developer_mode,
      children: [
        // 🚨 Toggle GlobalErrorBoundary
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return SettingsItem(
              icon: settingsProvider.globalErrorBoundaryEnabled ? Icons.shield : Icons.shield_outlined,
              title: 'Global Error Boundary',
              subtitle: settingsProvider.globalErrorBoundaryEnabled 
                  ? 'Ativo - Captura erros globalmente'
                  : '⚠️ DESABILITADO - Erros aparecem diretamente',
              onTap: () => _showErrorBoundaryToggleDialog(context),
              trailing: Switch(
                value: settingsProvider.globalErrorBoundaryEnabled,
                onChanged: settingsProvider.isLoading ? null : (enabled) {
                  settingsProvider.toggleErrorBoundary(enabled);
                  _showRestartMessage(context);
                },
              ),
            );
          },
        ),
        SettingsItem(
          icon: Icons.science,
          title: 'Simular Dados',
          subtitle: 'Inserir dados de teste (2 veículos, 14\nmeses)',
          onTap: () => _showGenerateDataDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
          ),
        ),
        SettingsItem(
          icon: Icons.delete,
          title: 'Remover Dados',
          subtitle: 'Limpar todo o banco de dados local',
          onTap: () => _showAdvancedClearDataDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
          ),
        ),
        SettingsItem(
          icon: Icons.storage,
          title: 'Inspetor de Banco',
          subtitle: 'Visualizar dados do Hive\nSharedPreferences',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DatabaseInspectorPage(),
              ),
            );
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
            const SizedBox(height: 16),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
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

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.system,
              'Automático (Sistema)',
              'Segue a configuração do sistema',
              Icons.brightness_auto,
            ),
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.light,
              'Claro',
              'Tema claro sempre ativo',
              Icons.brightness_high,
            ),
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.dark,
              'Escuro',
              'Tema escuro sempre ativo',
              Icons.brightness_2,
            ),
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

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }


  void _showGenerateDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GenerateDataDialog(),
    );
  }

  void _showAdvancedClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ClearDataDialog(),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Dialog explicativo sobre o GlobalErrorBoundary
  void _showErrorBoundaryToggleDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  return Icon(
                    settingsProvider.globalErrorBoundaryEnabled ? Icons.shield : Icons.shield_outlined,
                    color: settingsProvider.globalErrorBoundaryEnabled ? Colors.green : Colors.orange,
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text('Global Error Boundary'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controla como erros são tratados na aplicação:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              
              // Estado Ativo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ATIVO (Recomendado)',
                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('• Captura erros globalmente'),
                        Text('• Exibe tela de erro amigável'),
                        Text('• Permite recuperação da aplicação'),
                        Text('• Usuário final não vê crashes'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Estado Desabilitado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DESABILITADO (Debug)',
                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text('⚠️ Erros aparecem diretamente'),
                        Text('• Melhor para debug/desenvolvimento'),
                        Text('• Mostra stack traces completos'),
                        Text('• App pode crashar completamente'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mudanças requerem reinicialização do app para ter efeito.',
                        style: TextStyle(fontSize: 12, color: Colors.amber[700]),
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
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  /// Mensagem de reinicialização necessária
  void _showRestartMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.restart_alt, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Configuração salva. Reinicie o app para aplicar mudanças.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
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
    try {
      final appRatingService = di.sl<IAppRatingRepository>();
      final success = await appRatingService.showRatingDialog(context: context);
      
      if (success && mounted) {
        _showSnackBar(context, 'Obrigado pelo feedback!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Erro ao abrir a loja: $e');
      }
    }
  }
}

class _GenerateDataDialog extends StatefulWidget {
  @override
  State<_GenerateDataDialog> createState() => _GenerateDataDialogState();
}

class _GenerateDataDialogState extends State<_GenerateDataDialog> {
  final _dataGenerator = DataGeneratorService.instance;
  
  int _numberOfVehicles = 2;
  int _monthsOfHistory = 14;
  bool _isGenerating = false;
  Map<String, dynamic>? _lastResult;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Gerar Dados de Teste'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta função irá gerar dados realísticos para testar a interface do aplicativo.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Configuração número de veículos
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Número de veículos:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _numberOfVehicles > 1 ? () {
                          setState(() => _numberOfVehicles--);
                        } : null,
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                      ),
                      Expanded(
                        child: Text(
                          '$_numberOfVehicles',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _numberOfVehicles < 5 ? () {
                          setState(() => _numberOfVehicles++);
                        } : null,
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Configuração meses de histórico
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Meses de histórico:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _monthsOfHistory > 6 ? () {
                          setState(() => _monthsOfHistory -= 2);
                        } : null,
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                      ),
                      Expanded(
                        child: Text(
                          '$_monthsOfHistory',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _monthsOfHistory < 24 ? () {
                          setState(() => _monthsOfHistory += 2);
                        } : null,
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Estimativa de dados
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimativa de dados a serem gerados:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEstimateRow('Veículos', '$_numberOfVehicles'),
                  _buildEstimateRow('Abastecimentos', '${_numberOfVehicles * _monthsOfHistory * 3}'),
                  _buildEstimateRow('Leituras odômetro', '${_numberOfVehicles * _monthsOfHistory * 4}'),
                  _buildEstimateRow('Despesas', '${_numberOfVehicles * _monthsOfHistory * 4}'),
                  _buildEstimateRow('Manutenções', '${(_numberOfVehicles * _monthsOfHistory * 0.4).round()}'),
                ],
              ),
            ),
            
            // Resultado da última geração
            if (_lastResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Última geração concluída:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResultRow('Veículos', '${_lastResult!['vehicles']}'),
                    _buildResultRow('Abastecimentos', '${_lastResult!['fuelRecords']}'),
                    _buildResultRow('Leituras odômetro', '${_lastResult!['odometerReadings']}'),
                    _buildResultRow('Despesas', '${_lastResult!['expenses']}'),
                    _buildResultRow('Manutenções', '${_lastResult!['maintenanceRecords']}'),
                    _buildResultRow('Tempo', '${_lastResult!['duration']}ms'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isGenerating ? null : _generateData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isGenerating
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StandardLoadingView.inline(color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Gerando...'),
                  ],
                )
              : const Text('Gerar Dados'),
        ),
      ],
    );
  }

  Widget _buildEstimateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label:',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label:',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _generateData() async {
    setState(() => _isGenerating = true);
    
    try {
      final result = await _dataGenerator.generateTestData(
        numberOfVehicles: _numberOfVehicles,
        monthsOfHistory: _monthsOfHistory,
      );
      
      setState(() {
        _lastResult = result;
        _isGenerating = false;
      });
      
      _showSnackBar(
        'Dados gerados com sucesso! '
        '${result['vehicles']} veículos, '
        '${result['fuelRecords']} abastecimentos, '
        '${result['expenses']} despesas.'
      );
      
    } on UnimplementedError {
      _showSnackBar(
        'Funcionalidade em desenvolvimento.\n'
        'O Database Inspector já está funcional para visualizar dados existentes.',
        isError: false
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      _showSnackBar('Erro ao gerar dados: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}

class _ClearDataDialog extends StatefulWidget {
  @override
  State<_ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends State<_ClearDataDialog> {
  final _dataCleaner = DataCleanerService.instance;
  
  bool _isLoading = true;
  bool _isClearing = false;
  Map<String, dynamic>? _currentStats;
  String _selectedClearType = 'all'; // 'all', 'selective'
  final Set<String> _selectedModules = {};
  Map<String, dynamic>? _lastClearResult;

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  Future<void> _loadCurrentStats() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _dataCleaner.getDataStatsBeforeCleaning();
      setState(() {
        _currentStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erro ao carregar estatísticas: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Limpar Dados'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ATENÇÃO - AÇÃO IRREVERSÍVEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta ação irá remover permanentemente os dados selecionados. '
                    'Não é possível desfazer esta operação.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_isLoading) ...[
              StandardLoadingView.initial(
                message: 'Carregando estatísticas...',
                height: 200,
              ),
            ] else if (_currentStats != null) ...[
              // Current Stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados Atuais:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatsRow('HiveBoxes', '${_currentStats!['totalBoxes']}'),
                    _buildStatsRow('Registros totais', '${_currentStats!['totalRecords']}'),
                    _buildStatsRow('Preferências app', '${_currentStats!['appSpecificPrefs']}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Clear Type Selection
              const Text(
                'Tipo de Limpeza:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              RadioListTile<String>(
                title: const Text('Limpeza Completa'),
                subtitle: const Text('Remove todos os dados da aplicação'),
                value: 'all',
                groupValue: _selectedClearType,
                onChanged: (value) {
                  setState(() => _selectedClearType = value!);
                },
              ),
              
              RadioListTile<String>(
                title: const Text('Limpeza Seletiva'),
                subtitle: const Text('Escolha módulos específicos para limpar'),
                value: 'selective',
                groupValue: _selectedClearType,
                onChanged: (value) {
                  setState(() => _selectedClearType = value!);
                },
              ),
              
              // Selective Modules (only show if selective is selected)
              if (_selectedClearType == 'selective') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecione os módulos para limpar:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      ..._dataCleaner.getModuleSummary().entries.map((entry) {
                        return CheckboxListTile(
                          title: Text(entry.key),
                          subtitle: Text(entry.value, style: const TextStyle(fontSize: 12)),
                          value: _selectedModules.contains(entry.key),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedModules.add(entry.key);
                              } else {
                                _selectedModules.remove(entry.key);
                              }
                            });
                          },
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
            
            // Last Clear Result
            if (_lastClearResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Última limpeza concluída:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResultRow('Boxes limpos', '${_lastClearResult!['totalClearedBoxes'] ?? 0}'),
                    _buildResultRow('Preferências limpas', '${_lastClearResult!['totalClearedPreferences'] ?? 0}'),
                    _buildResultRow('Erros', '${(_lastClearResult!['errors'] as List?)?.length ?? 0}'),
                    _buildResultRow('Tempo', '${_lastClearResult!['duration']}ms'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isClearing || _isLoading || !_canClear() ? null : _performClear,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: _isClearing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StandardLoadingView.inline(color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Limpando...'),
                  ],
                )
              : Text(_selectedClearType == 'all' ? 'Limpar Tudo' : 'Limpar Selecionados'),
        ),
      ],
    );
  }

  Widget _buildStatsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('• $label:', style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('• $label:', style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  bool _canClear() {
    if (_selectedClearType == 'all') return true;
    if (_selectedClearType == 'selective') return _selectedModules.isNotEmpty;
    return false;
  }

  Future<void> _performClear() async {
    // Double confirmation for destructive action
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isClearing = true);
    
    try {
      Map<String, dynamic> result;
      
      if (_selectedClearType == 'all') {
        result = await _dataCleaner.clearAllData();
        _showSnackBar(
          'Limpeza completa concluída! '
          '${result['totalClearedBoxes']} boxes e '
          '${result['totalClearedPreferences']} preferências removidas.',
        );
      } else {
        // Clear selected modules
        result = {
          'totalClearedBoxes': 0,
          'totalClearedPreferences': 0,
          'errors': <String>[],
          'duration': 0,
        };
        
        final startTime = DateTime.now();
        
        for (final module in _selectedModules) {
          final moduleResult = await _dataCleaner.clearModuleData(module);
          result['totalClearedBoxes'] += (moduleResult['clearedBoxes'] as List).length;
          if (moduleResult['errors'] != null) {
            (result['errors'] as List).addAll(moduleResult['errors'] as Iterable? ?? []);
          }
        }
        
        result['duration'] = DateTime.now().difference(startTime).inMilliseconds;
        
        _showSnackBar(
          'Limpeza seletiva concluída! '
          '${result['totalClearedBoxes']} boxes removidos de ${_selectedModules.length} módulos.',
        );
      }
      
      setState(() {
        _lastClearResult = result;
        _isClearing = false;
        _selectedModules.clear();
      });
      
      // Reload stats
      await _loadCurrentStats();
      
    } catch (e) {
      setState(() => _isClearing = false);
      _showSnackBar('Erro durante a limpeza: $e', isError: true);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: Text(
          _selectedClearType == 'all'
            ? 'Tem certeza que deseja remover TODOS os dados? Esta ação é irreversível.'
            : 'Tem certeza que deseja limpar os módulos selecionados: ${_selectedModules.join(", ")}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Colors.green,
        duration: Duration(seconds: isError ? 5 : 4),
      ),
    );
  }

}
