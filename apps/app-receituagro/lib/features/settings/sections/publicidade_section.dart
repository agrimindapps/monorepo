import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/settings_design_tokens.dart';
import '../services/premium_service.dart';
import '../services/navigation_service.dart';
import '../widgets/section_title_widget.dart';

/// Premium/Ads section following SOLID principles
class PublicidadeSection extends StatelessWidget {
  const PublicidadeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPremiumService>(
      builder: (context, premiumService, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitleWidget(
              title: 'Publicidade & Assinaturas',
              icon: SettingsDesignTokens.adIcon,
            ),
            const SizedBox(height: 8),
            Container(
              margin: SettingsDesignTokens.sectionPadding,
              decoration: SettingsDesignTokens.getCardDecoration(context),
              child: _buildPremiumListTile(context, premiumService),
            ),
            const SizedBox(height: SettingsDesignTokens.sectionSpacing),
          ],
        );
      },
    );
  }

  Widget _buildPremiumListTile(BuildContext context, IPremiumService premiumService) {
    final theme = Theme.of(context);
    final navigationService = context.read<INavigationService>();
    
    return ListTile(
      contentPadding: SettingsDesignTokens.cardPadding,
      leading: Container(
        padding: SettingsDesignTokens.iconPadding,
        decoration: BoxDecoration(
          color: premiumService.isPremium 
              ? SettingsDesignTokens.successBackgroundColor
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
        ),
        child: Icon(
          premiumService.isPremium 
              ? SettingsDesignTokens.checkIcon
              : SettingsDesignTokens.premiumIcon,
          color: premiumService.isPremium 
              ? SettingsDesignTokens.successColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
      ),
      title: Text(
        premiumService.isPremium ? 'Premium Ativo' : 'Remover anúncios',
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        premiumService.isPremium 
            ? _getPremiumStatusText(premiumService.status)
            : 'Apoie o desenvolvimento e aproveite o app sem publicidade',
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      trailing: premiumService.isPremium 
          ? null
          : Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
      onTap: premiumService.isPremium ? null : () async {
        await _handlePremiumNavigation(context, premiumService, navigationService);
      },
    );
  }

  String _getPremiumStatusText(PremiumStatus status) {
    if (status.isTestSubscription) {
      return 'Assinatura de teste ativa';
    }
    
    if (status.expiryDate != null) {
      final daysLeft = status.expiryDate!.difference(DateTime.now()).inDays;
      if (daysLeft > 0) {
        return 'Expira em $daysLeft dias';
      } else {
        return 'Assinatura expirada';
      }
    }
    
    return 'Premium ativo';
  }

  Future<void> _handlePremiumNavigation(
    BuildContext context,
    IPremiumService premiumService,
    INavigationService navigationService,
  ) async {
    try {
      // Navigate to premium page
      await premiumService.navigateToPremium();
      
      // Refresh premium status after returning
      await premiumService.checkPremiumStatus();
    } catch (e) {
      navigationService.showSnackBar(
        SettingsDesignTokens.getErrorSnackbar(
          'Erro ao acessar página premium: $e',
        ),
      );
    }
  }
}