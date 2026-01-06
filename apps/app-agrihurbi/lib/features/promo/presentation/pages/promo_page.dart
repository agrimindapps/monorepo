import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página promocional do AgriHurbi
/// Landing page para apresentar o app e suas funcionalidades
class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationBar(context),
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildStatisticsSection(context),
            _buildCallToAction(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: DesignTokens.spacingMd,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: DesignTokens.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AgriHurbi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryColor,
              foregroundColor: DesignTokens.textLightColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primaryColor.withValues(alpha: 0.05),
            DesignTokens.primaryColor.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.agriculture,
              size: 80,
              color: DesignTokens.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Gestão Agrícola Inteligente para o Produtor Moderno',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimaryColor,
                height: 1.1,
                letterSpacing: -1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Controle completo da sua propriedade rural com tecnologia de ponta. Aumente sua produtividade e reduza custos com o AgriHurbi.',
              style: TextStyle(
                fontSize: 20,
                color: DesignTokens.textSecondaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryColor,
                  foregroundColor: DesignTokens.textLightColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: DesignTokens.primaryColor.withValues(alpha: 0.4),
                ),
                child: const Text('Começar Agora'),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.primaryColor,
                  side: const BorderSide(
                    color: DesignTokens.primaryColor,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Saiba Mais'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.eco_rounded,
        'title': 'Gestão de Culturas',
        'description':
            'Monitore o desenvolvimento das suas culturas em tempo real com indicadores precisos.',
        'color': Colors.green,
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'Controle de Irrigação',
        'description':
            'Otimize o uso de água com planejamento inteligente baseado em dados climáticos.',
        'color': Colors.blue,
      },
      {
        'icon': Icons.landscape_rounded,
        'title': 'Manejo de Solo',
        'description':
            'Acompanhe a qualidade e saúde do seu solo para garantir a melhor produtividade.',
        'color': Colors.brown,
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Relatórios Detalhados',
        'description':
            'Análises completas de produtividade e custos para tomada de decisão assertiva.',
        'color': Colors.purple,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Funcionalidades'.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: DesignTokens.primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tudo que você precisa em um só lugar',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimaryColor,
              letterSpacing: -1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: features.map((feature) {
              return Container(
                width: 300,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: DesignTokens.borderColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 32,
                        color: feature['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature['description'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: DesignTokens.textSecondaryColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: DesignTokens.primaryColor,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1625246333195-58f214014a2b?q=80&w=1931&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            DesignTokens.primaryColor.withValues(alpha: 0.9),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 60,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildStatItem('1000+', 'Propriedades'),
              _buildStatItem('50mil+', 'Hectares'),
              _buildStatItem('30%', 'Mais Produtividade'),
              _buildStatItem('4.9★', 'Avaliação'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Pronto para revolucionar sua gestão?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimaryColor,
              letterSpacing: -1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Junte-se a milhares de produtores que já estão transformando seus resultados com o AgriHurbi.',
              style: TextStyle(
                fontSize: 18,
                color: DesignTokens.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: DesignTokens.accentColor.withValues(alpha: 0.4),
            ),
            child: const Text('Criar Conta Grátis'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: const Border(
          top: BorderSide(color: DesignTokens.borderColor),
        ),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                color: DesignTokens.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'AgriHurbi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '© 2025 AgriHurbi. Todos os direitos reservados.',
            style: TextStyle(
              color: DesignTokens.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
