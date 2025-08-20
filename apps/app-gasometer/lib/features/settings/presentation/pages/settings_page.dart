import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import 'database_inspector_page.dart';
import '../../../../core/services/data_generator_service.dart';
import '../../../../core/services/data_cleaner_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                      padding: const EdgeInsets.all(16.0),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF2C2C2E) 
          : const Color(0xFF2C2C2E),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_gas_station,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GasOMeter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Gerencie suas preferências',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => _showThemeDialog(context, themeProvider),
                      icon: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                          ? Icons.brightness_2
                          : themeProvider.themeMode == ThemeMode.light
                            ? Icons.brightness_high
                            : Icons.brightness_auto,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildAccountSection(context),
        const SizedBox(height: 24),
        _buildAppearanceSection(context),
        const SizedBox(height: 24),
        _buildNotificationSection(context),
        const SizedBox(height: 24),
        _buildDevelopmentSection(context),
        const SizedBox(height: 24),
        _buildSupportSection(context),
        const SizedBox(height: 24),
        _buildInformationSection(context),
        const SizedBox(height: 24),
        _buildLogoutButton(context),
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
            borderRadius: BorderRadius.circular(12),
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
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to login
                    _showSnackBar(context, 'Funcionalidade em desenvolvimento');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 18),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA500),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            color: const Color(0xFFFFA500).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFA500),
            size: 16,
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Aparência',
      icon: Icons.palette,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return _buildSettingsItem(
              context,
              icon: Icons.brightness_6,
              title: 'Tema',
              subtitle: _getThemeDescription(themeProvider.themeMode),
              onTap: () => _showThemeDialog(context, themeProvider),
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.notification_important,
          title: 'Lembretes de Manutenção',
          subtitle: 'Receba notificações para manutenções pendentes',
          trailing: Switch(
            value: true, // TODO: Connect to actual setting
            onChanged: (value) {
              // TODO: Implement notification toggle
            },
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.local_gas_station,
          title: 'Alertas de Combustível',
          subtitle: 'Notificações sobre consumo e economia',
          trailing: Switch(
            value: false, // TODO: Connect to actual setting
            onChanged: (value) {
              // TODO: Implement fuel alerts toggle
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Desenvolvimento',
      icon: Icons.developer_mode,
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.science,
          title: 'Simular Dados',
          subtitle: 'Inserir dados de teste (2 veículos, 14\nmeses)',
          onTap: () => _showGenerateDataDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.delete,
          title: 'Remover Dados',
          subtitle: 'Limpar todo o banco de dados local',
          onTap: () => _showAdvancedClearDataDialog(context),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        _buildSettingsItem(
          context,
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Suporte',
      icon: Icons.help,
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.help_outline,
          title: 'Central de Ajuda',
          subtitle: 'Perguntas frequentes e tutoriais',
          onTap: () {
            // TODO: Navigate to help center
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.email,
          title: 'Contato',
          subtitle: 'Entre em contato conosco',
          onTap: () {
            // TODO: Open contact form or email
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.bug_report,
          title: 'Reportar Bug',
          subtitle: 'Relatar problemas ou sugestões',
          onTap: () {
            // TODO: Open bug report form
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.star,
          title: 'Avaliar o App',
          subtitle: 'Avalie nossa experiência na loja',
          onTap: () {
            // TODO: Open app store rating
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
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
            // TODO: Show app info dialog
            _showSnackBar(context, 'Funcionalidade em desenvolvimento');
          },
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53E3E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Sair do Módulo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(16),
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

              Navigator.of(context).pop();
              // TODO: Implement data clearing
              _showSnackBar(context, 'Dados removidos com sucesso');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Módulo'),
        content: const Text(
          'Tem certeza que deseja sair? Você pode perder dados não sincronizados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout functionality
              _showSnackBar(context, 'Logout realizado com sucesso');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sair'),
          ),
        ],
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
                Expanded(
                  child: Text(
                    'Número de veículos:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
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
                Expanded(
                  child: Text(
                    'Meses de histórico:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
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
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
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
  Set<String> _selectedModules = {};
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
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
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
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando estatísticas...'),
                  ],
                ),
              ),
            ] else if (_currentStats != null) ...[
              // Current Stats
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
              Text(
                'Tipo de Limpeza:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              RadioListTile<String>(
                title: Text('Limpeza Completa'),
                subtitle: Text('Remove todos os dados da aplicação'),
                value: 'all',
                groupValue: _selectedClearType,
                onChanged: (value) {
                  setState(() => _selectedClearType = value!);
                },
              ),
              
              RadioListTile<String>(
                title: Text('Limpeza Seletiva'),
                subtitle: Text('Escolha módulos específicos para limpar'),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecione os módulos para limpar:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      ..._dataCleaner.getModuleSummary().entries.map((entry) {
                        return CheckboxListTile(
                          title: Text(entry.key),
                          subtitle: Text(entry.value, style: TextStyle(fontSize: 12)),
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
                      }).toList(),
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
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
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
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
            (result['errors'] as List).addAll(moduleResult['errors']);
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