import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../premium/presentation/providers/premium_provider.dart';

class PromotionalPage extends StatefulWidget {
  const PromotionalPage({super.key});

  @override
  State<PromotionalPage> createState() => _PromotionalPageState();
}

class _PromotionalPageState extends State<PromotionalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          'Plantis Premium',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hero Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            PlantisColors.primary,
                            PlantisColors.secondary,
                            PlantisColors.accent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: PlantisColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.stars,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Eleve o cuidado das suas plantas\nao próximo nível',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Desbloqueie recursos premium e transforme\nseu jardim com tecnologia avançada',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Premium Features
                    _buildFeaturesSection(theme),

                    const SizedBox(height: 32),

                    // Pricing Section
                    _buildPricingSection(theme),

                    const SizedBox(height: 32),

                    // Benefits Section
                    _buildBenefitsSection(theme),

                    const SizedBox(height: 32),

                    // Testimonials
                    _buildTestimonialsSection(theme),

                    const SizedBox(height: 32),

                    // Call to Action
                    _buildCallToActionSection(theme, screenSize),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    final features = [
      {
        'icon': Icons.cloud_sync,
        'title': 'Sincronização na Nuvem',
        'description':
            'Mantenha seus dados seguros e sincronizados entre todos os seus dispositivos',
        'color': PlantisColors.water,
      },
      {
        'icon': Icons.analytics,
        'title': 'Relatórios Avançados',
        'description':
            'Análises detalhadas do desenvolvimento das suas plantas com gráficos interativos',
        'color': PlantisColors.leaf,
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Lembretes Inteligentes',
        'description':
            'Sistema de notificações personalizáveis baseado no tipo e necessidades de cada planta',
        'color': PlantisColors.flower,
      },
      {
        'icon': Icons.backup,
        'title': 'Backup Automático',
        'description':
            'Nunca perca suas informações com backup automático e restauração fácil',
        'color': PlantisColors.soil,
      },
      {
        'icon': Icons.camera_enhance,
        'title': 'Galeria Ilimitada',
        'description':
            'Armazene quantas fotos quiser das suas plantas com qualidade HD',
        'color': PlantisColors.sun,
      },
      {
        'icon': Icons.support_agent,
        'title': 'Suporte Prioritário',
        'description':
            'Atendimento preferencial e suporte técnico especializado em plantas',
        'color': PlantisColors.primary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos Premium',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (feature['color'] as Color).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feature['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PlantisColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PlantisColors.flower,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'OFERTA ESPECIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'R\$ ',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                  text: '12,90',
                  style: TextStyle(
                    color: PlantisColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '/mês',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Primeiro mês por apenas R\$ 4,90',
            style: TextStyle(
              color: PlantisColors.flower,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '• Cancele a qualquer momento\n• Sem taxa de adesão\n• Suporte 24/7 incluído',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.leaf.withValues(alpha: 0.1),
            PlantisColors.water.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: PlantisColors.leaf, size: 28),
              const SizedBox(width: 12),
              Text(
                'Por que escolher o Premium?',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            '📈 Mais produtividade',
            'Automação de tarefas e lembretes inteligentes economizam seu tempo',
            theme,
          ),
          _buildBenefitItem(
            '🌱 Plantas mais saudáveis',
            'Cuidados baseados em dados científicos e análises personalizadas',
            theme,
          ),
          _buildBenefitItem(
            '☁️ Segurança garantida',
            'Backup automático protege anos de cuidado com suas plantas',
            theme,
          ),
          _buildBenefitItem(
            '📱 Acesso em qualquer lugar',
            'Sincronização permite acesso aos dados em todos os dispositivos',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: PlantisColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(ThemeData theme) {
    final testimonials = [
      {
        'name': 'Maria Silva',
        'text':
            'O Plantis Premium transformou minha experiência! Minhas plantas nunca estiveram tão saudáveis.',
        'rating': 5,
      },
      {
        'name': 'João Santos',
        'text':
            'Os relatórios avançados me ajudaram a entender melhor as necessidades das minhas plantas.',
        'rating': 5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que nossos usuários dizem',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        testimonial['rating'] as int,
                        (index) => const Icon(
                          Icons.star,
                          color: PlantisColors.sun,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        testimonial['text'] as String,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testimonial['name'] as String,
                      style: const TextStyle(
                        color: PlantisColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallToActionSection(ThemeData theme, Size screenSize) {
    return Column(
      children: [
        // Main CTA Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: PlantisColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: PlantisColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _handleSubscription(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Começar Teste Gratuito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showMoreInfo(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PlantisColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Saber Mais',
                  style: TextStyle(
                    color: PlantisColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _shareApp(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PlantisColors.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Compartilhar',
                  style: TextStyle(
                    color: PlantisColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.go(AppRouter.login),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: PlantisColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.login,
              color: PlantisColors.primary,
              size: 20,
            ),
            label: const Text(
              'Já tenho conta - Fazer Login',
              style: TextStyle(
                color: PlantisColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Terms and conditions
        Text(
          'Teste gratuito por 7 dias, depois R\$ 12,90/mês.\nCancele a qualquer momento.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleSubscription(BuildContext context) {
    final premiumProvider = context.read<PremiumProvider?>();

    if (premiumProvider == null) {
      _showSubscriptionConfirmation(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Iniciar Teste Premium',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você está prestes a iniciar seu teste gratuito de 7 dias do Plantis Premium.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlantisColors.leaf.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Seus benefícios incluem:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Sincronização na nuvem\n• Backup automático\n• Relatórios avançados\n• Suporte prioritário',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startPremiumTrial(context, premiumProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Iniciar Teste'),
              ),
            ],
          ),
    );
  }

  void _startPremiumTrial(
    BuildContext context,
    PremiumProvider premiumProvider,
  ) async {
    // Try to purchase the first available product (trial)
    if (premiumProvider.availableProducts.isNotEmpty) {
      final firstProduct = premiumProvider.availableProducts.first;
      final success = await premiumProvider.purchaseProduct(
        firstProduct.productId,
      );

      if (success && context.mounted) {
        _showSuccessMessage(context, 'Teste premium iniciado com sucesso!');
      } else if (context.mounted) {
        _showSubscriptionConfirmation(context);
      }
    } else {
      _showSubscriptionConfirmation(context);
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlantisColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSubscriptionConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Funcionalidade em desenvolvimento! Em breve você poderá assinar o premium.',
        ),
        backgroundColor: PlantisColors.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showMoreInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Sobre o Plantis Premium',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'O Plantis Premium oferece recursos avançados para jardineiros que querem levar o cuidado das plantas ao próximo nível.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🌱 Recursos Inclusos:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Plantas ilimitadas\n'
                    '• Lembretes inteligentes personalizados\n'
                    '• Backup automático na nuvem\n'
                    '• Análises detalhadas de crescimento\n'
                    '• Identificação de plantas por IA\n'
                    '• Diagnóstico de doenças\n'
                    '• Temas personalizados\n'
                    '• Suporte prioritário 24/7',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Por que Premium?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Com o Premium, suas plantas ficam mais saudáveis através de cuidados baseados em dados científicos e tecnologia avançada.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PlantisColors.leaf.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: PlantisColors.leaf.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: PlantisColors.leaf),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Teste grátis por 7 dias, depois R\$ 12,90/mês. Cancele a qualquer momento.',
                            style: TextStyle(
                              color: PlantisColors.leaf.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleSubscription(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Iniciar Teste'),
              ),
            ],
          ),
    );
  }

  void _shareApp(BuildContext context) {
    // Show sharing dialog with app information
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Compartilhar Plantis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ajude seus amigos a cuidarem melhor das plantas deles!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlantisColors.leaf.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PlantisColors.leaf.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plantis - Cuidado de Plantas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cuide das suas plantas com amor e tecnologia. O melhor app para jardineiros iniciantes e experientes!',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Lembretes inteligentes\n'
                        '• Diário visual das plantas\n'
                        '• Dicas personalizadas\n'
                        '• Organização por espaços',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Copie o texto acima e compartilhe onde quiser!',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Obrigado por compartilhar o Plantis! 🌱'),
                      backgroundColor: PlantisColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Compartilhar'),
              ),
            ],
          ),
    );
  }
}
