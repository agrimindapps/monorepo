import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/providers/auth_providers.dart' as local;
import '../../../core/theme/accessibility_tokens.dart';
import '../../../core/theme/colors.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin, AccessibilityFocusMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkUserLoginStatus();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _checkUserLoginStatus() {
    ref.read(local.authProvider);
    final isInitialized = ref.read(local.isInitializedProvider);
    final isAuthenticated = ref.read(local.isAuthenticatedProvider);
    if (isInitialized && isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/plants');
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final isInitialized = ref.watch(local.isInitializedProvider);
          final isAuthenticated = ref.watch(local.isAuthenticatedProvider);
          if (!isInitialized) return _buildSplashScreen();
          if (isAuthenticated) return _buildRedirectingScreen();
          return _buildLandingContent();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------

  Widget _buildSplashScreen() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PlantisColors.primary,
            PlantisColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Semantics(
          label: AccessibilityTokens.getSemanticLabel(
            'loading',
            'Carregando aplicativo Plantis',
          ),
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.eco, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Inicializando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedirectingScreen() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PlantisColors.primary,
            PlantisColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Semantics(
          label: 'Redirecionando para o aplicativo',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.eco, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Redirecionando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandingContent() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PlantisColors.primary,
            PlantisColors.primary.withOpacity(0.8),
            Colors.white,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildHeroSection(),
              _buildFeaturesSection(),
              _buildCtaSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Row(
            children: [
              Icon(Icons.eco, size: 32, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Plantis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          AccessibleButton(
            onPressed: () {
              AccessibilityTokens.performHapticFeedback('light');
              context.go('/login');
            },
            semanticLabel: AccessibilityTokens.getSemanticLabel(
              'login_button',
              'Ir para página de login',
            ),
            tooltip: 'Fazer login no aplicativo',
            minimumSize: const Size(
              AccessibilityTokens.recommendedTouchTargetSize + 32,
              AccessibilityTokens.recommendedTouchTargetSize,
            ),
            backgroundColor: Colors.white,
            foregroundColor: PlantisColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    header: true,
                    child: Text(
                      'Cuide das Suas Plantas\ncom Amor e Tecnologia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AccessibilityTokens.getAccessibleFontSize(
                          context,
                          32,
                        ),
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'O aplicativo que transforma você em um jardineiro expert.\nLembretes inteligentes, dicas personalizadas e muito mais.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: AccessibleButton(
                      onPressed: () {
                        AccessibilityTokens.performHapticFeedback('medium');
                        context.go('/login');
                      },
                      semanticLabel: 'Começar a usar o Plantis gratuitamente',
                      tooltip: 'Criar conta ou fazer login no aplicativo',
                      minimumSize: const Size(
                        double.infinity,
                        AccessibilityTokens.largeTouchTargetSize,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: PlantisColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hapticPattern: 'medium',
                      child: Text(
                        'Começar Agora - É Grátis!',
                        style: TextStyle(
                          fontSize: AccessibilityTokens.getAccessibleFontSize(
                            context,
                            18,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: Text(
              'Por que escolher o Plantis?',
              style: TextStyle(
                color: PlantisColors.primary,
                fontSize: AccessibilityTokens.getAccessibleFontSize(
                  context,
                  28,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recursos pensados para transformar sua experiência com plantas',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlantisColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildFeatureItem(
            Icons.schedule,
            'Lembretes Inteligentes',
            'Receba notificações personalizadas para regar, adubar e cuidar das suas plantas no tempo certo.',
            Colors.blue,
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            Icons.photo_camera,
            'Diário Visual',
            'Acompanhe o crescimento das suas plantas com fotos e organize suas memórias verdes.',
            Colors.green,
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            Icons.lightbulb_outline,
            'Dicas Personalizadas',
            'Receba orientações específicas baseadas no tipo, idade e condições das suas plantas.',
            Colors.orange,
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            Icons.group,
            'Organize por Espaços',
            'Gerencie plantas em diferentes ambientes: jardim, varanda, sala de estar e mais.',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: PlantisColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCtaSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PlantisColors.primary,
            PlantisColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.eco, size: 60, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            'Pronto para começar sua jornada verde?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Junte-se a milhares de pessoas que já transformaram seus lares em verdadeiros jardins.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: PlantisColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Começar Gratuitamente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '✓ Grátis para sempre  ✓ Sem cartão de crédito  ✓ Pronto em 30 segundos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 24, color: PlantisColors.primary),
              SizedBox(width: 8),
              Text(
                'Plantis',
                style: TextStyle(
                  color: PlantisColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cuidando das suas plantas com tecnologia e carinho.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlantisColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Plantis - Todos os direitos reservados',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
