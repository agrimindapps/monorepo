// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../models/navigation_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/responsive_helpers.dart';

class NavigationBarWidget extends StatelessWidget {
  final PromoController controller;

  const NavigationBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ResponsiveHelpers.buildResponsiveLayout(
          context,
          builder: (context, constraints, breakpoint) {
            switch (breakpoint) {
              case ResponsiveBreakpoint.mobile:
                return _buildMobileNavigation(context);
              case ResponsiveBreakpoint.tablet:
                return _buildTabletNavigation(context);
              case ResponsiveBreakpoint.desktop:
              case ResponsiveBreakpoint.ultrawide:
                return _buildDesktopNavigation(context);
            }
          },
        );
      },
    );
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return Container(
      height: ResponsiveHelpers.getResponsiveNavBarHeight(context),
      decoration: _buildNavigationDecoration(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PromoConstants.defaultPadding),
          child: Row(
            children: [
              _buildLogo(context),
              const Spacer(),
              _buildMobileMenuButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletNavigation(BuildContext context) {
    return Container(
      height: ResponsiveHelpers.getResponsiveNavBarHeight(context),
      decoration: _buildNavigationDecoration(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PromoConstants.cardPadding),
          child: Row(
            children: [
              _buildLogo(context),
              const Spacer(),
              _buildNavigationItems(context, isCompact: true),
              const SizedBox(width: PromoConstants.itemSpacing),
              _buildCTAButton(context, isCompact: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Container(
      height: ResponsiveHelpers.getResponsiveNavBarHeight(context),
      decoration: _buildNavigationDecoration(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PromoConstants.largeSpacing),
          child: Row(
            children: [
              _buildLogo(context),
              const SizedBox(width: PromoConstants.largeSpacing),
              _buildNavigationItems(context),
              const Spacer(),
              _buildCTAButton(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildNavigationDecoration(BuildContext context) {
    final isScrolled = controller.isNavBarScrolled;
    
    return BoxDecoration(
      color: isScrolled 
          ? PromoConstants.whiteColor.withValues(alpha: 0.95)
          : Colors.transparent,
      boxShadow: isScrolled
          ? [
              const BoxShadow(
                color: PromoConstants.navBarShadowColor,
                spreadRadius: 1,
                blurRadius: PromoConstants.navBarBlurRadius,
                offset: Offset(0, 2),
              ),
            ]
          : [],
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isScrolled = controller.isNavBarScrolled;
    
    return InkWell(
      onTap: () => controller.scrollToSection(NavigationSection.hero),
      borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(PromoConstants.smallSpacing),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ResponsiveHelpers.getResponsiveIconSize(context, 32),
              height: ResponsiveHelpers.getResponsiveIconSize(context, 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    PromoConstants.primaryColor,
                    PromoConstants.accentColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
              ),
              child: Icon(
                Icons.pets,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
                color: PromoConstants.whiteColor,
              ),
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Text(
              PromoConstants.appName,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: isScrolled 
                    ? PromoConstants.textColor 
                    : PromoConstants.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, {bool isCompact = false}) {
    final isScrolled = controller.isNavBarScrolled;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: NavigationSection.values.where((section) {
        // Hide some sections on compact layout
        if (isCompact && section == NavigationSection.screenshots) return false;
        if (isCompact && section == NavigationSection.testimonials) return false;
        return section != NavigationSection.hero; // Don't show hero in nav
      }).map((section) {
        return Padding(
          padding: EdgeInsets.only(
            right: isCompact ? PromoConstants.smallSpacing : PromoConstants.itemSpacing,
          ),
          child: _buildNavigationItem(context, section, isScrolled),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationItem(BuildContext context, NavigationSection section, bool isScrolled) {
    final isActive = controller.currentSection == section;
    
    return InkWell(
      onTap: () => controller.scrollToSection(section),
      borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PromoConstants.defaultPadding,
          vertical: PromoConstants.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? (isScrolled ? PromoConstants.primaryColor : PromoConstants.whiteColor.withValues(alpha: 0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              section.icon,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
              color: isActive
                  ? (isScrolled ? PromoConstants.whiteColor : PromoConstants.whiteColor)
                  : (isScrolled ? PromoConstants.textColor : PromoConstants.whiteColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(width: PromoConstants.smallSpacing),
            Text(
              section.displayName,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? (isScrolled ? PromoConstants.whiteColor : PromoConstants.whiteColor)
                    : (isScrolled ? PromoConstants.textColor : PromoConstants.whiteColor.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, {bool isCompact = false}) {
    final isScrolled = controller.isNavBarScrolled;
    final isLaunched = controller.countdownController.isLaunched;
    
    return ElevatedButton.icon(
      onPressed: isLaunched 
          ? () => controller.scrollToSection(NavigationSection.download)
          : () => controller.showPreRegisterDialog(),
      icon: Icon(
        isLaunched ? Icons.download : Icons.notifications_active,
        size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
      ),
      label: Text(
        isLaunched 
            ? (isCompact ? 'Baixar' : 'Baixar App')
            : (isCompact ? 'Notificar' : 'Seja Notificado'),
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
          fontWeight: PromoConstants.buttonWeight,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: isScrolled ? PromoConstants.whiteColor : PromoConstants.primaryColor,
        backgroundColor: isScrolled ? PromoConstants.primaryColor : PromoConstants.whiteColor,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : PromoConstants.ctaButtonHorizontalPadding,
          vertical: PromoConstants.ctaButtonPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
        ),
        elevation: isScrolled ? PromoConstants.buttonElevation : 0,
      ),
    );
  }

  Widget _buildMobileMenuButton(BuildContext context) {
    final isScrolled = controller.isNavBarScrolled;
    
    return InkWell(
      onTap: () => _showMobileMenu(context),
      borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(PromoConstants.smallSpacing),
        decoration: BoxDecoration(
          color: isScrolled 
              ? PromoConstants.primaryColor.withValues(alpha: 0.1)
              : PromoConstants.whiteColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
        ),
        child: Icon(
          Icons.menu,
          size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
          color: isScrolled 
              ? PromoConstants.primaryColor 
              : PromoConstants.whiteColor,
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMobileMenuSheet(context),
    );
  }

  Widget _buildMobileMenuSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PromoConstants.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(PromoConstants.cardBorderRadius),
          topRight: Radius.circular(PromoConstants.cardBorderRadius),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: PromoConstants.smallSpacing),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PromoConstants.textColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Menu header
            Padding(
              padding: const EdgeInsets.all(PromoConstants.defaultPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.menu,
                    color: PromoConstants.primaryColor,
                    size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
                  ),
                  const SizedBox(width: PromoConstants.smallSpacing),
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: PromoConstants.textColor,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(PromoConstants.smallSpacing),
                      child: Icon(
                        Icons.close,
                        color: PromoConstants.textColor.withValues(alpha: 0.6),
                        size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items
            ...NavigationSection.values.where((section) => section != NavigationSection.hero).map((section) {
              return _buildMobileMenuItem(context, section);
            }),
            
            const SizedBox(height: PromoConstants.itemSpacing),
            
            // CTA button
            Padding(
              padding: const EdgeInsets.all(PromoConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: _buildCTAButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(BuildContext context, NavigationSection section) {
    final isActive = controller.currentSection == section;
    
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        controller.scrollToSection(section);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PromoConstants.defaultPadding,
          vertical: PromoConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: isActive ? PromoConstants.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? PromoConstants.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              section.icon,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
              color: isActive ? PromoConstants.primaryColor : PromoConstants.textColor,
            ),
            const SizedBox(width: PromoConstants.defaultPadding),
            Text(
              section.displayName,
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? PromoConstants.primaryColor : PromoConstants.textColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
              color: PromoConstants.textColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
