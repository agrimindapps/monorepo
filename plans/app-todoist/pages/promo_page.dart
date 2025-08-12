// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'promo/call_to_action.dart';
import 'promo/faq_section.dart';
import 'promo/features_carousel.dart';
import 'promo/footer_section.dart';
import 'promo/header_section.dart';
import 'promo/how_it_works.dart';
import 'promo/navigation_bar.dart';
import 'promo/statistics_section.dart';
import 'promo/testimonials_section.dart';

class PromoTodoistPage extends StatefulWidget {
  const PromoTodoistPage({super.key});

  @override
  State<PromoTodoistPage> createState() => _PromoTodoistPageState();
}

class _PromoTodoistPageState extends State<PromoTodoistPage> {
  // Variável de controle para exibição do modo "Em breve"
  final bool _isAppReleased = false; // Altere para 'true' após o lançamento

  // Controllers e keys para navegação
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  // Lista de funcionalidades para o carrossel
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.check_circle_outline,
      'title': 'Organização Inteligente',
      'description':
          'Organize suas tarefas com projetos, etiquetas e filtros personalizados para máxima produtividade.'
    },
    {
      'icon': Icons.schedule,
      'title': 'Lembretes Eficazes',
      'description':
          'Receba notificações precisas e nunca perca prazos importantes com nossos lembretes inteligentes.'
    },
    {
      'icon': Icons.sync,
      'title': 'Sincronização Multiplataforma',
      'description':
          'Acesse suas tarefas em qualquer dispositivo com sincronização em tempo real e trabalhe offline.'
    },
    {
      'icon': Icons.trending_up,
      'title': 'Acompanhamento de Progresso',
      'description':
          'Visualize sua produtividade com gráficos e estatísticas que mostram seu crescimento pessoal.'
    },
  ];

  // Lista de depoimentos
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'João Silva',
      'comment':
          'O Todoist transformou completamente minha rotina. Nunca fui tão produtivo e organizado!',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Maria Santos',
      'comment':
          'Interface limpa e recursos poderosos. Consegui organizar tanto vida pessoal quanto profissional.',
      'avatar': Icons.person,
      'rating': 5
    },
    {
      'name': 'Pedro Oliveira',
      'comment':
          'A sincronização funciona perfeitamente. Uso no celular, tablet e computador sem problemas.',
      'avatar': Icons.person,
      'rating': 4
    },
  ];

  // Método para scroll suave até uma seção
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to constrain content width while keeping background full-width
  Widget _constrainContentWidth(Widget child, {Color? backgroundColor}) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal com rolagem
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espaço para compensar a AppBar
                SizedBox(height: AppBar().preferredSize.height + 40),

                // Header com gradiente
                const TodoistHeaderSection(),

                // Carrossel de funcionalidades
                _constrainContentWidth(
                  Container(
                    key: _featuresKey,
                    child: TodoistFeaturesCarousel(features: _features),
                  ),
                ),

                // Como funciona
                _constrainContentWidth(
                  Container(
                    key: _howItWorksKey,
                    child: const TodoistHowItWorksSection(),
                  ),
                ),

                // Depoimentos
                _constrainContentWidth(
                  Container(
                    key: _testimonialsKey,
                    child: _isAppReleased
                        ? TodoistTestimonialsSection(
                            testimonials: _testimonials)
                        : _buildTestimonialsComingSoon(),
                  ),
                  backgroundColor: Colors.grey[50],
                ),

                // FAQ
                _constrainContentWidth(
                  Container(
                    key: _faqKey,
                    child: const TodoistFAQSection(),
                  ),
                ),

                // Estatísticas - sempre exibe a seção com indicadores zerados para pré-lançamento
                _constrainContentWidth(
                  const TodoistStatisticsSection(),
                  backgroundColor: Colors.grey[50],
                ),

                // Call to Action
                const TodoistCallToActionSection(),

                // Footer
                _constrainContentWidth(
                  const TodoistFooterSection(),
                  backgroundColor: Colors.grey[900],
                ),
              ],
            ),
          ),

          // Barra de navegação fixa no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TodoistPromoNavigationBar(
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

  // Widget específico para seção de depoimentos em modo "Em breve"
  Widget _buildTestimonialsComingSoon() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          // Título da seção
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'O Que Nossos ',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Usuários',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(
                        0xFFE44332), // Cor característica do Todoist
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: ' Dizem',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Cards de depoimentos placeholder
          isMobile
              ? _buildMobileTestimonialsPlaceholder()
              : _buildDesktopTestimonialsPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildDesktopTestimonialsPlaceholder() {
    return Row(
      children: [
        Expanded(child: _buildTestimonialPlaceholder()),
        const SizedBox(width: 20),
        Expanded(child: _buildTestimonialPlaceholder()),
        const SizedBox(width: 20),
        Expanded(child: _buildTestimonialPlaceholder()),
      ],
    );
  }

  Widget _buildMobileTestimonialsPlaceholder() {
    return Column(
      children: [
        _buildTestimonialPlaceholder(),
        const SizedBox(height: 20),
        _buildTestimonialPlaceholder(),
        const SizedBox(height: 20),
        _buildTestimonialPlaceholder(),
      ],
    );
  }

  Widget _buildTestimonialPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person_outline,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 16),

          // Nome placeholder
          Container(
            height: 16,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),

          // Estrelas placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_outline,
                color: Colors.grey[300],
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Texto do depoimento placeholder
          Column(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
