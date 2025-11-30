import 'package:flutter/material.dart';

import '../widgets/call_to_action.dart';
import '../widgets/faq_section.dart';
import '../widgets/features_carousel.dart';
import '../widgets/footer_section.dart';
import '../widgets/header_section.dart';
import '../widgets/how_it_works.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/statistics_section.dart';
import '../widgets/testimonials_section.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const HeaderSection(),
                FeaturesCarousel(
                  key: _featuresKey,
                  features: _getFeaturesList(),
                ),
                HowItWorks(key: _howItWorksKey),
                const StatisticsSection(),
                TestimonialsSection(key: _testimonialsKey),
                FaqSection(key: _faqKey),
                const CallToAction(),
                const FooterSection(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PromoNavigationBar(
              onNavigate: _scrollToSection,
              featuresKey: _featuresKey,
              howItWorksKey: _howItWorksKey,
              testimonialsKey: _testimonialsKey,
              faqKey: _faqKey,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFeaturesList() {
    return [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Planejamento de Refeições',
        'description':
            'Organize suas refeições da semana com praticidade e inteligência nutricional.',
      },
      {
        'icon': Icons.calculate,
        'title': 'Cálculo de Macros',
        'description':
            'Acompanhe calorias, proteínas, carboidratos e gorduras de forma automática.',
      },
      {
        'icon': Icons.analytics,
        'title': 'Relatórios Nutricionais',
        'description':
            'Visualize gráficos detalhados sobre sua evolução e hábitos alimentares.',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Inteligentes',
        'description':
            'Receba notificações para suas refeições e metas de hidratação.',
      },
    ];
  }
}
