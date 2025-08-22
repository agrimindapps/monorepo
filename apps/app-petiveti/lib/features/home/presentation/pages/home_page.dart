import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetiVeti'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              icon: Icons.pets,
              title: 'Meus Pets',
              subtitle: 'Gerencie seus animais',
              route: '/animals',
              color: Colors.blue,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.calendar_today,
              title: 'Consultas',
              subtitle: 'Agende e acompanhe',
              route: '/appointments',
              color: Colors.green,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.vaccines,
              title: 'Vacinas',
              subtitle: 'Controle de vacinas',
              route: '/vaccines',
              color: Colors.orange,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.medication,
              title: 'Medicamentos',
              subtitle: 'Gerencie medicações',
              route: '/medications',
              color: Colors.red,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.monitor_weight,
              title: 'Peso',
              subtitle: 'Controle de peso',
              route: '/weight',
              color: Colors.purple,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.calculate,
              title: 'Calculadoras',
              subtitle: 'Ferramentas veterinárias',
              route: '/calculators',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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