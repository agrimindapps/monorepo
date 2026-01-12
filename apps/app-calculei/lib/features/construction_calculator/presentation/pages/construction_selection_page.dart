import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/calculator_app_bar.dart';

/// Selection page for construction calculators
class ConstructionCalculatorSelectionPage extends StatelessWidget {
  const ConstructionCalculatorSelectionPage({super.key});

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
                  // Header Card
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
                                Icons.construction,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Calculadoras para Obra',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Calcule materiais, quantidades e custos para sua construção.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8),
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: _calculators.map((calc) {
                          return _CalculatorCard(
                            title: calc.title,
                            description: calc.description,
                            icon: calc.icon,
                            color: calc.color,
                            onTap: () => context.push(calc.route),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tips Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Dicas',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _TipItem(
                            text: 'Sempre adicione uma margem de segurança nos cálculos',
                          ),
                          const _TipItem(
                            text: 'Verifique as dimensões no local antes de comprar',
                          ),
                          const _TipItem(
                            text: 'Consulte um profissional para obras estruturais',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final List<_CalculatorInfo> _calculators = [
    const _CalculatorInfo(
      title: 'Concreto',
      description: 'Volume e materiais',
      icon: Icons.layers,
      color: Colors.grey,
      route: '/calculators/construction/concrete',
    ),
    const _CalculatorInfo(
      title: 'Ferragem',
      description: 'Armadura de aço',
      icon: Icons.architecture,
      color: Colors.blueGrey,
      route: '/calculators/construction/rebar',
    ),
    const _CalculatorInfo(
      title: 'Caixa d\'Água',
      description: 'Dimensionamento',
      icon: Icons.water_drop,
      color: Colors.blue,
      route: '/calculators/construction/water-tank',
    ),
    const _CalculatorInfo(
      title: 'Elétrica',
      description: 'Instalação e dimensionamento',
      icon: Icons.bolt,
      color: Colors.amber,
      route: '/calculators/construction/electrical',
    ),
    const _CalculatorInfo(
      title: 'Tinta',
      description: 'Litros necessários',
      icon: Icons.format_paint,
      color: Colors.orange,
      route: '/calculators/construction/paint',
    ),
    const _CalculatorInfo(
      title: 'Piso',
      description: 'Peças e caixas',
      icon: Icons.grid_on,
      color: Colors.brown,
      route: '/calculators/construction/flooring',
    ),
    const _CalculatorInfo(
      title: 'Tijolos',
      description: 'Unidades e argamassa',
      icon: Icons.crop_square,
      color: Colors.red,
      route: '/calculators/construction/brick',
    ),
    const _CalculatorInfo(
      title: 'Drywall',
      description: 'Gesso acartonado',
      icon: Icons.view_column,
      color: Colors.teal,
      route: '/calculators/construction/drywall',
    ),
    const _CalculatorInfo(
      title: 'Telhado',
      description: 'Telhas e madeiramento',
      icon: Icons.roofing,
      color: Colors.deepOrange,
      route: '/calculators/construction/roof',
    ),
  ];
}

class _CalculatorInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _CalculatorInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _CalculatorCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CalculatorCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
