import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home page with calculator grid
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculei - Calculadoras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 600
              ? 2 // Mobile
              : constraints.maxWidth < 900
                  ? 3 // Tablet
                  : 4; // Desktop

          return GridView.count(
            crossAxisCount: crossAxisCount,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              // Implemented calculators
              _CalculatorCard(
                title: '13º Salário',
                icon: Icons.card_giftcard,
                color: Colors.green,
                onTap: () => context.go('/calc/thirteenth-salary'),
              ),
              _CalculatorCard(
                title: 'Férias',
                icon: Icons.beach_access,
                color: Colors.blue,
                onTap: () => context.go('/calc/vacation'),
              ),

              // All calculators now implemented
              _CalculatorCard(
                title: 'Salário Líquido',
                icon: Icons.monetization_on,
                color: Colors.orange,
                onTap: () => context.go('/calc/net-salary'),
              ),
              _CalculatorCard(
                title: 'Horas Extras',
                icon: Icons.access_time,
                color: Colors.purple,
                onTap: () => context.go('/calc/overtime'),
              ),
              _CalculatorCard(
                title: 'Reserva de Emergência',
                icon: Icons.savings,
                color: Colors.teal,
                onTap: () => context.go('/calc/emergency-reserve'),
              ),
              _CalculatorCard(
                title: 'À vista ou Parcelado',
                icon: Icons.payment,
                color: Colors.indigo,
                onTap: () => context.go('/calc/cash-vs-installment'),
              ),
              _CalculatorCard(
                title: 'Seguro Desemprego',
                icon: Icons.work_off,
                color: Colors.red,
                onTap: () => context.go('/calc/unemployment-insurance'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
