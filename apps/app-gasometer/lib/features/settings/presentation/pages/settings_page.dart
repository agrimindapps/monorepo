import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/providers/vehicles_provider.dart';
import '../providers/settings_notifier.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final vehiclesState = ref.watch(vehiclesProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(context),
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
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Seção de configurações',
              hint: 'Página principal para gerenciar preferências',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
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
                  SemanticText.heading(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
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
            _buildThemeToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(9),
      ),
      child: IconButton(
        onPressed: () => _showThemeDialog(context),
        icon: const Icon(
          Icons.brightness_auto,
          color: Colors.white,
          size: 19,
        ),
        tooltip: 'Alterar tema',
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAccountSection(),
          const SizedBox(height: 24),
          _buildNotificationSection(),
          const SizedBox(height: 24),
          _buildAppSection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Conta',
      icon: Icons.person,
      children: [
        _buildSettingItem(
          icon: Icons.account_circle,
          title: 'Perfil',
          subtitle: 'Gerenciar informações da conta',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
        _buildSettingItem(
          icon: Icons.logout,
          title: 'Sair',
          subtitle: 'Fazer logout da conta',
          onTap: () {
            _showLogoutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final notificationsEnabled = settingsAsync.valueOrNull?.notificationsEnabled ?? true;
    final fuelAlertsEnabled = settingsAsync.valueOrNull?.fuelAlertsEnabled ?? true;

    return _buildSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        _buildSettingItem(
          icon: Icons.notifications_active,
          title: 'Notificações Push',
          subtitle: 'Receber alertas e lembretes',
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) {
                    ref.read(settingsNotifierProvider.notifier).toggleNotifications(value);
                  },
          ),
        ),
        _buildSettingItem(
          icon: Icons.local_gas_station,
          title: 'Alertas de Combustível',
          subtitle: 'Notificações sobre abastecimento',
          trailing: Switch(
            value: fuelAlertsEnabled,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) {
                    ref.read(settingsNotifierProvider.notifier).toggleFuelAlerts(value);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return _buildSection(
      title: 'Aplicativo',
      icon: Icons.apps,
      children: [
        _buildSettingItem(
          icon: Icons.palette,
          title: 'Tema',
          subtitle: 'Escolher aparência do aplicativo',
          onTap: () => _showThemeDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.language,
          title: 'Idioma',
          subtitle: 'Português (Brasil)',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
        _buildSettingItem(
          icon: Icons.storage,
          title: 'Armazenamento',
          subtitle: 'Gerenciar dados locais',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Suporte',
      icon: Icons.help,
      children: [
        _buildSettingItem(
          icon: Icons.help_outline,
          title: 'Central de Ajuda',
          subtitle: 'Perguntas frequentes',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
        _buildSettingItem(
          icon: Icons.email,
          title: 'Contato',
          subtitle: 'Entre em contato conosco',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
        _buildSettingItem(
          icon: Icons.star_rate,
          title: 'Avaliar o App',
          subtitle: 'Deixe sua avaliação',
          onTap: () => _showRateAppDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'Sobre',
      icon: Icons.info,
      children: [
        _buildSettingItem(
          icon: Icons.info_outline,
          title: 'Versão do App',
          subtitle: '1.0.0',
          onTap: () {
            _showSnackBar('GasOMeter v1.0.0');
          },
        ),
        _buildSettingItem(
          icon: Icons.description,
          title: 'Termos de Uso',
          subtitle: 'Leia os termos de uso',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
        _buildSettingItem(
          icon: Icons.privacy_tip,
          title: 'Política de Privacidade',
          subtitle: 'Como tratamos seus dados',
          onTap: () {
            _showSnackBar('Funcionalidade em desenvolvimento');
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
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
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentThemeMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              'Automático (Sistema)',
              'Segue a configuração do sistema',
              Icons.brightness_auto,
              ThemeMode.system,
              currentThemeMode == ThemeMode.system,
              () => _changeTheme(ThemeMode.system),
            ),
            _buildThemeOption(
              'Claro',
              'Tema claro sempre ativo',
              Icons.brightness_high,
              ThemeMode.light,
              currentThemeMode == ThemeMode.light,
              () => _changeTheme(ThemeMode.light),
            ),
            _buildThemeOption(
              'Escuro',
              'Tema escuro sempre ativo',
              Icons.brightness_2,
              ThemeMode.dark,
              currentThemeMode == ThemeMode.dark,
              () => _changeTheme(ThemeMode.dark),
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

  void _changeTheme(ThemeMode mode) {
    ref.read(settingsNotifierProvider.notifier).changeTheme(mode);
    Navigator.of(context).pop();
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja fazer logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Logout realizado com sucesso');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRateAppDialog() async {
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final canShow = await notifier.canShowRating();

    if (!canShow) {
      _showSnackBar('Avaliação já foi feita recentemente');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star_rate, color: Colors.orange),
            SizedBox(width: 8),
            Text('Avaliar o App'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Você está gostando do GasOMeter? Sua avaliação é muito importante!',
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Talvez mais tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await notifier.handleAppRating(context);
              if (mounted) {
                _showSnackBar(
                  success ? 'Obrigado pelo feedback!' : 'Não foi possível abrir a avaliação',
                );
              }
            },
            icon: const Icon(Icons.star),
            label: const Text('Avaliar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}