import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';

class MemorySettingsPage extends ConsumerWidget {
  const MemorySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Configurações - Memory',
      accentColor: const Color(0xFF9C27B0),
      maxGameWidth: 600,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Áudio'),
            Card(
              color: Colors.black.withValues(alpha: 0.3),
              child: SwitchListTile(
                title: const Text('Efeitos Sonoros', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Sons ao virar cartas e encontrar pares',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
                value: true,
                onChanged: (value) {
                  // TODO: Implement sound settings
                },
                activeColor: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Aparência'),
            Card(
              color: Colors.black.withValues(alpha: 0.3),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Animações', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'Animações ao virar cartas',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                    ),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement animation settings
                    },
                    activeColor: const Color(0xFF9C27B0),
                  ),
                  SwitchListTile(
                    title: const Text('Tema Escuro', style: TextStyle(color: Colors.white)),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement theme settings
                    },
                    activeColor: const Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Configurações disponíveis em breve',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9C27B0),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
