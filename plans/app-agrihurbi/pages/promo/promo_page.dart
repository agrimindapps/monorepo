// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'apps_section.dart';
import 'contact_section.dart';
import 'footer_section.dart';
import 'media_section.dart';
import 'testimonial_section.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final scrollController = ScrollController();

  // Referências para as seções para navegação
  final GlobalKey _aboutSection = GlobalKey();
  final GlobalKey _appsSection = GlobalKey();
  final GlobalKey _testimonialsSection = GlobalKey();
  final GlobalKey _contactSection = GlobalKey();

  final List<String> _backgroundImages = List.generate(
      6,
      (index) =>
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/bg_0${index + 1}.jpg');

  int _currentBackgroundIndex = 0;
  late Timer _backgroundTimer;

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
  void initState() {
    super.initState();

    // Inicia com uma imagem aleatória
    _currentBackgroundIndex = Random().nextInt(_backgroundImages.length);

    // Configura o timer para mudar o fundo a cada 8 segundos
    _backgroundTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        // Gera um novo índice aleatório diferente do atual
        int newIndex;
        do {
          newIndex = Random().nextInt(_backgroundImages.length);
        } while (newIndex == _currentBackgroundIndex);

        _currentBackgroundIndex = newIndex;
      });
    });
  }

  @override
  void dispose() {
    _backgroundTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parallax Header
                _buildParallaxHeader(),

                // Sobre a Marca
                _buildAboutSection(),

                // Aplicativos
                _buildAppsSection(),

                // Depoimentos
                _buildTestimonials(),

                // Apps na Mídia
                _buildMediaFeatures(),

                // Contact Form
                _buildContactForm(),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
          // Menu de navegação fixo
          _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(
                Icons.eco,
                size: 32,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 12),
              Text(
                'Agrimind',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),

          // Menu items
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = MediaQuery.of(context).size.width < 800;

              if (isMobile) {
                return PopupMenuButton(
                  icon: const Icon(Icons.menu),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Sobre nós'),
                      onTap: () => _scrollToSection(_aboutSection),
                    ),
                    PopupMenuItem(
                      child: const Text('Aplicativos'),
                      onTap: () => _scrollToSection(_appsSection),
                    ),
                    PopupMenuItem(
                      child: const Text('Depoimentos'),
                      onTap: () => _scrollToSection(_testimonialsSection),
                    ),
                    PopupMenuItem(
                      child: const Text('Contato'),
                      onTap: () => _scrollToSection(_contactSection),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () => _scrollToSection(_aboutSection),
                      child: const Text('Sobre nós'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _scrollToSection(_appsSection),
                      child: const Text('Aplicativos'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _scrollToSection(_testimonialsSection),
                      child: const Text('Depoimentos'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _scrollToSection(_contactSection),
                      child: const Text('Contato'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Cabeçalho com efeito parallax
  Widget _buildParallaxHeader() {
    return Stack(
      children: [
        // Fundo com efeito parallax e transição
        AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Container(
            key: ValueKey<int>(_currentBackgroundIndex),
            height: 650,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_backgroundImages[_currentBackgroundIndex]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        ),

        // Conteúdo sobreposto
        Container(
          height: 650,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo e nome
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Agrimind',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Slogan
              const Text(
                'Tecnologia que transforma o agronegócio',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Descrição
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Soluções digitais inovadoras que simplificam o trabalho e aumentam a produtividade em diversos setores.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // CTA Button
              ElevatedButton(
                onPressed: () => _scrollToSection(_appsSection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Conheça nossos aplicativos'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sobre a marca
  Widget _buildAboutSection() {
    return Container(
      key: _aboutSection,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sobre a Agrimind',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 4,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                'A Agrimind nasceu com a missão de criar aplicativos intuitivos e eficientes para usuários finais. '
                'Inicialmente focada no setor agrícola, nossa empresa expandiu suas soluções para diversos segmentos, '
                'sempre mantendo o compromisso com a qualidade e a usabilidade. '
                'Combinamos tecnologia de ponta com conhecimento especializado para desenvolver ferramentas '
                'que realmente fazem a diferença no dia a dia de nossos usuários.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // Estatísticas
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final stats = [
                  {
                    'number': '6+',
                    'label': 'Aplicativos',
                  },
                  {
                    'number': '50k+',
                    'label': 'Usuários',
                  },
                  {
                    'number': '4.8',
                    'label': 'Avaliação média',
                  },
                ];

                if (isMobile) {
                  return Column(
                    children:
                        stats.map((stat) => _buildStatItem(stat)).toList(),
                  );
                } else {
                  return SizedBox(
                    width: 1120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: stats.map((stat) {
                        return Expanded(
                          child: _buildStatItem(stat),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, String> stat) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            stat['number']!,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['label']!,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Aplicativos
  Widget _buildAppsSection() {
    return Container(
      key: _appsSection,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.grey[50],
      child: Column(
        children: [
          const Text(
            'Nossas Soluções Digitais',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 4,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Conheça nossa coleção de aplicativos desenvolvidos para transformar o agronegócio. '
              'Cada solução foi criada pensando nas necessidades reais do campo.',
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.grey[800],
              ),
              // textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          const AppsSection(),
        ],
      ),
    );
  }

  // Depoimentos
  Widget _buildTestimonials() {
    return Container(
      key: _testimonialsSection,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'O Que Nossos Usuários Dizem',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 4,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 40),
          const TestimonialSection(), // Corrigido o nome do componente
        ],
      ),
    );
  }

  // Apps na Mídia
  Widget _buildMediaFeatures() {
    return const MidiaSection();
  }

  // Call to action
  Widget _buildContactForm() {
    return const ContactForm();
  }

  // Footer
  Widget _buildFooter() {
    return const FooterSection();
  }
}
