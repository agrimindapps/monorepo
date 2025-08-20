// Flutter imports:
import 'package:flutter/material.dart';

/// Widget reutilizável para criar cabeçalhos de seções de formulário
/// com um padrão visual consistente.
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
