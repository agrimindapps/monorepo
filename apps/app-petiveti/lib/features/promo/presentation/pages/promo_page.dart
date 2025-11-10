import 'package:core/core.dart' hide Column;
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

/// Página de Promoção do App
class PromoPage extends ConsumerStatefulWidget {
  const PromoPage({super.key});

  @override
  ConsumerState<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends ConsumerState<PromoPage> {
  // =====================
  // Propriedades
  // =====================
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _screenshotsKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  // Example local constants — replace with real content or move to a data source
  static const List<dynamic> kPromoFeatures = <dynamic>[];
  static const List<dynamic> kPromoScreenshots = <dynamic>[];

  // =====================
  // Ciclo de Vida
  // =====================
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

  // =====================
  // Métodos Privados
  // =====================
  /// Scroll suavemente para a seção indicada pela [key].
  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  /// Navega para a tela de login e registra o evento.
  void _onLoginPressed() {
    ref.read(promoProvider.notifier).trackEvent('promo_login_clicked');
    context.go('/login');
  }

  /// Alterna o diálogo de pré‑registro e opcionalmente registra um evento.
  void _togglePreRegistration({String? trackingEvent}) {
    ref.read(promoProvider.notifier).togglePreRegistrationDialog();
    if (trackingEvent != null) {
      ref.read(promoProvider.notifier).trackEvent(trackingEvent);
    }
  }

  /// Constrói o corpo principal da página.
  Widget _buildBody(BuildContext context, PromoState state) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          PromoHeroSection(
            appName: SplashConstants.appName,
            appTagline: SplashConstants.appTagline,
            appDescription: SplashConstants.appDescription,
            onGetStartedPressed: _onLoginPressed,
            onPreRegisterPressed: () => _togglePreRegistration(
              trackingEvent: 'promo_pre_register_clicked',
            ),
          ),
          PromoFeaturesSection(key: _featuresKey, features: kPromoFeatures),
          PromoScreenshotsSection(
            key: _screenshotsKey,
            screenshots: kPromoScreenshots,
            currentIndex: state.currentScreenshotIndex,
            onScreenshotChanged: (index) =>
                ref.read(promoProvider.notifier).changeScreenshot(index),
          ),
          PromoSimpleFaqSection(key: _faqKey),
          PromoCTASection(
            onPreRegisterPressed: () =>
                _togglePreRegistration(trackingEvent: 'promo_cta_clicked'),
          ),
          const PromoFooter(),
        ],
      ),
    );
  }

  // =====================
  // Build
  // =====================
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
            _buildBody(context, state),
          _buildAppBar(),
          if (state.showPreRegistrationDialog) _buildPreRegistrationDialog(),
        ],
      ),
    );
  }

  /// Small builder for the promo app bar to keep build() concise.
  Widget _buildAppBar() => PromoAppBar(
    onFeaturesPressed: () => _scrollToSection(_featuresKey),
    onScreenshotsPressed: () => _scrollToSection(_screenshotsKey),
    onTestimonialsPressed: () => _scrollToSection(_testimonialsKey),
    onFaqPressed: () => _scrollToSection(_faqKey),
    onLoginPressed: _onLoginPressed,
  );

  /// Small builder for the pre-registration dialog.
  Widget _buildPreRegistrationDialog() =>
      PromoPreRegistrationDialog(onClose: () => _togglePreRegistration());
}
