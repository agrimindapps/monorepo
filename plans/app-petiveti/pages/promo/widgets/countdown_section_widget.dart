// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/countdown_controller.dart';
import '../models/launch_countdown_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class CountdownSectionWidget extends StatefulWidget {
  final CountdownController controller;

  const CountdownSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  State<CountdownSectionWidget> createState() => _CountdownSectionWidgetState();
}

class _CountdownSectionWidgetState extends State<CountdownSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final countdown = widget.controller.countdown;
        
        if (countdown == null) {
          return const SizedBox.shrink();
        }
        
        if (widget.controller.isLaunched) {
          return _buildLaunchedSection(context);
        }
        
        return _buildCountdownSection(context, countdown);
      },
    );
  }

  Widget _buildCountdownSection(BuildContext context, LaunchCountdown countdown) {
    return Container(
      padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PromoConstants.primaryColor,
            PromoConstants.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildCountdownHeader(context, countdown),
          const SizedBox(height: PromoConstants.largeSpacing),
          _buildCountdownDisplay(context, countdown),
          const SizedBox(height: PromoConstants.largeSpacing),
          _buildCountdownFooter(context, countdown),
        ],
      ),
    );
  }

  Widget _buildCountdownHeader(BuildContext context, LaunchCountdown countdown) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                Icons.rocket_launch,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 60),
                color: PromoConstants.whiteColor,
              ),
            );
          },
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        Text(
          'Lançamento em',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.sectionTitleFontSize,
            ),
            fontWeight: PromoConstants.sectionTitleWeight,
            color: PromoConstants.whiteColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: PromoConstants.smallSpacing),
        
        Text(
          PromoHelpers.formatLaunchDate(countdown.launchDate),
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(
              context,
              PromoConstants.heroSubtitleFontSize,
            ),
            color: PromoConstants.whiteColor.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCountdownDisplay(BuildContext context, LaunchCountdown countdown) {
    final timeRemaining = PromoHelpers.calculateTimeRemaining(countdown.launchDate);
    
    return ResponsiveHelpers.buildResponsiveLayout(
      context,
      builder: (context, constraints, breakpoint) {
        switch (breakpoint) {
          case ResponsiveBreakpoint.mobile:
            return _buildMobileCountdown(context, timeRemaining);
          case ResponsiveBreakpoint.tablet:
            return _buildTabletCountdown(context, timeRemaining);
          case ResponsiveBreakpoint.desktop:
          case ResponsiveBreakpoint.ultrawide:
            return _buildDesktopCountdown(context, timeRemaining);
        }
      },
    );
  }

  Widget _buildMobileCountdown(BuildContext context, Map<String, int> timeRemaining) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeUnit(context, timeRemaining['days']!, 'Dias'),
            _buildTimeUnit(context, timeRemaining['hours']!, 'Horas'),
          ],
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeUnit(context, timeRemaining['minutes']!, 'Min'),
            _buildTimeUnit(context, timeRemaining['seconds']!, 'Seg'),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletCountdown(BuildContext context, Map<String, int> timeRemaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(context, timeRemaining['days']!, 'Dias'),
        _buildSeparator(context),
        _buildTimeUnit(context, timeRemaining['hours']!, 'Horas'),
        _buildSeparator(context),
        _buildTimeUnit(context, timeRemaining['minutes']!, 'Minutos'),
        _buildSeparator(context),
        _buildTimeUnit(context, timeRemaining['seconds']!, 'Segundos'),
      ],
    );
  }

  Widget _buildDesktopCountdown(BuildContext context, Map<String, int> timeRemaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit(context, timeRemaining['days']!, 'Dias', isLarge: true),
        _buildSeparator(context, isLarge: true),
        _buildTimeUnit(context, timeRemaining['hours']!, 'Horas', isLarge: true),
        _buildSeparator(context, isLarge: true),
        _buildTimeUnit(context, timeRemaining['minutes']!, 'Minutos', isLarge: true),
        _buildSeparator(context, isLarge: true),
        _buildTimeUnit(context, timeRemaining['seconds']!, 'Segundos', isLarge: true),
      ],
    );
  }

  Widget _buildTimeUnit(BuildContext context, int value, String label, {bool isLarge = false}) {
    final containerSize = ResponsiveHelpers.getResponsiveValue(
      context,
      mobile: 70.0,
      tablet: 90.0,
      desktop: isLarge ? 120.0 : 100.0,
      ultrawide: isLarge ? 140.0 : 120.0,
    );

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: PromoConstants.defaultAnimation,
      builder: (context, animatedValue, child) {
        return Container(
          width: containerSize,
          height: containerSize,
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelpers.getResponsiveValue(
              context,
              mobile: 4.0,
              tablet: 8.0,
              desktop: 12.0,
              ultrawide: 16.0,
            ),
          ),
          decoration: BoxDecoration(
            color: PromoConstants.whiteColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(PromoConstants.countdownUnitBorderRadius),
            border: Border.all(
              color: PromoConstants.whiteColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                animatedValue.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(
                    context,
                    isLarge ? PromoConstants.countdownValueFontSize + 6 : PromoConstants.countdownValueFontSize,
                  ),
                  fontWeight: FontWeight.bold,
                  color: PromoConstants.whiteColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveHelpers.getResponsiveFontSize(
                    context,
                    isLarge ? PromoConstants.countdownLabelFontSize + 2 : PromoConstants.countdownLabelFontSize,
                  ),
                  color: PromoConstants.whiteColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeparator(BuildContext context, {bool isLarge = false}) {
    if (ResponsiveHelpers.isMobile(context)) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelpers.getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 8.0,
                desktop: 12.0,
                ultrawide: 16.0,
              ),
            ),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(
                  context,
                  isLarge ? 36.0 : 28.0,
                ),
                fontWeight: FontWeight.bold,
                color: PromoConstants.whiteColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownFooter(BuildContext context, LaunchCountdown countdown) {
    return Column(
      children: [
        // Status message
        Container(
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
            countdown.statusMessage,
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
              color: PromoConstants.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Description
        Text(
          'Seja o primeiro a saber quando o PetiVeti estiver disponível!',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
            color: PromoConstants.whiteColor.withValues(alpha: 0.8),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Pre-register button
        ElevatedButton.icon(
          onPressed: () {
            debugPrint('Show pre-register dialog');
          },
          icon: Icon(
            Icons.notifications_active,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
          ),
          label: Text(
            'Receber Notificação',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
              fontWeight: PromoConstants.buttonWeight,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: PromoConstants.primaryColor,
            backgroundColor: PromoConstants.whiteColor,
            padding: ResponsiveHelpers.getResponsivePadding(
              context,
              mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              desktop: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
            ),
            elevation: PromoConstants.buttonElevation,
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchedSection(BuildContext context) {
    return Container(
      padding: ResponsiveHelpers.getResponsiveSectionPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PromoConstants.successColor,
            PromoConstants.successColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Success icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.celebration,
                  size: ResponsiveHelpers.getResponsiveIconSize(context, 80),
                  color: PromoConstants.whiteColor,
                ),
              );
            },
          ),
          
          const SizedBox(height: PromoConstants.itemSpacing),
          
          // Launched message
          Text(
            'PetiVeti está disponível!',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.sectionTitleFontSize,
              ),
              fontWeight: PromoConstants.sectionTitleWeight,
              color: PromoConstants.whiteColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PromoConstants.smallSpacing),
          
          Text(
            'Baixe agora e comece a cuidar melhor do seu pet!',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(
                context,
                PromoConstants.bodyFontSize,
              ),
              color: PromoConstants.whiteColor.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: PromoConstants.largeSpacing),
          
          // Download buttons
          ResponsiveHelpers.buildResponsive(
            context,
            mobile: _buildMobileDownloadButtons(context),
            tablet: _buildTabletDownloadButtons(context),
            desktop: _buildDesktopDownloadButtons(context),
            ultrawide: _buildDesktopDownloadButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDownloadButtons(BuildContext context) {
    return Column(
      children: [
        _buildDownloadButton(context, 'Google Play', Icons.android, true),
        const SizedBox(height: PromoConstants.itemSpacing),
        _buildDownloadButton(context, 'App Store', Icons.apple, false),
      ],
    );
  }

  Widget _buildTabletDownloadButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDownloadButton(context, 'Google Play', Icons.android, true),
        const SizedBox(width: PromoConstants.itemSpacing),
        _buildDownloadButton(context, 'App Store', Icons.apple, false),
      ],
    );
  }

  Widget _buildDesktopDownloadButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDownloadButton(context, 'Baixar no Google Play', Icons.android, true, isExpanded: true),
        const SizedBox(width: PromoConstants.largeSpacing),
        _buildDownloadButton(context, 'Baixar na App Store', Icons.apple, false, isExpanded: true),
      ],
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isAndroid, {
    bool isExpanded = false,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        debugPrint('Open app store for platform: ${isAndroid ? 'android' : 'ios'}');
      },
      icon: Icon(
        icon,
        size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
          fontWeight: PromoConstants.buttonWeight,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: PromoConstants.successColor,
        backgroundColor: PromoConstants.whiteColor,
        padding: ResponsiveHelpers.getResponsivePadding(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          desktop: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
        minimumSize: isExpanded 
            ? Size(ResponsiveHelpers.getResponsiveValue(context, mobile: 200.0, tablet: 250.0, desktop: 300.0), 56)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
        ),
        elevation: PromoConstants.buttonElevation,
      ),
    );
  }
}
