import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Intro dialog shown on first launch
class IntroDialog extends StatelessWidget {
  static const String _hasSeenIntroKey = 'has_seen_intro';

  const IntroDialog({super.key});

  /// Check if user has seen intro
  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  /// Mark intro as seen
  static Future<void> markAsSecen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }

  /// Show intro dialog if not seen
  static Future<void> showIfNeeded(BuildContext context) async {
    final seen = await hasSeenIntro();
    if (!seen && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const IntroDialog(),
      );
      await markAsSeen();
    }
  }

  /// Mark intro as seen (fix typo)
  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calculate,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Bem-vindo ao Calculei!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Features
            const _FeatureItem(
              icon: Icons.calculate_outlined,
              title: '8+ Calculadoras',
              description: 'Férias, 13º, Salário Líquido e muito mais',
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.favorite_outline,
              title: 'Favoritos & Recentes',
              description: 'Acesso rápido às suas calculadoras preferidas',
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.share_outlined,
              title: 'Compartilhar Resultados',
              description: 'Compartilhe cálculos com amigos e familiares',
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.info_outline,
              title: 'Conteúdo Educativo',
              description: 'Aprenda como funciona cada cálculo',
            ),

            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
