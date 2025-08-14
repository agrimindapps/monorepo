import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/settings_design_tokens.dart';
import '../services/premium_service.dart';
import '../services/navigation_service.dart';
import '../widgets/section_title_widget.dart';

/// Development tools section - only visible in development builds
class DesenvolvimentoSection extends StatelessWidget {
  const DesenvolvimentoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPremiumService>(
      builder: (context, premiumService, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitleWidget(
              title: SettingsDesignTokens.developmentSectionTitle,
              icon: SettingsDesignTokens.devIcon,
              iconColor: SettingsDesignTokens.developmentColor,
            ),
            const SizedBox(height: 8),
            Container(
              margin: SettingsDesignTokens.sectionPadding,
              decoration: SettingsDesignTokens.getCardDecoration(context),
              child: Column(
                children: [
                  _buildGenerateTestSubscriptionTile(context, premiumService),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRemoveTestSubscriptionTile(context, premiumService),
                ],
              ),
            ),
            const SizedBox(height: SettingsDesignTokens.sectionSpacing),
          ],
        );
      },
    );
  }

  Widget _buildGenerateTestSubscriptionTile(
    BuildContext context,
    IPremiumService premiumService,
  ) {
    final navigationService = context.read<INavigationService>();
    final isTestActive = premiumService.status.isTestSubscription;
    
    return ListTile(
      contentPadding: SettingsDesignTokens.cardPadding,
      leading: Container(
        padding: SettingsDesignTokens.iconPadding,
        decoration: isTestActive 
            ? SettingsDesignTokens.getSuccessIconDecoration()
            : SettingsDesignTokens.getDevelopmentIconDecoration(),
        child: Icon(
          isTestActive 
              ? SettingsDesignTokens.checkIcon
              : SettingsDesignTokens.verifiedIcon,
          color: isTestActive 
              ? SettingsDesignTokens.successColor
              : SettingsDesignTokens.developmentColor,
          size: 24,
        ),
      ),
      title: Text(
        SettingsDesignTokens.generateTestSubscription,
        style: SettingsDesignTokens.getListTitleStyle(context),
      ),
      subtitle: Text(
        isTestActive 
            ? 'Assinatura de teste ativa'
            : SettingsDesignTokens.generateTestSubscriptionDesc,
        style: SettingsDesignTokens.getListSubtitleStyle(context),
      ),
      enabled: !isTestActive,
      onTap: isTestActive ? null : () async {
        await _generateTestSubscription(context, premiumService, navigationService);
      },
    );
  }

  Widget _buildRemoveTestSubscriptionTile(
    BuildContext context,
    IPremiumService premiumService,
  ) {
    final navigationService = context.read<INavigationService>();
    final isTestActive = premiumService.status.isTestSubscription;
    
    return ListTile(
      contentPadding: SettingsDesignTokens.cardPadding,
      leading: Container(
        padding: SettingsDesignTokens.iconPadding,
        decoration: SettingsDesignTokens.getErrorIconDecoration(),
        child: Icon(
          SettingsDesignTokens.removeIcon,
          color: SettingsDesignTokens.errorColor,
          size: 24,
        ),
      ),
      title: Text(
        SettingsDesignTokens.removeTestSubscription,
        style: SettingsDesignTokens.getListTitleStyle(context).copyWith(
          color: isTestActive ? null : Theme.of(context).disabledColor,
        ),
      ),
      subtitle: Text(
        isTestActive 
            ? SettingsDesignTokens.removeTestSubscriptionDesc
            : 'Nenhuma assinatura de teste ativa',
        style: SettingsDesignTokens.getListSubtitleStyle(context).copyWith(
          color: isTestActive 
              ? null 
              : Theme.of(context).disabledColor.withValues(alpha: 0.7),
        ),
      ),
      enabled: isTestActive,
      onTap: isTestActive ? () async {
        await _removeTestSubscription(context, premiumService, navigationService);
      } : null,
    );
  }

  Future<void> _generateTestSubscription(
    BuildContext context,
    IPremiumService premiumService,
    INavigationService navigationService,
  ) async {
    try {
      await premiumService.generateTestSubscription();
      navigationService.showSnackBar(
        SettingsDesignTokens.getSuccessSnackbar(
          SettingsDesignTokens.testSubscriptionSuccess,
        ),
      );
    } catch (e) {
      navigationService.showSnackBar(
        SettingsDesignTokens.getErrorSnackbar(
          '${SettingsDesignTokens.testSubscriptionError}: $e',
        ),
      );
    }
  }

  Future<void> _removeTestSubscription(
    BuildContext context,
    IPremiumService premiumService,
    INavigationService navigationService,
  ) async {
    try {
      await premiumService.removeTestSubscription();
      navigationService.showSnackBar(
        SettingsDesignTokens.getWarningSnackbar(
          SettingsDesignTokens.testSubscriptionRemoved,
        ),
      );
    } catch (e) {
      navigationService.showSnackBar(
        SettingsDesignTokens.getErrorSnackbar(
          '${SettingsDesignTokens.removeSubscriptionError}: $e',
        ),
      );
    }
  }
}