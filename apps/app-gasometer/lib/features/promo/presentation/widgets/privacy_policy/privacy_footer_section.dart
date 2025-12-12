import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyFooterSection extends StatelessWidget {
  const PrivacyFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.blue.shade900,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'GasOMeter',
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
                _footerLink('Política de Privacidade', () {}),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Termos de Uso', () => context.go('/terms')),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 12,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                _footerLink('Exclusão de Conta', () => context.go('/account-deletion')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap) {
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
