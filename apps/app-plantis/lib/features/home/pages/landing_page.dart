import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../presentation/managers/landing_animation_manager.dart';
import '../presentation/managers/landing_auth_redirect_manager.dart';
import '../presentation/managers/landing_footer_builder.dart';
import '../presentation/providers/landing_providers.dart';
import '../presentation/widgets/landing_cta_section.dart';
import '../presentation/widgets/landing_features_section.dart';
import '../presentation/widgets/landing_hero_section.dart';
import '../presentation/widgets/landing_loading_screen.dart';

/// Landing page with Clean Architecture
///
/// Uses Riverpod providers for state management and
/// separated widgets and managers for better maintainability
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  late LandingAnimationManager _animationManager;

  @override
  void initState() {
    super.initState();
    _animationManager = LandingAnimationManager();
    _animationManager.initAnimations(this);
    _animationManager.forward();
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth status stream
    final authStatusAsync = ref.watch(landingAuthStatusStreamProvider);

    return Scaffold(
      body: authStatusAsync.when(
        data: (authStatus) {
          // Check if should redirect to main app
          if (authStatus.isAuthenticated) {
            LandingAuthRedirectManager.redirectToMainApp(context);
            return const LandingLoadingScreen(message: 'Redirecionando...');
          }

          // Show landing content
          return _buildLandingContent();
        },
        loading: () => const LandingLoadingScreen(),
        error: (_, __) => _buildLandingContent(), // Show content on error
      ),
    );
  }

  Widget _buildLandingContent() {
    // Watch landing content provider
    final contentAsync = ref.watch(landingContentProvider);

    return contentAsync.when(
      data: (content) => FadeTransition(
        opacity: _animationManager.fadeAnimation,
        child: SlideTransition(
          position: _animationManager.slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LandingHeroSection(
                  content: content.hero,
                  onCtaPressed: () =>
                      LandingAuthRedirectManager.goToLogin(context),
                  comingSoon: content.comingSoon,
                  launchDate: content.launchDate,
                ),
                LandingFeaturesSection(
                  features: content.features,
                  comingSoon: content.comingSoon,
                ),
                LandingCtaSection(
                  content: content.cta,
                  onPressed: () =>
                      LandingAuthRedirectManager.goToRegister(context),
                  comingSoon: content.comingSoon,
                ),
                LandingFooterBuilder.buildFooter(),
              ],
            ),
          ),
        ),
      ),
      loading: () => const LandingLoadingScreen(),
      error: (_, __) => const Center(child: Text('Erro ao carregar conteúdo')),
    );
  }
}
