import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet showing options to add new records
class AddOptionsBottomSheet extends StatelessWidget {
  const AddOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ir para',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Options list
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _AddOptionTile(
                  icon: Icons.local_gas_station,
                  iconColor: Colors.green,
                  title: 'Abastecimentos',
                  subtitle: 'Ver e adicionar abastecimentos',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/fuel');
                  },
                ),
                _AddOptionTile(
                  icon: Icons.build,
                  iconColor: Colors.orange,
                  title: 'Manutenções',
                  subtitle: 'Ver e adicionar manutenções',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/maintenance');
                  },
                ),
                _AddOptionTile(
                  icon: Icons.attach_money,
                  iconColor: Colors.red,
                  title: 'Despesas',
                  subtitle: 'Ver e adicionar despesas',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/expenses');
                  },
                ),
                _AddOptionTile(
                  icon: Icons.speed,
                  iconColor: Colors.blue,
                  title: 'Odômetro',
                  subtitle: 'Ver e adicionar leituras',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/odometer');
                  },
                ),
                _AddOptionTile(
                  icon: Icons.directions_car,
                  iconColor: Colors.purple,
                  title: 'Veículos',
                  subtitle: 'Ver e cadastrar veículos',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/vehicles');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Individual option tile in the bottom sheet
class _AddOptionTile extends StatelessWidget {
  const _AddOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
