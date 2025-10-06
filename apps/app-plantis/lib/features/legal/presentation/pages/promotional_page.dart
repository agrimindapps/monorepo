import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../widgets/promo_call_to_action.dart';
import '../widgets/promo_features_carousel.dart';
import '../widgets/promo_header_section.dart';
import '../widgets/promo_navigation_bar.dart';
import '../widgets/promo_statistics_section.dart';

/// Página promocional moderna do Plantis
/// Design modular com widgets reutilizáveis
class PromotionalPage extends ConsumerStatefulWidget {
  const PromotionalPage({super.key});

  @override
  ConsumerState<PromotionalPage> createState() => _PromotionalPageState();
}

class _PromotionalPageState extends ConsumerState<PromotionalPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const PromoHeaderSection(),
                  PromoFeaturesCarousel(key: _featuresKey),
                  const PromoStatisticsSection(),
                  _HowItWorksSection(key: _howItWorksKey),
                  _TestimonialsSection(key: _testimonialsKey),
                  const PromoCallToAction(),
                  const _FooterSection(),
                ],
              ),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção Como Funciona
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    final steps = [
      {
        'number': '1',
        'title': 'Cadastre suas Plantas',
        'description': 'Adicione suas plantas com fotos e informações básicas',
        'icon': Icons.add_photo_alternate,
      },
      {
        'number': '2',
        'title': 'Configure os Cuidados',
        'description': 'Defina a frequência de rega, adubação e outras necessidades',
        'icon': Icons.settings,
      },
      {
        'number': '3',
        'title': 'Receba Lembretes',
        'description': 'Seja notificado automaticamente quando suas plantas precisarem de cuidados',
        'icon': Icons.notifications_active,
      },
      {
        'number': '4',
        'title': 'Acompanhe o Crescimento',
        'description': 'Registre o progresso e veja suas plantas prosperarem',
        'icon': Icons.trending_up,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Como Funciona',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'É simples começar a cuidar melhor das suas plantas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 48,
                alignment: WrapAlignment.center,
                children: steps.map((step) {
                  return SizedBox(
                    width: isMobile ? screenSize.width - 48 : 250,
                    child: _buildStepCard(
                      step['number'] as String,
                      step['title'] as String,
                      step['description'] as String,
                      step['icon'] as IconData,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Seção de Depoimentos
class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    final testimonials = [
      {
        'name': 'Ana Costa',
        'text':
            'O Plantis mudou completamente minha rotina! Nunca mais esqueci de regar minhas plantas.',
        'rating': 5,
        'avatar': Icons.person,
      },
      {
        'name': 'Pedro Silva',
        'text':
            'Excelente app! Os lembretes são precisos e a interface é muito intuitiva.',
        'rating': 5,
        'avatar': Icons.person_outline,
      },
      {
        'name': 'Maria Oliveira',
        'text':
            'Minhas plantas nunca estiveram tão saudáveis. Recomendo para todos os jardineiros!',
        'rating': 5,
        'avatar': Icons.person_2,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'O que nossos usuários dizem',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = testimonials[index];
                    return Container(
                      width: isMobile ? 280 : 350,
                      margin: const EdgeInsets.only(right: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              testimonial['rating'] as int,
                              (index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              testimonial['text'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                                child: Icon(
                                  testimonial['avatar'] as IconData,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                testimonial['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção de Footer
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.black87,
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            const Text(
              'Plantis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuidado de plantas com amor e tecnologia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildFooterLink('Sobre', context),
                _buildFooterLink('Privacidade', context),
                _buildFooterLink('Termos', context),
                _buildFooterLink('Contato', context),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© 2025 Plantis. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, BuildContext context) {
    return InkWell(
      onTap: () => _navigateToPage(text, context),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.7),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _navigateToPage(String text, BuildContext context) {
    switch (text) {
      case 'Privacidade':
        context.go(AppRouter.privacyPolicy);
        break;
      case 'Termos':
        context.go(AppRouter.termsOfService);
        break;
      case 'Sobre':
        break;
      case 'Contato':
        break;
    }
  }
}
