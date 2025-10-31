import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';
import '../notifiers/auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: SplashConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: SplashConstants.fadeBeginValue,
      end: SplashConstants.fadeEndValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: SplashConstants.fadeInterval,
    ));

    _scaleAnimation = Tween<double>(
      begin: SplashConstants.scaleBeginValue,
      end: SplashConstants.scaleEndValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: SplashConstants.scaleInterval,
    ));

    _animationController.forward();
  }

  void _checkAuthState() {
    Future.delayed(SplashConstants.splashMinimumDuration, () async {
      if (!mounted) return; // Check if widget is still mounted

      try {
        final authState = ref.read(authNotifierProvider);

        if (authState.isAuthenticated) {
          context.go(SplashConstants.homeRoute);
        } else {
          context.go(SplashConstants.promoRoute);
        }
      } catch (e) {
        print('❌ SPLASH: First auth check failed: $e');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        try {
          final authState = ref.read(authNotifierProvider);
          if (authState.isAuthenticated) {
            context.go(SplashConstants.homeRoute);
          } else {
            context.go(SplashConstants.promoRoute);
          }
        } catch (e2) {
          print('❌ SPLASH: Second auth check failed: $e2');
          if (mounted) {
            context.go(SplashConstants.promoRoute);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.getBackgroundColor(context),
      body: Semantics(
        label: 'Tela de inicialização do PetiVeti',
        child: Center(
          child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Logo do PetiVeti',
                      image: true,
                      child: Container(
                        padding: SplashConstants.logoContainerPadding,
                        decoration: BoxDecoration(
                          color: SplashColors.getLogoContainerColor(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SplashColors.getShadowColor(context),
                              blurRadius: SplashConstants.logoShadowBlurRadius,
                              offset: SplashConstants.logoShadowOffset,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pets,
                          size: SplashConstants.logoIconSize,
                          color: SplashColors.getLogoIconColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: SplashConstants.logoToTitleSpacing),
                    Semantics(
                      label: 'Nome do aplicativo: ${SplashConstants.appName}',
                      header: true,
                      child: Text(
                        SplashConstants.appName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: SplashColors.getTitleColor(context),
                            ),
                      ),
                    ),
                    const SizedBox(height: SplashConstants.titleToTaglineSpacing),
                    Semantics(
                      label: 'Slogan do aplicativo: ${SplashConstants.appTagline}',
                      child: Text(
                        SplashConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: SplashColors.getTaglineColor(context),
                            ),
                      ),
                    ),
                    const SizedBox(height: SplashConstants.taglineToIndicatorSpacing),
                    Semantics(
                      label: 'Carregando aplicativo',
                      hint: 'Aguarde enquanto o PetiVeti está sendo inicializado',
                      liveRegion: true,
                      child: SizedBox(
                        width: SplashConstants.progressIndicatorSize,
                        height: SplashConstants.progressIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: SplashConstants.progressIndicatorStrokeWidth,
                          valueColor: AlwaysStoppedAnimation<Color>(SplashColors.getProgressIndicatorColor(context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}
