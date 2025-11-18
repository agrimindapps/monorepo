import 'package:core/core.dart' ;
import 'package:flutter/material.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';
import '../widgets/call_to_action.dart';
import '../widgets/faq_section.dart';
import '../widgets/features_carousel.dart';
import '../widgets/footer_section.dart';
import '../widgets/header_section.dart';
import '../widgets/how_it_works.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/statistics_section.dart';
import '../widgets/testimonials_section.dart';

class PromoPage extends ConsumerStatefulWidget {
  const PromoPage({super.key});

  @override
  ConsumerState<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends ConsumerState<PromoPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthenticationAndRedirect();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAuthenticationAndRedirect() {
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      debugPrint(
        '🔐 Usuário autenticado na página promocional, redirecionando para página interna',
      );
      if (mounted) {
        context.go('/');
      }
    }
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
        'icon': Icons.local_gas_station,
        'title': 'Controle de Abastecimento',
        'description':
            'Registre cada abastecimento e acompanhe o consumo do seu veículo com precisão.',
      },
      {
        'icon': Icons.build,
        'title': 'Manutenções',
        'description':
            'Mantenha um histórico completo das manutenções preventivas e corretivas.',
      },
      {
        'icon': Icons.analytics,
        'title': 'Relatórios Detalhados',
        'description':
            'Visualize gráficos e estatísticas sobre gastos, consumo e performance.',
      },
      {
        'icon': Icons.notifications,
        'title': 'Lembretes Inteligentes',
        'description':
            'Receba notificações para manutenções programadas e revisões importantes.',
      },
    ];
  }
}
