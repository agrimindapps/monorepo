import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/header_theme_button.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../dialogs/feedback_dialog.dart';
import '../widgets/sections/legal_section.dart';
import '../widgets/sections/notification_section.dart';
import '../widgets/sections/preferences_section.dart';
import '../widgets/sections/premium_section.dart';
import '../widgets/sections/profile_user_section.dart';
import '../widgets/sections/support_section.dart';

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
            const Padding(
              padding: EdgeInsets.all(8),
              child: PetivetiPageHeader(
                icon: Icons.settings,
                title: 'Configurações',
                subtitle: 'Gerencie suas preferências',
                semanticLabel: 'Seção de configurações',
                semanticHint: 'Página principal para gerenciar preferências',
                actions: [
                  HeaderThemeButton(),
                ],
              ),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
          const PremiumSection(),
          const SizedBox(height: 16),

          // Preferences Section (Theme, Sounds, Vibration)
          const PreferencesSection(),
          const SizedBox(height: 16),

          // Notifications
          const NotificationSection(),
          const SizedBox(height: 16),

          // Support
          SupportSection(
            onFeedbackTap: _showFeedbackDialog,
            onRateTap: _showRateAppDialog,
            onHelpTap: _launchHelpUrl,
            onContactTap: _launchSupportEmail,
          ),
          const SizedBox(height: 16),

          // Legal Section
          const LegalSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  Future<void> _showRateAppDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avaliar o PetiVeti'),
        content: const Text(
          'Você está gostando do PetiVeti? Sua avaliação nos ajuda muito!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora Não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Avaliar'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abrindo loja de aplicativos...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://petiveti.com/ajuda');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'suporte@petiveti.com',
      query: 'subject=Suporte PetiVeti',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
