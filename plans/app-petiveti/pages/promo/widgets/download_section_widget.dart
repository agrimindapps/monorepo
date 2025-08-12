// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/pre_register_model.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/responsive_helpers.dart';

class DownloadSectionWidget extends StatelessWidget {
  final PromoController controller;
  final DownloadContent downloadContent;

  const DownloadSectionWidget({
    super.key,
    required this.controller,
    required this.downloadContent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isLaunched = controller.countdownController.isLaunched;
        
        return Container(
          padding: ResponsiveHelpers.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(PromoConstants.ctaSectionPadding / 2),
            tablet: const EdgeInsets.all(PromoConstants.ctaSectionPadding * 0.75),
            desktop: const EdgeInsets.all(PromoConstants.ctaSectionPadding),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLaunched
                  ? [PromoConstants.successColor, PromoConstants.successColor.withValues(alpha: 0.8)]
                  : [PromoConstants.primaryColor, PromoConstants.primaryColor.withValues(alpha: 0.8)],
            ),
          ),
          child: isLaunched ? _buildLaunchedSection(context) : _buildPreLaunchSection(context),
        );
      },
    );
  }

  Widget _buildPreLaunchSection(BuildContext context) {
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        switch (breakpoint) {
          case ResponsiveBreakpoint.mobile:
            return _buildMobilePreLaunchLayout(context);
          case ResponsiveBreakpoint.tablet:
            return _buildTabletPreLaunchLayout(context);
          case ResponsiveBreakpoint.desktop:
          case ResponsiveBreakpoint.ultrawide:
            return _buildDesktopPreLaunchLayout(context);
        }
      },
    );
  }

  Widget _buildMobilePreLaunchLayout(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, isLaunched: false),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildPreRegisterCard(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildFeatureHighlights(context),
      ],
    );
  }

  Widget _buildTabletPreLaunchLayout(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, isLaunched: false),
        const SizedBox(height: PromoConstants.largeSpacing),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildPreRegisterCard(context),
            ),
            const SizedBox(width: PromoConstants.largeSpacing),
            Expanded(
              flex: 3,
              child: _buildFeatureHighlights(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopPreLaunchLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, isLaunched: false, alignment: CrossAxisAlignment.start),
              const SizedBox(height: PromoConstants.largeSpacing),
              _buildFeatureHighlights(context),
            ],
          ),
        ),
        const SizedBox(width: PromoConstants.largeSpacing * 2),
        Expanded(
          flex: 1,
          child: _buildPreRegisterCard(context),
        ),
      ],
    );
  }

  Widget _buildLaunchedSection(BuildContext context) {
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        switch (breakpoint) {
          case ResponsiveBreakpoint.mobile:
            return _buildMobileLaunchedLayout(context);
          case ResponsiveBreakpoint.tablet:
            return _buildTabletLaunchedLayout(context);
          case ResponsiveBreakpoint.desktop:
          case ResponsiveBreakpoint.ultrawide:
            return _buildDesktopLaunchedLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLaunchedLayout(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, isLaunched: true),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildDownloadCards(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildStoreFeatures(context),
      ],
    );
  }

  Widget _buildTabletLaunchedLayout(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, isLaunched: true),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildDownloadCards(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildStoreFeatures(context),
      ],
    );
  }

  Widget _buildDesktopLaunchedLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, isLaunched: true, alignment: CrossAxisAlignment.start),
              const SizedBox(height: PromoConstants.largeSpacing),
              _buildStoreFeatures(context),
            ],
          ),
        ),
        const SizedBox(width: PromoConstants.largeSpacing * 2),
        Expanded(
          flex: 1,
          child: _buildDownloadCards(context),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required bool isLaunched,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Icon
        Icon(
          isLaunched ? Icons.celebration : Icons.rocket_launch,
          size: ResponsiveHelpers.getResponsiveIconSize(context, 60),
          color: PromoConstants.whiteColor,
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Title
        Text(
          isLaunched ? downloadContent.launchedTitle : downloadContent.prelaunchTitle,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.sectionTitleFontSize,
            ),
            fontWeight: PromoConstants.sectionTitleWeight,
            color: PromoConstants.whiteColor,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        
        // Subtitle
        if ((isLaunched ? downloadContent.launchedSubtitle : downloadContent.prelaunchSubtitle).isNotEmpty) ...[
          const SizedBox(height: PromoConstants.itemSpacing),
          Text(
            isLaunched ? downloadContent.launchedSubtitle : downloadContent.prelaunchSubtitle,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.sectionSubtitleFontSize,
              ),
              color: PromoConstants.whiteColor.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }

  Widget _buildPreRegisterCard(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(PromoConstants.ctaCardPadding),
        tablet: const EdgeInsets.all(PromoConstants.ctaCardPadding + 4),
        desktop: const EdgeInsets.all(PromoConstants.ctaCardPadding + 8),
      ),
      decoration: BoxDecoration(
        color: PromoConstants.whiteColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: PromoConstants.primaryColor,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
              ),
              const SizedBox(width: PromoConstants.smallSpacing),
              Expanded(
                child: Text(
                  'Seja o primeiro a saber!',
                  style: TextStyle(
                    fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: PromoConstants.textColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PromoConstants.itemSpacing),
          
          // Description
          Text(
            'Cadastre-se para receber uma notificação assim que o PetiVeti estiver disponível na sua plataforma preferida.',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              color: PromoConstants.textColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: PromoConstants.largeSpacing),
          
          // Pre-register button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.showPreRegisterDialog(),
              icon: Icon(
                Icons.email_outlined,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
              ),
              label: Text(
                'Cadastrar Email',
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                  fontWeight: PromoConstants.buttonWeight,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: PromoConstants.whiteColor,
                backgroundColor: PromoConstants.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: PromoConstants.ctaButtonHorizontalPadding,
                  vertical: PromoConstants.ctaButtonPadding + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
                ),
                elevation: PromoConstants.buttonElevation,
              ),
            ),
          ),
          
          const SizedBox(height: PromoConstants.itemSpacing),
          
          // Privacy note
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                color: PromoConstants.textColor.withValues(alpha: 0.5),
              ),
              const SizedBox(width: PromoConstants.smallSpacing),
              Expanded(
                child: Text(
                  'Seus dados estão seguros conosco',
                  style: TextStyle(
                    fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                    color: PromoConstants.textColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCards(BuildContext context) {
    return ResponsiveHelpers.buildResponsive(
      context,
      mobile: Column(
        children: [
          _buildDownloadCard(context, 'Android', Icons.android, true),
          const SizedBox(height: PromoConstants.itemSpacing),
          _buildDownloadCard(context, 'iOS', Icons.apple, false),
        ],
      ),
      tablet: Row(
        children: [
          Expanded(child: _buildDownloadCard(context, 'Android', Icons.android, true)),
          const SizedBox(width: PromoConstants.itemSpacing),
          Expanded(child: _buildDownloadCard(context, 'iOS', Icons.apple, false)),
        ],
      ),
      desktop: Column(
        children: [
          _buildDownloadCard(context, 'Android', Icons.android, true),
          const SizedBox(height: PromoConstants.itemSpacing),
          _buildDownloadCard(context, 'iOS', Icons.apple, false),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(BuildContext context, String platform, IconData icon, bool isAndroid) {
    return Container(
      padding: const EdgeInsets.all(PromoConstants.ctaCardPadding),
      decoration: BoxDecoration(
        color: PromoConstants.whiteColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Platform icon
          Container(
            width: ResponsiveHelpers.getResponsiveIconSize(context, 60),
            height: ResponsiveHelpers.getResponsiveIconSize(context, 60),
            decoration: BoxDecoration(
              color: isAndroid ? const Color(0xFF3DDC84) : const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
            ),
            child: Icon(
              icon,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 32),
              color: PromoConstants.whiteColor,
            ),
          ),
          
          const SizedBox(height: PromoConstants.itemSpacing),
          
          // Platform name
          Text(
            'Disponível para $platform',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: PromoConstants.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PromoConstants.smallSpacing),
          
          // Store name
          Text(
            isAndroid ? 'Google Play Store' : 'Apple App Store',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              color: PromoConstants.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PromoConstants.largeSpacing),
          
          // Download button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.launchService.openAppStore(
                isAndroid ? AppPlatform.android : AppPlatform.ios,
              ),
              icon: Icon(
                Icons.download,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
              ),
              label: Text(
                'Baixar Agora',
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                  fontWeight: PromoConstants.buttonWeight,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: PromoConstants.whiteColor,
                backgroundColor: isAndroid ? const Color(0xFF3DDC84) : const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: PromoConstants.ctaButtonHorizontalPadding,
                  vertical: PromoConstants.ctaButtonPadding + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
                ),
                elevation: PromoConstants.buttonElevation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por que escolher o PetiVeti?',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        ...downloadContent.highlights.map((highlight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PromoConstants.smallSpacing),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
                  color: PromoConstants.whiteColor,
                ),
                const SizedBox(width: PromoConstants.smallSpacing),
                Expanded(
                  child: Text(
                    highlight,
                    style: TextStyle(
                      fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                      color: PromoConstants.whiteColor.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStoreFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos disponíveis:',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        Wrap(
          spacing: PromoConstants.itemSpacing,
          runSpacing: PromoConstants.smallSpacing,
          children: downloadContent.storeFeatures.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PromoConstants.defaultPadding,
                vertical: PromoConstants.smallSpacing,
              ),
              decoration: BoxDecoration(
                color: PromoConstants.whiteColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
                border: Border.all(
                  color: PromoConstants.whiteColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                  color: PromoConstants.whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
