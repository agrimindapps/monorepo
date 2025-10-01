import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../auth/presentation/login_page.dart';
import '../../tasks/presentation/home_page.dart';
import 'premium_page.dart';

/// Página promocional principal do Task Manager
///
/// Implementa os princípios SOLID:
/// - Single Responsibility: Responsável apenas por apresentar conteúdo promocional
/// - Open/Closed: Extensível para novos componentes sem modificar código existente
/// - Liskov Substitution: Pode substituir qualquer StatelessWidget
/// - Interface Segregation: Usa interfaces específicas para cada funcionalidade
/// - Dependency Inversion: Depende de abstrações, não de implementações concretas
class PromotionalPage extends ConsumerWidget {
  const PromotionalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal
          SingleChildScrollView(
            child: Column(
              children: [
                _HeaderSection(),
                _FeaturesSection(),
                _HowItWorksSection(),
                _TestimonialsSection(),
                _CallToActionSection(),
                _FooterSection(),
              ],
            ),
          ),
          // AppBar flutuante
          Positioned(top: 0, left: 0, right: 0, child: _buildFloatingAppBar()),
        ],
      ),
    );
  }

  Widget _buildFloatingAppBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botão de Login
            Builder(
              builder:
                  (context) => ElevatedButton.icon(
                    onPressed: () => _navigateToLogin(context),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Entrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      foregroundColor: const Color(0xFF6366F1),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
    );
  }
}

/// Seção de cabeçalho com gradiente e call-to-action principal
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo moderno
            Color(0xFF8B5CF6), // Violeta
            Color(0xFFA855F7), // Roxo claro
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 60 : 100,
            horizontal: isMobile ? 20 : 40,
          ),
          child: Column(
            children: [
              // Logo/Ícone
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.task_alt,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Título principal
              Text(
                'Task Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 48 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              // Subtítulo
              Text(
                'Organize tudo. Alcance mais.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Descrição
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'A ferramenta de produtividade que ajuda você a organizar suas tarefas, projetos e vida de forma simples e eficiente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Botões de ação
              isMobile
                  ? _buildMobileButtons(context)
                  : _buildDesktopButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrimaryButton(
          context,
          'Começar Gratuitamente',
          Icons.rocket_launch,
        ),
        const SizedBox(width: 20),
        _buildSecondaryButton(context, 'Ver Premium', Icons.star_outline),
      ],
    );
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            context,
            'Começar Gratuitamente',
            Icons.rocket_launch,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildSecondaryButton(
            context,
            'Ver Premium',
            Icons.star_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToApp(context),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6366F1),
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _navigateToPremium(context),
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  void _navigateToApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (context) => const HomePage()),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const PremiumPage()),
    );
  }
}

/// Seção de funcionalidades principais
class _FeaturesSection extends StatelessWidget {
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.task_alt,
      'title': 'Gerenciamento Intuitivo',
      'description':
          'Crie, organize e acompanhe suas tarefas com interface limpa e intuitiva.',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Notificações Inteligentes',
      'description':
          'Receba lembretes no momento certo e nunca perca prazos importantes.',
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização Total',
      'description':
          'Acesse suas tarefas em qualquer dispositivo com sincronização automática.',
    },
    {
      'icon': Icons.analytics,
      'title': 'Insights de Produtividade',
      'description':
          'Acompanhe seu progresso com relatórios e estatísticas detalhadas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Título da seção
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Recursos ',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'Poderosos',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Descubra as ferramentas que vão transformar sua produtividade',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            // Grid de funcionalidades
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: isMobile ? 1.5 : 1.2,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(_features[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    final IconData icon = feature['icon'] as IconData;
    final String title = feature['title'] as String;
    final String description = feature['description'] as String;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: const Color(0xFF6366F1)),
          ),

          const SizedBox(height: 24),

          // Título
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Descrição
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção Como Funciona
class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Título da seção
            Text(
              'Como Funciona',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 60),

            // Steps
            Column(
              children: [
                _buildStep(
                  1,
                  'Cadastre-se',
                  'Crie sua conta gratuita em segundos',
                  Icons.person_add,
                ),
                const SizedBox(height: 40),
                _buildStep(
                  2,
                  'Organize',
                  'Adicione suas tarefas e organize por projetos',
                  Icons.folder_outlined,
                ),
                const SizedBox(height: 40),
                _buildStep(
                  3,
                  'Execute',
                  'Complete tarefas e acompanhe seu progresso',
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    int number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        // Número
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Conteúdo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Ícone
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF6366F1)),
        ),
      ],
    );
  }
}

/// Seção de depoimentos (placeholder)
class _TestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text(
              'O que nossos usuários dizem',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.star_border, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Depoimentos em breve...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seção de call-to-action final
class _CallToActionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            const Text(
              'Pronto para aumentar sua produtividade?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Comece gratuitamente e descubra como o Task Manager pode transformar sua organização.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Começar Agora - É Grátis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer da página
class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Task Manager. Organize tudo. Alcance mais.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
