import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/settings_design_tokens.dart';
import '../services/navigation_service.dart';
import '../widgets/section_title_widget.dart';

/// Speech to text configuration section
class SpeechToTextSection extends StatelessWidget {
  const SpeechToTextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Transcrição para Voz',
          icon: SettingsDesignTokens.speechIcon,
        ),
        const SizedBox(height: 8),
        Container(
          margin: SettingsDesignTokens.sectionPadding,
          decoration: SettingsDesignTokens.getCardDecoration(context),
          child: _buildSpeechConfigListTile(context),
        ),
        const SizedBox(height: SettingsDesignTokens.sectionSpacing),
      ],
    );
  }

  Widget _buildSpeechConfigListTile(BuildContext context) {
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
          SettingsDesignTokens.volumeIcon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
      ),
      title: Text(
        'Configurações de voz',
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        'Configure as opções de texto para fala para melhor experiência',
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () => _navigateToSpeechSettings(context, navigationService),
    );
  }

  void _navigateToSpeechSettings(
    BuildContext context,
    INavigationService navigationService,
  ) {
    // Navigate to TTS settings page
    // In a real implementation, this would navigate to TTsSettingsPage
    navigationService.showSnackBar(
      SettingsDesignTokens.getSuccessSnackbar(
        'Navegando para configurações de voz...',
      ),
    );
  }
}