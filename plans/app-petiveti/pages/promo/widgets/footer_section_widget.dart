// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../politicas/petiveti_pp_page.dart';
import '../../politicas/petiveti_tc_page.dart';
import '../controllers/promo_controller.dart';
import '../models/promo_content_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class FooterSectionWidget extends StatelessWidget {
  final PromoController controller;
  final FooterContent footerContent;

  const FooterSectionWidget({
    super.key,
    required this.controller,
    required this.footerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(PromoConstants.footerPadding),
        tablet: const EdgeInsets.all(PromoConstants.footerPadding + 10),
        desktop: const EdgeInsets.all(PromoConstants.footerPadding + 20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PromoConstants.textColor,
            PromoConstants.textColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: ResponsiveHelpers.buildResponsiveLayout(
        context,
        builder: (context, constraints, breakpoint) {
          switch (breakpoint) {
            case ResponsiveBreakpoint.mobile:
              return _buildMobileLayout(context);
            case ResponsiveBreakpoint.tablet:
              return _buildTabletLayout(context);
            case ResponsiveBreakpoint.desktop:
            case ResponsiveBreakpoint.ultrawide:
              return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildLogo(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildQuickLinks(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildSocialMedia(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildContactInfo(context),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildPolicyLinks(context),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildDivider(),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: PromoConstants.itemSpacing),
                  _buildContactInfo(context),
                ],
              ),
            ),
            const SizedBox(width: PromoConstants.largeSpacing),
            Expanded(
              child: _buildQuickLinks(context),
            ),
            const SizedBox(width: PromoConstants.largeSpacing),
            Expanded(
              child: _buildSocialMedia(context),
            ),
          ],
        ),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildPolicyLinks(context),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildDivider(),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: PromoConstants.itemSpacing),
                  _buildAppDescription(context),
                  const SizedBox(height: PromoConstants.itemSpacing),
                  _buildSocialMedia(context),
                ],
              ),
            ),
            const SizedBox(width: PromoConstants.largeSpacing * 2),
            Expanded(
              flex: 2,
              child: _buildQuickLinks(context),
            ),
            const SizedBox(width: PromoConstants.largeSpacing),
            Expanded(
              flex: 2,
              child: _buildContactInfo(context),
            ),
            const SizedBox(width: PromoConstants.largeSpacing),
            Expanded(
              flex: 2,
              child: _buildLegalLinks(context),
            ),
          ],
        ),
        const SizedBox(height: PromoConstants.largeSpacing),
        _buildPolicyLinks(context),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildDivider(),
        const SizedBox(height: PromoConstants.itemSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCopyright(context),
            _buildAppVersion(context),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      crossAxisAlignment: ResponsiveHelpers.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: ResponsiveHelpers.isMobile(context)
              ? MainAxisSize.min
              : MainAxisSize.max,
          children: [
            Container(
              width: ResponsiveHelpers.getResponsiveIconSize(context, 40),
              height: ResponsiveHelpers.getResponsiveIconSize(context, 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    PromoConstants.primaryColor,
                    PromoConstants.accentColor,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(PromoConstants.iconBorderRadius),
              ),
              child: Icon(
                Icons.pets,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
                color: PromoConstants.whiteColor,
              ),
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Text(
              footerContent.appName,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: PromoConstants.whiteColor,
              ),
            ),
          ],
        ),
        if (!ResponsiveHelpers.isMobile(context)) ...[
          const SizedBox(height: PromoConstants.smallSpacing),
          Text(
            footerContent.tagline,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              color: PromoConstants.whiteColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppDescription(BuildContext context) {
    return Text(
      footerContent.description,
      style: TextStyle(
        fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
        color: PromoConstants.whiteColor.withValues(alpha: 0.8),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: ResponsiveHelpers.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Links Rápidos',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        ...footerContent.quickLinks.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PromoConstants.smallSpacing),
            child: _buildFooterLink(
              context,
              link,
              () => _handleLinkTap(link),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return Column(
      crossAxisAlignment: ResponsiveHelpers.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Redes Sociais',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        Wrap(
          spacing: PromoConstants.footerSocialIconPadding,
          runSpacing: PromoConstants.footerSocialIconPadding,
          alignment: ResponsiveHelpers.isMobile(context)
              ? WrapAlignment.center
              : WrapAlignment.start,
          children: footerContent.socialLinks.map((social) {
            return _buildSocialIcon(context, social);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: ResponsiveHelpers.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Contato',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildContactItem(
          context,
          Icons.email_outlined,
          footerContent.contactEmail,
          () => controller.launchService
              .sendEmail(email: footerContent.contactEmail),
        ),
        const SizedBox(height: PromoConstants.smallSpacing),
        _buildContactItem(
          context,
          Icons.phone_outlined,
          footerContent.contactPhone,
          () => controller.launchService
              .makePhoneCall(footerContent.contactPhone),
        ),
        const SizedBox(height: PromoConstants.smallSpacing),
        _buildContactItem(
          context,
          Icons.location_on_outlined,
          footerContent.address,
          null,
        ),
      ],
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: PromoConstants.whiteColor,
          ),
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        ...footerContent.legalLinks.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PromoConstants.smallSpacing),
            child: _buildFooterLink(
              context,
              link,
              () => _handleLinkTap(link),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooterLink(
      BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
            color: PromoConstants.whiteColor.withValues(alpha: 0.8),
            decoration: TextDecoration.underline,
            decorationColor: PromoConstants.whiteColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, String social) {
    return InkWell(
      onTap: () => _handleSocialTap(social),
      borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
      child: Container(
        width: ResponsiveHelpers.getResponsiveIconSize(context, 40),
        height: ResponsiveHelpers.getResponsiveIconSize(context, 40),
        decoration: BoxDecoration(
          color: PromoConstants.whiteColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
          border: Border.all(
            color: PromoConstants.whiteColor.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          _getSocialIcon(social),
          size: ResponsiveHelpers.getResponsiveIconSize(
              context, PromoConstants.footerSocialIconSize),
          color: PromoConstants.whiteColor,
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: ResponsiveHelpers.isMobile(context)
              ? MainAxisSize.min
              : MainAxisSize.max,
          children: [
            Icon(
              icon,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
              color: PromoConstants.whiteColor.withValues(alpha: 0.8),
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize:
                      ResponsiveHelpers.getResponsiveFontSize(context, 14),
                  color: PromoConstants.whiteColor.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            PromoConstants.whiteColor
                .withValues(alpha: PromoConstants.footerDividerOpacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      footerContent.copyright,
      style: TextStyle(
        fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
        color: PromoConstants.whiteColor.withValues(alpha: 0.6),
      ),
      textAlign: ResponsiveHelpers.isMobile(context)
          ? TextAlign.center
          : TextAlign.start,
    );
  }

  Widget _buildAppVersion(BuildContext context) {
    return Text(
      'v${footerContent.appVersion}',
      style: TextStyle(
        fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
        color: PromoConstants.whiteColor.withValues(alpha: 0.6),
        fontFamily: 'monospace',
      ),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'linkedin':
        return Icons.business;
      default:
        return Icons.link;
    }
  }

  void _handleLinkTap(String link) {
    // Simple implementation - open as external URL
    controller.launchService.openWebsite(page: link);

    // Track analytics
    PromoHelpers.debugPrint('Footer link tapped: $link');
  }

  void _handleSocialTap(String social) {
    controller.launchService.openSocialMedia(social);

    // Track analytics
    PromoHelpers.debugPrint('Social media tapped: $social');
  }

  Widget _buildPolicyLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Get.to(() => const PetiVetiPoliticaPage()),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Políticas de Privacidade',
            style: TextStyle(
              color: PromoConstants.whiteColor.withValues(alpha: 0.7),
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              decoration: TextDecoration.underline,
              decorationColor: PromoConstants.whiteColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 1,
          height: 16,
          color: PromoConstants.whiteColor.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: () => Get.to(() => const PetiVetiTermosPage()),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Termos de Uso',
            style: TextStyle(
              color: PromoConstants.whiteColor.withValues(alpha: 0.7),
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              decoration: TextDecoration.underline,
              decorationColor: PromoConstants.whiteColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
