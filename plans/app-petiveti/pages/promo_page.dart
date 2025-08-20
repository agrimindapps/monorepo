// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'login_web_page.dart';

// Moved enum to top-level of file
enum AppPlatform { android, iOS }

class PetiVetiPromoPage extends StatelessWidget {
  const PetiVetiPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: PromoContent(),
      ),
    );
  }
}

class PromoContent extends StatelessWidget {
  PromoContent({super.key});

  // Scroll controller para navegação suave entre seções
  final ScrollController _scrollController = ScrollController();

  // Cores do tema
  final Color primaryColor = const Color(0xFF6A1B9A); // Roxo principal
  final Color accentColor = const Color(0xFF03A9F4); // Azul accent
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF333333);

  // Global keys para cada seção para navegação
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  // Altura aproximada de cada seção para scroll suave
  final Map<String, double> _sectionOffsets = {
    'inicio': 0,
    'recursos': 700,
    'depoimentos': 1400,
    'faq': 2100,
    'download': 2800,
  };

  void _scrollToSection(String section) {
    _scrollController.animateTo(
      _sectionOffsets[section] ?? 0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PetiVetiLoginWebPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 900;
    final bool isTablet = screenSize.width > 600 && screenSize.width <= 900;
    // Removendo variável não utilizada isUltraWide

    return Stack(
      children: [
        Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Espaço para a barra de navegação fixa
                SizedBox(height: isDesktop ? 80 : 60),

                // Header Hero Section
                _buildHeroSection(context, isDesktop),

                // Features
                Container(
                  key: _featuresKey,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: _buildFeaturesSection(context, isDesktop, isTablet),
                  ),
                ),

                // Testimonials
                Container(
                  key: _testimonialsKey,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child:
                        _buildTestimonialsSection(context, isDesktop, isTablet),
                  ),
                ),

                // FAQ Section
                Container(
                  key: _faqKey,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: _buildFAQSection(context, isDesktop),
                  ),
                ),

                // CTA Download Section
                Container(
                  key: _downloadKey,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: _buildDownloadSection(context, isDesktop),
                  ),
                ),

                // Footer
                _buildFooter(context, isDesktop),
              ],
            ),
          ),
        ),

        // Barra de navegação fixa no topo
        _buildNavBar(context, isDesktop),
      ],
    );
  }

  // Barra de navegação fixa no topo
  Widget _buildNavBar(BuildContext context, bool isDesktop) {
    return Container(
      height: isDesktop ? 80 : 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Logo
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: primaryColor,
                    size: isDesktop ? 32 : 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PetiVeti',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Menu de navegação
              if (isDesktop) ...[
                _buildNavLink('Início', () => _scrollToSection('inicio')),
                _buildNavLink('Recursos', () => _scrollToSection('recursos')),
                _buildNavLink(
                    'Depoimentos', () => _scrollToSection('depoimentos')),
                _buildNavLink('FAQ', () => _scrollToSection('faq')),
                _buildNavLink('Download', () => _scrollToSection('download')),
                const SizedBox(width: 15),
                OutlinedButton(
                  onPressed: () => _navigateToLogin(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ] else ...[
                // Menu móvel para dispositivos menores
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _navigateToLogin(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _showMobileMenu(context);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Início'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection('inicio');
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Recursos'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection('recursos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.rate_review),
                title: const Text('Depoimentos'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection('depoimentos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('FAQ'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection('faq');
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection('download');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Hero Section with App Intro
  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 120.0 : 60.0,
              horizontal: 20.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isDesktop)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: _buildHeroContent(),
                        ),
                      ),
                    Expanded(
                      flex: isDesktop ? 5 : 10,
                      child: _buildAppPreview(),
                    ),
                    if (!isDesktop) const SizedBox(height: 40),
                  ],
                ),
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: _buildHeroContent(),
                  ),
                const SizedBox(height: 30),
                _buildStoreButtons(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'PetiVeti',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Cuidados completos para seu melhor amigo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'EM BREVE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 4,
          color: accentColor,
        ),
        const SizedBox(height: 20),
        const Text(
          'O aplicativo mais completo para tutores que se preocupam com a saúde e bem-estar de seus pets. Acompanhe vacinas, medicamentos, peso, consultas e muito mais.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildLaunchDate(),
        const SizedBox(height: 30),
        Container(
          width: 250,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB400), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showPreRegisterDialog(AppPlatform.android),
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Quero ser Notificado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para contagem regressiva
  Widget _buildLaunchDate() {
    // Data de lançamento prevista (exemplo: 3 meses no futuro)
    final launchDate = DateTime(2025, 10, 1);
    final now = DateTime.now();
    final daysRemaining = launchDate.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            'LANÇAMENTO PREVISTO PARA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${launchDate.day}/${launchDate.month}/${launchDate.year}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Faltam apenas $daysRemaining dias',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.timer, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreview() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.white70,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoreButtons(bool isDesktop) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 20,
      runSpacing: 10,
      children: [
        _buildWaitlistButton(
          'Avise-me - Google Play',
          Icons.android,
          () => _showPreRegisterDialog(AppPlatform.android),
          isDesktop,
        ),
        _buildWaitlistButton(
          'Avise-me - App Store',
          Icons.apple,
          () => _showPreRegisterDialog(AppPlatform.iOS),
          isDesktop,
        ),
      ],
    );
  }

  void _showPreRegisterDialog(AppPlatform platform) {
    final platformName =
        platform == AppPlatform.android ? 'Google Play' : 'App Store';

    final context = _scrollController.position.context.notificationContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PreRegisterDialog(
        platformName: platformName,
        primaryColor: primaryColor,
      ),
    );
  }

  Widget _buildWaitlistButton(
      String store, IconData icon, VoidCallback onTap, bool isDesktop) {
    return Container(
      height: 56,
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EM BREVE NA',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: isDesktop ? 10 : 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              store.replaceAll('Avise-me - ', '').toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 14 : 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // Features Section
  Widget _buildFeaturesSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    final featuresData = [
      {
        'icon': Icons.pets,
        'color': Colors.purple[700],
        'title': 'Perfis de Pet',
        'description':
            'Crie perfis detalhados para todos os seus animais de estimação com raça, idade, peso e muito mais.'
      },
      {
        'icon': Icons.local_hospital,
        'color': Colors.red[600],
        'title': 'Vacinas',
        'description':
            'Acompanhe o calendário de vacinação e receba notificações para nunca perder uma data importante.'
      },
      {
        'icon': Icons.medication,
        'color': Colors.green[700],
        'title': 'Medicamentos',
        'description':
            'Gerencie os medicamentos, doses e horários para garantir tratamentos eficazes.'
      },
      {
        'icon': Icons.monitor_weight,
        'color': Colors.orange[700],
        'title': 'Controle de Peso',
        'description':
            'Acompanhe a evolução do peso do seu animal com gráficos intuitivos.'
      },
      {
        'icon': Icons.event_note,
        'color': Colors.blue[600],
        'title': 'Histórico de Consultas',
        'description':
            'Mantenha um registro completo de todas as consultas veterinárias, diagnósticos e recomendações.'
      },
      {
        'icon': Icons.alarm,
        'color': Colors.teal[700],
        'title': 'Lembretes',
        'description':
            'Configure alertas personalizados para consultas, medicamentos e outros cuidados importantes.'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80.0,
        horizontal: isDesktop ? 80.0 : 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Recursos Completos para o Cuidado do seu Pet',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            width: 80,
            height: 4,
            color: primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Tudo o que você precisa para cuidar da saúde e bem-estar do seu animal de estimação em um único aplicativo.',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _buildFeaturesGrid(featuresData, isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(
      List<Map<String, dynamic>> features, bool isDesktop, bool isTablet) {
    final int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 30.0,
        mainAxisSpacing: 30.0,
        mainAxisExtent: 260,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature['icon'] as IconData,
          feature['color'] as Color?,
          feature['title'] as String,
          feature['description'] as String,
        );
      },
    );
  }

  Widget _buildFeatureCard(
      IconData icon, Color? color, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Testimonials Section
  Widget _buildTestimonialsSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    final testimonials = [
      {
        'quote': '',
        'author': '',
        'role': '',
        'image': '',
      },
      {
        'quote': '',
        'author': '',
        'role': '',
        'image': '',
      },
      {
        'quote': '',
        'author': '',
        'role': '',
        'image': '',
      },
    ];

    final int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80.0,
        horizontal: isDesktop ? 80.0 : 20.0,
      ),
      child: Column(
        children: [
          Text(
            'O que os Tutores Vão Dizer',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            width: 80,
            height: 4,
            color: primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Em breve você verá aqui histórias reais de tutores que transformaram o cuidado com seus pets',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 30.0,
              mainAxisSpacing: 30.0,
              mainAxisExtent: 300,
            ),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return _buildTestimonialCard(
                testimonial['quote'] as String,
                testimonial['author'] as String,
                testimonial['role'] as String,
                testimonial['image'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
      String quote, String author, String role, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: Color(0xFF6A1B9A),
            size: 30,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Download CTA Section
  Widget _buildDownloadSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80.0,
        horizontal: isDesktop ? 80.0 : 20.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isDesktop)
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 60.0),
                  child: _buildDownloadContent(isDesktop),
                ),
              ),
            if (isDesktop)
              Expanded(
                flex: 4,
                child: _buildAppMockup(),
              ),
            if (!isDesktop)
              Expanded(
                child: Column(
                  children: [
                    _buildDownloadContent(isDesktop),
                    const SizedBox(height: 40),
                    _buildAppMockup(),
                  ],
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadContent(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 42 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: const [
              TextSpan(text: 'Pronto para '),
              TextSpan(
                text: 'Começar?',
                style: TextStyle(color: Color(0xFFFFA000)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Baixe em breve o PetiVeti e tenha controle total sobre os cuidados do seu pet com o aplicativo mais completo do mercado.',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        _buildStoreButtons(isDesktop),
        const SizedBox(height: 30),
        Row(
          children: [
            _buildFeatureBadge('Gratuito para começar', Icons.verified),
            const SizedBox(width: 20),
            _buildFeatureBadge('Dados protegidos', Icons.security),
          ],
        ),
      ],
    );
  }

  Widget _buildAppMockup() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Smartphone em destaque
        Container(
          width: 220,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Tela do app
                Container(
                  color: primaryColor,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // Interface simplificada
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.amber[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'PetiVeti',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'CONTROLE TOTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Elementos de destaque ao redor
        Positioned(
          top: 50,
          left: 30,
          child: _buildFeatureBubble(
              'Controle de vacinas', const Color(0xFF4CAF50)),
        ),
        Positioned(
          bottom: 70,
          right: 20,
          child:
              _buildFeatureBubble('Controle de peso', const Color(0xFFFFA000)),
        ),
        Positioned(
          top: 150,
          right: 40,
          child: _buildFeatureBubble(
              'Alertas de medicação', const Color(0xFFF44336)),
        ),
      ],
    );
  }

  Widget _buildFeatureBubble(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // FAQ Section
  Widget _buildFAQSection(BuildContext context, bool isDesktop) {
    final faqItems = [
      {
        'question': 'O aplicativo é gratuito?',
        'answer':
            'Sim, o PetiVeti possui uma versão gratuita com recursos essenciais. Também oferecemos uma versão premium com funcionalidades avançadas.'
      },
      {
        'question': 'Posso cadastrar mais de um animal?',
        'answer':
            'Sim! Você pode cadastrar todos os seus pets no aplicativo e gerenciar as informações de cada um separadamente.'
      },
      {
        'question': 'Os dados ficam salvos se eu trocar de celular?',
        'answer':
            'Sim, utilizamos tecnologia de sincronização em nuvem para garantir que seus dados estejam seguros e acessíveis em qualquer dispositivo.'
      },
      {
        'question': 'O app funciona offline?',
        'answer':
            'Sim, você pode usar a maioria das funcionalidades offline. Os dados serão sincronizados quando você reconectar à internet.'
      },
      {
        'question': 'Como funciona o sistema de notificações?',
        'answer':
            'O PetiVeti envia lembretes personalizáveis para vacinas, medicamentos, consultas e outros eventos importantes relacionados ao seu pet.'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80.0,
        horizontal: isDesktop ? 80.0 : 20.0,
      ),
      child: Column(
        children: [
          Text(
            'Perguntas Frequentes',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            width: 80,
            height: 4,
            color: primaryColor,
          ),
          const SizedBox(height: 60),
          _buildFAQList(faqItems, isDesktop),
        ],
      ),
    );
  }

  Widget _buildFAQList(List<Map<String, String>> faqItems, bool isDesktop) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _FAQItem(
          question: faqItems[index]['question'] ?? '',
          answer: faqItems[index]['answer'] ?? '',
        );
      },
    );
  }

  // Chave global para acessar o contexto
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Footer Section
  Widget _buildFooter(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 40.0,
        horizontal: isDesktop ? 80.0 : 20.0,
      ),
      color: const Color(0xFF2E2E2E),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '© ${DateTime.now().year} PetiVeti. Todos os direitos reservados.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              if (isDesktop)
                Row(
                  children: [
                    _buildSocialIconRefined(Icons.facebook, () {}),
                    const SizedBox(width: 12),
                    _buildSocialIconRefined(Icons.chat_bubble_outline, () {}),
                    const SizedBox(width: 12),
                    _buildSocialIconRefined(Icons.camera_alt_outlined, () {}),
                    const SizedBox(width: 12),
                    _buildSocialIconRefined(Icons.language, () {}),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconRefined(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.7),
          size: 18,
        ),
      ),
    );
  }
}

