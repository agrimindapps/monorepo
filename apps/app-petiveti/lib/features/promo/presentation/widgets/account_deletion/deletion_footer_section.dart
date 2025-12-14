import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Footer section para página de exclusão
/// Adaptado para Petiveti
class DeletionFooterSection extends StatelessWidget {
  const DeletionFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.teal.shade800,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Petiveti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© ${DateTime.now().year} Agrimind Apps. Todos os direitos reservados.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerLink(
                  context,
                  'Política de Privacidade',
                  () => context.go('/privacy-policy'),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink(
                  context,
                  'Termos de Uso',
                  () => context.go('/terms-of-service'),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink(context, 'Exclusão de Conta', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
