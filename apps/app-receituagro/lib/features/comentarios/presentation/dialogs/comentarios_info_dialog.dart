import 'package:flutter/material.dart';

/// **COMENTARIOS INFO DIALOG**
/// 
/// Informational dialog explaining the Comentarios feature.
/// Provides context and usage instructions for users.
/// 
/// ## Features:
/// 
/// - **Feature Explanation**: Clear description of comentarios functionality
/// - **Usage Guidelines**: How to effectively use the feature
/// - **Visual Design**: Consistent with app-receituagro design system
/// - **Accessibility**: Proper semantic structure

class ComentariosInfoDialog extends StatelessWidget {
  const ComentariosInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildTitle(),
      content: _buildContent(theme),
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info_outline,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Sobre Comentários',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            icon: Icons.edit_note,
            title: 'O que são Comentários?',
            description: 'Crie anotações pessoais sobre suas experiências com '
                        'culturas, pragas, doenças e defensivos agrícolas.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.folder_outlined,
            title: 'Organização',
            description: 'Seus comentários são organizados por contexto, '
                        'permitindo filtrar por ferramenta ou item específico.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.phone_android,
            title: 'Armazenamento',
            description: 'Os comentários ficam salvos localmente no seu '
                        'dispositivo para acesso offline.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.diamond,
            title: 'Recurso Premium',
            description: 'A criação e edição de comentários está disponível '
                        'apenas para assinantes premium.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.check, size: 18),
        label: const Text(
          'Entendi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
        ),
      ),
    ];
  }

  /// Factory constructor for simple info dialog
  static ComentariosInfoDialog simple() {
    return const ComentariosInfoDialog();
  }

  /// Show info dialog as a static method
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => const ComentariosInfoDialog(),
    );
  }
}