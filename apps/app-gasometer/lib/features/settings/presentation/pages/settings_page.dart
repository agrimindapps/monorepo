import 'package:core/core.dart' ;
import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../dialogs/feedback_dialog.dart';
import '../providers/settings_notifier.dart';
import '../widgets/sections/about_section.dart';
import '../widgets/sections/account_section.dart';
import '../widgets/sections/app_section.dart';
import '../widgets/sections/legal_section.dart';
import '../widgets/sections/notification_section.dart';
import '../widgets/sections/support_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(vehiclesNotifierProvider);
    ref.watch(settingsNotifierProvider);
    ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent(context)),
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
        icon: const Icon(Icons.brightness_auto, color: Colors.white, size: 19),
        tooltip: 'Alterar tema',
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // < 768px = mobile

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AccountSection - Ocultado em tablets/desktop (> 768px)
          // Justificativa: Em telas maiores, logout é acessível via menu lateral
          if (isMobile) ...[
            AccountSection(onLogoutTap: _showLogoutDialog),
            const SizedBox(height: 24),
          ],
          const NotificationSection(),
          const SizedBox(height: 24),
          AppSection(onThemeTap: () => _showThemeDialog(context)),
          const SizedBox(height: 24),
          const LegalSection(),
          const SizedBox(height: 24),
          SupportSection(
            onHelpTap: () =>
                _showSnackBar('Central de ajuda estará disponível em breve!'),
            onFeedbackTap: _showFeedbackDialog,
            onRateTap: _showRateAppDialog,
          ),
          const SizedBox(height: 24),
          AboutSection(onVersionTap: () => _showSnackBar('GasOMeter v1.0.0')),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentThemeMode = ref.read(themeModeProvider);

    showDialog<void>(
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
        // ✅ CRÍTICO: Fechar dialog ANTES de mudar tema
        // Isso previne problemas de navegação quando o app rebuilda
        Navigator.of(context).pop();

        // ✅ Aguardar um frame antes de mudar tema
        // Garante que o dialog foi completamente removido da árvore
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onTap();
        });
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
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

    await showDialog<void>(
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
                  success
                      ? 'Obrigado pelo feedback!'
                      : 'Não foi possível abrir a avaliação',
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

  void _showFeedbackDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }
}
