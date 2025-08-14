import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/settings_design_tokens.dart';
import '../services/navigation_service.dart';
import '../widgets/section_title_widget.dart';

/// About/Information section
class SobreSection extends StatelessWidget {
  const SobreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Mais informações',
          icon: SettingsDesignTokens.infoIcon,
        ),
        const SizedBox(height: 8),
        Container(
          margin: SettingsDesignTokens.sectionPadding,
          decoration: SettingsDesignTokens.getCardDecoration(context),
          child: Column(
            children: [
              _buildFeedbackTile(context),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildAboutTile(context),
            ],
          ),
        ),
        const SizedBox(height: SettingsDesignTokens.sectionSpacing),
      ],
    );
  }

  Widget _buildFeedbackTile(BuildContext context) {
    final theme = Theme.of(context);
    final navigationService = context.read<INavigationService>();
    
    return ListTile(
      contentPadding: SettingsDesignTokens.cardPadding,
      leading: Container(
        padding: SettingsDesignTokens.iconPadding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
        ),
        child: Icon(
          Icons.feedback_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
      ),
      title: Text(
        'Enviar feedback',
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        'Compartilhe sugestões para melhorar o aplicativo',
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () => _handleFeedback(context, navigationService),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final theme = Theme.of(context);
    final navigationService = context.read<INavigationService>();
    
    return ListTile(
      contentPadding: SettingsDesignTokens.cardPadding,
      leading: Container(
        padding: SettingsDesignTokens.iconPadding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
        ),
        child: Icon(
          SettingsDesignTokens.circleInfoIcon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
      ),
      title: Text(
        'Sobre o app',
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        'Informações sobre o aplicativo e versão',
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () => _navigateToAbout(context, navigationService),
    );
  }

  void _handleFeedback(
    BuildContext context,
    INavigationService navigationService,
  ) {
    // In a real implementation, this would open feedback form or email client
    navigationService.showSnackBar(
      SettingsDesignTokens.getSuccessSnackbar(
        'Abrindo formulário de feedback...',
      ),
    );
  }

  void _navigateToAbout(
    BuildContext context,
    INavigationService navigationService,
  ) {
    // In a real implementation, this would navigate to SobrePage/AboutPage
    navigationService.showSnackBar(
      SettingsDesignTokens.getSuccessSnackbar(
        'Navegando para página sobre...',
      ),
    );
  }
}