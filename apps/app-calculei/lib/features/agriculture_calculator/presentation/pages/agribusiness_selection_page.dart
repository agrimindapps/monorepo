import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';

/// Página de seleção principal de Agropecuária (Agricultura + Pecuária)
class AgribusinessSelectionPage extends StatelessWidget {
  const AgribusinessSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CalculatorAppBar(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.agriculture,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ferramentas Agropecuárias',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calculadoras especializadas para agricultura e pecuária. '
                            'Escolha a área que deseja trabalhar.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return Column(
                        children: [
                          _CategoryCard(
                            title: 'Agricultura',
                            subtitle: '8 calculadoras para cultivo',
                            description: 'NPK, Irrigação, Semeadura, pH, Densidade, '
                                'Fertilizante, Produtividade e Evapotranspiração',
                            icon: Icons.grass,
                            color: const Color(0xFF8BC34A),
                            route: '/calculators/agriculture',
                            calculatorCount: 8,
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 16),
                          _CategoryCard(
                            title: 'Pecuária',
                            subtitle: '3 calculadoras para criação',
                            description: 'Ração, Ganho de Peso e Ciclo Reprodutivo',
                            icon: Icons.pets,
                            color: const Color(0xFFFF5722),
                            route: '/calculators/livestock',
                            calculatorCount: 3,
                            isMobile: isMobile,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final int calculatorCount;
  final bool isMobile;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.calculatorCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 40 : 48,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$calculatorCount',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
