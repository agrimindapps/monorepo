import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';

/// Página de seleção de calculadoras pecuárias (criação de animais)
class LivestockSelectionPage extends StatelessWidget {
  const LivestockSelectionPage({super.key});

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
                                Icons.pets,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Calculadoras Pecuárias',
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
                            'Ferramentas para auxiliar no manejo e criação de animais: '
                            'gado, suínos, aves e outros.',
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

                  // Calculator Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: const [
                          _CalculatorCard(
                            title: 'Ração',
                            subtitle: 'Consumo de animais',
                            icon: Icons.pets,
                            color: Colors.red,
                            route: '/calculators/agriculture/feed',
                          ),
                          _CalculatorCard(
                            title: 'Ganho Peso',
                            subtitle: 'Tempo para meta',
                            icon: Icons.monitor_weight,
                            color: Colors.teal,
                            route: '/calculators/agriculture/weight-gain',
                          ),
                          _CalculatorCard(
                            title: 'Reprodução',
                            subtitle: 'Ciclo e gestação',
                            icon: Icons.child_friendly,
                            color: Colors.pink,
                            route: '/calculators/agriculture/breeding-cycle',
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

class _CalculatorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _CalculatorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
