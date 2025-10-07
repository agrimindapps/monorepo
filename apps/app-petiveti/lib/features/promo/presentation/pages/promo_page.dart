import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';
import '../providers/promo_provider.dart';
import '../states/promo_state.dart';
import '../widgets/promo_app_bar.dart';
import '../widgets/promo_cta_section.dart';
import '../widgets/promo_features_section.dart';
import '../widgets/promo_footer.dart';
import '../widgets/promo_hero_section.dart';
import '../widgets/promo_loading_widget.dart';
import '../widgets/promo_pre_registration_dialog.dart';
import '../widgets/promo_screenshots_section.dart';
import '../widgets/promo_simple_faq_section.dart';

class PromoPage extends ConsumerStatefulWidget {
  const PromoPage({super.key});

  @override
  ConsumerState<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends ConsumerState<PromoPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _screenshotsKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(promoProvider.notifier).loadPromoContent();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    ref.read(promoProvider.notifier).trackEvent('promo_login_clicked');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          if (state.isLoading || !state.hasContent)
            const PromoLoadingWidget()
          else
            _buildContent(context, state),
          PromoAppBar(
            onFeaturesPressed: () => _scrollToSection(_featuresKey),
            onScreenshotsPressed: () => _scrollToSection(_screenshotsKey),
            onTestimonialsPressed: () => _scrollToSection(_testimonialsKey),
            onFaqPressed: () => _scrollToSection(_faqKey),
            onLoginPressed: _navigateToLogin,
          ),
          if (state.showPreRegistrationDialog)
            PromoPreRegistrationDialog(
              onClose:
                  () =>
                      ref
                          .read(promoProvider.notifier)
                          .togglePreRegistrationDialog(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PromoState state) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          PromoHeroSection(
            appName: SplashConstants.appName,
            appTagline: SplashConstants.appTagline,
            appDescription: SplashConstants.appDescription,
            onGetStartedPressed: _navigateToLogin, // Já tenho conta -> Login
            onPreRegisterPressed: () {
              // Pré-cadastro -> Modal
              ref.read(promoProvider.notifier).togglePreRegistrationDialog();
              ref
                  .read(promoProvider.notifier)
                  .trackEvent('promo_pre_register_clicked');
            },
          ),
          PromoFeaturesSection(
            key: _featuresKey,
            features: const <dynamic>[], // Will use hardcoded features
          ),
          PromoScreenshotsSection(
            key: _screenshotsKey,
            screenshots: const <dynamic>[], // Will use hardcoded screenshots
            currentIndex: state.currentScreenshotIndex,
            onScreenshotChanged: (index) {
              ref.read(promoProvider.notifier).changeScreenshot(index);
            },
          ),
          PromoSimpleFaqSection(key: _faqKey),
          PromoCTASection(
            onPreRegisterPressed: () {
              ref.read(promoProvider.notifier).togglePreRegistrationDialog();
              ref.read(promoProvider.notifier).trackEvent('promo_cta_clicked');
            },
          ),
          const PromoFooter(),
        ],
      ),
    );
  }
}