// Widget auxiliares

class _PreRegisterDialog extends StatefulWidget {
  final String platformName;
  final Color primaryColor;

  const _PreRegisterDialog({
    required this.platformName,
    required this.primaryColor,
  });

  @override
  State<_PreRegisterDialog> createState() => _PreRegisterDialogState();
}

class _PreRegisterDialogState extends State<_PreRegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simula uma requisição
      await Future.delayed(const Duration(seconds: 2));

      // Simula sucesso (aqui seria implementada a lógica real)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Obrigado! Você será notificado quando o app for lançado.',
            ),
            backgroundColor: widget.primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Trata erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ops! Algo deu errado. Tente novamente.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone e título
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: widget.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quero ser Notificado',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Descrição
              Text(
                'Deixe seus dados e seja o primeiro a saber quando o PetiVeti estiver disponível no ${widget.platformName}!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Campo Nome
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                validator: _validateName,
                decoration: InputDecoration(
                  labelText: 'Nome completo *',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.primaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: _isLoading ? Colors.grey[100] : Colors.grey[50],
                ),
              ),

              const SizedBox(height: 16),

              // Campo Email
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail *',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.primaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: _isLoading ? Colors.grey[100] : Colors.grey[50],
                ),
              ),

              const SizedBox(height: 24),

              // Botão Cadastrar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Texto de privacidade
              Center(
                child: Text(
                  'Seus dados serão usados apenas para te notificar sobre o\nlançamento do app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        expandedAlignment: Alignment.topLeft,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          widget.question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        trailing: Icon(
          _expanded ? Icons.remove : Icons.add,
          color: const Color(0xFF6A1B9A),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        children: [
          Text(
            widget.answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
