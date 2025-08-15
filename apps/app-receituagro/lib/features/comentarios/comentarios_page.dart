import 'package:flutter/material.dart';
import '../../core/widgets/modern_header_widget.dart';

class ComentariosPage extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return const _ComentariosPageContent();
  }
}

class _ComentariosPageContent extends StatelessWidget {
  const _ComentariosPageContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(context, isDark),
            Expanded(
              child: _buildEmptyState(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddComentario(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Comentários',
      subtitle: 'Suas anotações pessoais',
      leftIcon: Icons.comment_outlined,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      rightIcon: Icons.info_outline,
      onRightIconPressed: () => _showInfoDialog(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.comment_outlined,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum comentário ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas anotações pessoais',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _onAddComentario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Comentário'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Digite seu comentário...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre Comentários'),
        content: const Text(
          'Use esta seção para criar anotações pessoais sobre suas experiências '
          'com culturas, pragas e defensivos. Seus comentários ficam salvos '
          'localmente e podem ser filtrados por contexto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}