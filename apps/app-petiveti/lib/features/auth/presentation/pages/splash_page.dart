import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';
import '../providers/auth_provider.dart';

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
    // CORREÇÃO: Aguardar DI estar pronto antes de acessar authProvider
    Future.delayed(SplashConstants.splashMinimumDuration, () async {
      if (!mounted) return; // Check if widget is still mounted
      
      try {
        // Tentar acessar authProvider de forma segura
        final authState = ref.read(authProvider);
        
        if (authState.isAuthenticated) {
          context.go(SplashConstants.homeRoute);
        } else {
          context.go(SplashConstants.promoRoute);
        }
      } catch (e) {
        // Se authProvider ainda não está pronto, aguardar mais um pouco
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        
        try {
          final authState = ref.read(authProvider);
          if (authState.isAuthenticated) {
            context.go(SplashConstants.homeRoute);
          } else {
            context.go(SplashConstants.promoRoute);
          }
        } catch (e2) {
          // Se ainda não conseguiu, ir para promo como fallback
          if (mounted) {
            context.go(SplashConstants.promoRoute);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose animation controller safely
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
                    // Logo with accessibility
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
                    
                    // App Name with accessibility
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
                    
                    // Tagline with accessibility
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
                    
                    // Loading indicator with accessibility
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