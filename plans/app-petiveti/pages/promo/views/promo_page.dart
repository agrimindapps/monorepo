// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/promo_controller.dart';
import '../utils/promo_constants.dart';
import '../utils/responsive_helpers.dart';
import '../widgets/countdown_section_widget.dart';
import '../widgets/download_section_widget.dart';
import '../widgets/faq_section_widget.dart';
import '../widgets/features_section_widget.dart';
import '../widgets/footer_section_widget.dart';
import '../widgets/hero_section_widget.dart';
import '../widgets/navigation_bar_widget.dart';
import '../widgets/pre_register_dialog_widget.dart';
import '../widgets/screenshots_section_widget.dart';
import '../widgets/testimonials_section_widget.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  late PromoController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = PromoController();
    _initializePage();
  }

  void _initializePage() async {
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PromoConstants.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (!_controller.isInitialized) {
            return _buildLoadingPage();
          }

          return Stack(
            children: [
              _buildPageContent(),
              _buildNavigationBar(),
              if (_controller.isPreRegisterDialogVisible) _buildPreRegisterDialog(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PromoConstants.whiteColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
              ),
              child: const Icon(
                Icons.pets,
                size: 40,
                color: PromoConstants.whiteColor,
              ),
            ),
            const SizedBox(height: PromoConstants.largeSpacing),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(PromoConstants.whiteColor),
            ),
            const SizedBox(height: PromoConstants.itemSpacing),
            Text(
              'Carregando ${PromoConstants.appName}...',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                color: PromoConstants.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return CustomScrollView(
      controller: _controller.scrollController,
      slivers: [
        // Hero Section
        if (_controller.promoContent?.heroContent != null)
        SliverToBoxAdapter(
          child: HeroSectionWidget(
            controller: _controller,
            heroContent: _controller.promoContent!.heroContent,
          ),
        ),

        // Features Section
        if (_controller.promoContent?.featuresContent != null)
        SliverToBoxAdapter(
          child: FeaturesSectionWidget(
            controller: _controller,
            featuresContent: _controller.promoContent!.featuresContent,
          ),
        ),

        // Screenshots Section
        if (_controller.promoContent?.screenshotsContent != null)
        SliverToBoxAdapter(
          child: ScreenshotsSectionWidget(
            controller: _controller,
            screenshotsContent: _controller.promoContent!.screenshotsContent,
          ),
        ),

        // Countdown Section
        SliverToBoxAdapter(
          child: CountdownSectionWidget(
            controller: _controller.countdownController,
          ),
        ),

        // Testimonials Section
        if (_controller.promoContent?.testimonialsContent != null)
        SliverToBoxAdapter(
          child: TestimonialsSectionWidget(
            controller: _controller,
            testimonialsContent: _controller.promoContent!.testimonialsContent,
          ),
        ),

        // Download Section
        if (_controller.promoContent?.downloadContent != null)
        SliverToBoxAdapter(
          child: DownloadSectionWidget(
            controller: _controller,
            downloadContent: _controller.promoContent!.downloadContent,
          ),
        ),

        // FAQ Section
        if (_controller.promoContent?.faqContent != null)
        SliverToBoxAdapter(
          child: FAQSectionWidget(
            controller: _controller,
            faqContent: _controller.promoContent!.faqContent,
          ),
        ),

        // Footer Section
        if (_controller.promoContent?.footerContent != null)
        SliverToBoxAdapter(
          child: FooterSectionWidget(
            controller: _controller,
            footerContent: _controller.promoContent!.footerContent,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: NavigationBarWidget(
        controller: _controller,
      ),
    );
  }

  Widget _buildPreRegisterDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: PreRegisterDialogWidget(
          controller: _controller.preRegisterController,
        ),
      ),
    );
  }
}
