import 'package:flutter/material.dart';

import '../../constants/settings_design_tokens.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// About app section
/// Shows app information and about dialog
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Sobre',
          icon: SettingsDesignTokens.infoIcon,
          showIcon: true,
        ),
        SettingsCard(
          child: SettingsListTile(
            leadingIcon: Icons.info_outline,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: 'Sobre o App',
            subtitle: 'Informações do aplicativo',
            onTap: () => _showAboutDialog(context),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.science,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('ReceitaAgro'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Versão 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'O ReceitaAgro é um compêndio completo de pragas agrícolas, oferecendo diagnósticos precisos e receitas de defensivos para agricultores e profissionais do setor.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'RECURSOS:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                '''• Diagnóstico de pragas agrícolas
• Receitas de defensivos
• Base de dados completa
• Interface intuitiva
• Busca avançada''',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Desenvolvido com 💚 para agricultores',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}