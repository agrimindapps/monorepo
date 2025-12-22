import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/semantic_widgets.dart';

/// Tools page with utility features
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _ToolCard(
              icon: Icons.calculate,
              title: 'Calculadora\nFlex',
              description: 'Álcool ou Gasolina?',
              onTap: () {
                context.push('/tools/flex-calculator');
              },
            ),
            _ToolCard(
              icon: Icons.dashboard,
              title: 'Luzes do\nPainel',
              description: 'Entenda os indicadores',
              onTap: () {
                context.push('/tools/dashboard-indicators');
              },
            ),
            _ToolCard(
              icon: Icons.attach_money,
              title: 'Custo por\nKm',
              description: 'Quanto gasta por km',
              onTap: () {
                context.push('/tools/cost-per-km');
              },
            ),
            _ToolCard(
              icon: Icons.speed,
              title: 'Autonomia',
              description: 'Quantos km pode rodar',
              onTap: () {
                context.push('/tools/range-calculator');
              },
            ),
            _ToolCard(
              icon: Icons.bar_chart,
              title: 'Estatísticas',
              description: 'Análises e gráficos',
              onTap: () {
                context.go('/reports');
              },
            ),
            _ToolCard(
              icon: Icons.local_gas_station,
              title: 'Postos\nPróximos',
              description: 'Encontre postos',
              onTap: () {
                // TODO: Navigate to gas stations finder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em breve: Pesquisa de Postos')),
                );
              },
            ),
            _ToolCard(
              icon: Icons.file_download,
              title: 'Exportar\nDados',
              description: 'PDF ou Excel',
              onTap: () {
                // TODO: Navigate to data export
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Em breve: Exportação de Dados')),
                );
              },
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.build,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Ferramentas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Utilitários e recursos extras',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
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

/// Tool card widget
class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
