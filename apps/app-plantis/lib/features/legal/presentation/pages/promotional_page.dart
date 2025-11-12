import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../home/domain/entities/landing_content.dart';
import '../../../home/presentation/providers/landing_providers.dart';
import '../builders/how_it_works_section_builder.dart';
import '../builders/footer_section_builder.dart';
import '../builders/promo_coming_soon_section_builder.dart';
import '../builders/testimonials_section_builder.dart';
import '../managers/promotional_page_animation_manager.dart';
import '../managers/promotional_page_scroll_manager.dart';
import '../widgets/promo_call_to_action.dart';
import '../widgets/promo_features_carousel.dart';
import '../widgets/promo_header_section.dart';
import '../widgets/promo_navigation_bar.dart';
import '../widgets/promo_statistics_section.dart';

/// Página promocional moderna do Plantis
/// Design modular com widgets reutilizáveis
/// SRP: Page only handles navigation and layout composition
class PromotionalPage extends ConsumerStatefulWidget {
  const PromotionalPage({super.key});

  @override
  ConsumerState<PromotionalPage> createState() => _PromotionalPageState();
}

class _PromotionalPageState extends ConsumerState<PromotionalPage>
    with SingleTickerProviderStateMixin {
  late PromotionalPageAnimationManager _animationManager;
  late PromotionalPageScrollManager _scrollManager;
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationManager = PromotionalPageAnimationManager();
    _animationManager.initAnimations(this);
    _animationManager.forward();

    _scrollManager = PromotionalPageScrollManager();
    _scrollManager.addScrollListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationManager.dispose();
    _scrollManager.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    _scrollManager.scrollToSection(key);
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch<AsyncValue<LandingContent>>(landingContentProvider);

    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollManager.scrollController,
              child: contentAsync.when<Widget>(
                data: (LandingContent content) => Column(
                  children: [
                    // Coming Soon banner and countdown (if applicable)
                    PromoComingSoonSectionBuilder.build(
                      comingSoon: content.comingSoon,
                      launchDate: content.launchDate,
                    ),
                    PromoHeaderSection(
                      comingSoon: content.comingSoon,
                      launchDate: content.launchDate,
                    ),
                    PromoFeaturesCarousel(key: _featuresKey),
                    const PromoStatisticsSection(),
                    HowItWorksSectionBuilder.build(context),
                    TestimonialsSectionBuilder.build(
                      screenWidth: MediaQuery.of(context).size.width,
                    ),
                    const PromoCallToAction(),
                    FooterSectionBuilder.build(),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Column(
                  children: [
                    const PromoHeaderSection(),
                    PromoFeaturesCarousel(key: _featuresKey),
                    const PromoStatisticsSection(),
                    HowItWorksSectionBuilder.build(context),
                    TestimonialsSectionBuilder.build(
                      screenWidth: MediaQuery.of(context).size.width,
                    ),
                    const PromoCallToAction(),
                    FooterSectionBuilder.build(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: contentAsync.when<Widget>(
              data: (LandingContent content) => PromoNavigationBar(
                onNavigate: _scrollToSection,
                featuresKey: _featuresKey,
                howItWorksKey: _howItWorksKey,
                testimonialsKey: _testimonialsKey,
                comingSoon: content.comingSoon,
                launchDate: content.launchDate,
              ),
              loading: () => PromoNavigationBar(
                onNavigate: _scrollToSection,
                featuresKey: _featuresKey,
                howItWorksKey: _howItWorksKey,
                testimonialsKey: _testimonialsKey,
              ),
              error: (_, __) => PromoNavigationBar(
                onNavigate: _scrollToSection,
                featuresKey: _featuresKey,
                howItWorksKey: _howItWorksKey,
                testimonialsKey: _testimonialsKey,
              ),
            ),
          ),
          if (_scrollManager.showScrollToTopButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollManager.scrollToTop,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }
}
