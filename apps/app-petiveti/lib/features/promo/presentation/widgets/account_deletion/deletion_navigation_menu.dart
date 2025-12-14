import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Menu de navegação para página de exclusão
/// Adaptado para Petiveti
class DeletionNavigationMenu extends StatelessWidget {
  const DeletionNavigationMenu({
    super.key,
    required this.onSectionSelected,
  });

  final void Function(String section) onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = MediaQuery.of(context).size.width < 800;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/promo'),
                child: Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: Colors.teal.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Petiveti',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: onSectionSelected,
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'intro',
                        child: Text('Introdução'),
                      ),
                      const PopupMenuItem(
                        value: 'what_deleted',
                        child: Text('O que será deletado'),
                      ),
                      const PopupMenuItem(
                        value: 'consequences',
                        child: Text('Consequências'),
                      ),
                      const PopupMenuItem(
                        value: 'third_party',
                        child: Text('Serviços Terceiros'),
                      ),
                      const PopupMenuItem(
                        value: 'process',
                        child: Text('Processo'),
                      ),
                      const PopupMenuItem(
                        value: 'confirmation',
                        child: Text('Confirmação'),
                      ),
                      const PopupMenuItem(
                        value: 'contact',
                        child: Text('Contato'),
                      ),
                    ];
                  },
                )
              else
                Row(
                  children: [
                    _navBarButton('Introdução', () => onSectionSelected('intro')),
                    _navBarButton(
                      'O que será deletado',
                      () => onSectionSelected('what_deleted'),
                    ),
                    _navBarButton(
                      'Consequências',
                      () => onSectionSelected('consequences'),
                    ),
                    _navBarButton(
                      'Serviços Terceiros',
                      () => onSectionSelected('third_party'),
                    ),
                    _navBarButton('Processo', () => onSectionSelected('process')),
                    _navBarButton(
                      'Confirmação',
                      () => onSectionSelected('confirmation'),
                    ),
                    _navBarButton('Contato', () => onSectionSelected('contact')),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _navBarButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[800], fontSize: 14),
      ),
    );
  }
}
