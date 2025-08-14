import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/settings_design_tokens.dart';
import '../services/device_service.dart';
import '../services/navigation_service.dart';
import '../widgets/section_title_widget.dart';

/// Site access section for mobile users
class SiteAccessSection extends StatelessWidget {
  const SiteAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Acessar Site',
          icon: SettingsDesignTokens.webIcon,
        ),
        const SizedBox(height: 8),
        Container(
          margin: SettingsDesignTokens.sectionPadding,
          decoration: SettingsDesignTokens.getCardDecoration(context),
          child: _buildSiteAccessListTile(context),
        ),
        const SizedBox(height: SettingsDesignTokens.sectionSpacing),
      ],
    );
  }

  Widget _buildSiteAccessListTile(BuildContext context) {
    final theme = Theme.of(context);
    final deviceService = context.read<IDeviceService>();
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
          SettingsDesignTokens.webIcon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
      ),
      title: Text(
        'App na Web',
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        SettingsDesignTokens.siteUrl,
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      trailing: Icon(
        Icons.open_in_new,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 20,
      ),
      onTap: () => _launchWebsite(context, deviceService, navigationService),
    );
  }

  Future<void> _launchWebsite(
    BuildContext context,
    IDeviceService deviceService,
    INavigationService navigationService,
  ) async {
    try {
      const url = 'https://${SettingsDesignTokens.siteUrl}';
      
      final canLaunch = await deviceService.canLaunchUrl(url);
      if (!canLaunch) {
        navigationService.showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
            'Não foi possível abrir o site',
          ),
        );
        return;
      }
      
      final launched = await deviceService.launchUrl(url);
      if (!launched) {
        navigationService.showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
            'Erro ao abrir o navegador',
          ),
        );
      }
    } catch (e) {
      navigationService.showSnackBar(
        SettingsDesignTokens.getErrorSnackbar(
          'Erro ao acessar site: $e',
        ),
      );
    }
  }
}