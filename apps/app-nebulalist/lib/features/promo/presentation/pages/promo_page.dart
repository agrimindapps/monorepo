import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // Removed auto-redirect logic - PromoPage is now the landing page
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
        'icon': Icons.checklist,
        'title': 'Listas Inteligentes',
        'description':
            'Crie listas personalizadas com tags, cores e prioridades para organizar suas tarefas.',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Sincronização em Nuvem',
        'description':
            'Acesse suas tarefas de qualquer dispositivo, sempre sincronizadas e atualizadas.',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Inteligentes',
        'description':
            'Nunca mais esqueça uma tarefa importante com notificações inteligentes.',
      },
      {
        'icon': Icons.group,
        'title': 'Colaboração em Equipe',
        'description':
            'Compartilhe listas e trabalhe em equipe com facilidade e produtividade.',
      },
    ];
  }
}
