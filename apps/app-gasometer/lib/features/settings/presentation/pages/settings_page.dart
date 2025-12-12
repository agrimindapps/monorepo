import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../dialogs/feedback_dialog.dart';
import '../providers/settings_notifier.dart';
import '../providers/theme_notifier.dart';
import '../widgets/profile/profile_user_section.dart';
import '../widgets/sections/legal_section.dart';
import '../widgets/sections/new_premium_section.dart';
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
    // ref.watch(vehiclesProvider);
    ref.watch(settingsProvider);
    ref.watch(gasometerThemeProvider);

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
          // Profile Section - Only on mobile
          if (isMobile) ...[
            ProfileUserSection(onLoginTap: () => context.push('/login')),
            const SizedBox(height: 16),
          ],

          // Premium Section
          const NewPremiumSection(),
          const SizedBox(height: 16),

          // Notifications
          const NotificationSection(),
          const SizedBox(height: 16),

          // Support
          SupportSection(
            onFeedbackTap: _showFeedbackDialog,
            onRateTap: _showRateAppDialog,
          ),
          const SizedBox(height: 16),

          // Legal Section
          const LegalSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentThemeMode = ref.read(gasometerThemeProvider);

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
    ref.read(gasometerThemeProvider.notifier).setThemeMode(mode);
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

  Future<void> _showRateAppDialog() async {
    try {
      final appRatingService = ref.read(appRatingRepositoryProvider);
      final canShow = await appRatingService.canShowRatingDialog();

      if (canShow) {
        if (!mounted) return;
        final success = await appRatingService.showRatingDialog(
          context: context,
        );

        if (mounted && !success) {
          // Se não mostrou o diálogo, abrir a loja diretamente
          final storeOpened = await appRatingService.openAppStore();
          if (!storeOpened && mounted) {
            _showSnackBar('Não foi possível abrir a loja de aplicativos');
          }
        }
      } else {
        // Já avaliou ou não atingiu os critérios, abrir loja diretamente
        final storeOpened = await appRatingService.openAppStore();
        if (!storeOpened && mounted) {
          _showSnackBar('Não foi possível abrir a loja de aplicativos');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao abrir avaliação do app');
      }
    }
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
