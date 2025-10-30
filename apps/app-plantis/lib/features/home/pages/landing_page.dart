import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../presentation/providers/landing_providers.dart';
import '../presentation/widgets/landing_cta_section.dart';
import '../presentation/widgets/landing_features_section.dart';
import '../presentation/widgets/landing_hero_section.dart';
import '../presentation/widgets/landing_loading_screen.dart';

/// Landing page with Clean Architecture
///
/// Uses Riverpod providers for state management and
/// separated widgets for better maintainability
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animationController.forward();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          if (authStatus.shouldRedirect) {
            // Redirect after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/plants');
            });
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
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LandingHeroSection(
                  content: content.hero,
                  onCtaPressed: () => context.go('/login'),
                ),
                LandingFeaturesSection(features: content.features),
                LandingCtaSection(
                  content: content.cta,
                  onPressed: () => context.go('/register'),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
      loading: () => const LandingLoadingScreen(),
      error: (_, __) => const Center(child: Text('Erro ao carregar conteúdo')),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 24, color: PlantisColors.primary),
              SizedBox(width: 8),
              Text(
                'Plantis',
                style: TextStyle(
                  color: PlantisColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cuidando das suas plantas com tecnologia e carinho.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlantisColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Plantis - Todos os direitos reservados',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
