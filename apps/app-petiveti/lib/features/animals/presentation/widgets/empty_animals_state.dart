import 'package:flutter/material.dart';
import '../../../../shared/widgets/ui_components.dart';

/// **Enhanced Empty Animals State**
/// 
/// Improved empty state using the standardized UIComponents library
/// for consistency across the application and better user experience.
/// 
/// Features:
/// - Engaging empty state design
/// - Clear call-to-action guidance
/// - Accessibility optimized
/// - Consistent with app design system
class EmptyAnimalsState extends StatelessWidget {
  const EmptyAnimalsState({super.key});

  @override
  Widget build(BuildContext context) {
    return UIComponents.emptyState(
      icon: Icons.pets,
      title: 'Nenhum pet cadastrado',
      subtitle: 'Adicione seu primeiro pet para começar a cuidar da saúde e bem-estar dele!',
      actionLabel: 'Adicionar Primeiro Pet',
      onAction: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Use o botão flutuante (🐾) para adicionar um pet!'),
            duration: Duration(seconds: 3),
          ),
        );
      },
      secondaryActionLabel: 'Saiba Mais',
      onSecondaryAction: () {
        _showWelcomeDialog(context);
      },
    );
  }

  /// **Welcome Information Dialog**
  /// 
  /// Provides helpful information about the animals feature
  /// for first-time users.
  static void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pets, color: Colors.blue),
            SizedBox(width: 12),
            Text('Bem-vindo ao PetiVeti!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aqui você pode:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _InfoItem(
              icon: Icons.add_circle,
              text: 'Cadastrar seus pets com todas as informações',
            ),
            _InfoItem(
              icon: Icons.medical_services,
              text: 'Acompanhar histórico de saúde e medicamentos',
            ),
            _InfoItem(
              icon: Icons.event,
              text: 'Agendar consultas e lembretes importantes',
            ),
            _InfoItem(
              icon: Icons.analytics,
              text: 'Monitorar peso e condição corporal',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// **Helper Widget for Info Items**
/// 
/// Displays an icon with descriptive text in a consistent format.
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}