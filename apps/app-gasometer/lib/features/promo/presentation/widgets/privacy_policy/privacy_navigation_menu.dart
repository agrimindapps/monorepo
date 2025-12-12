import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyNavigationMenu extends StatelessWidget {
  const PrivacyNavigationMenu({
    super.key,
    required this.onSectionSelected,
  });

  final ValueChanged<String> onSectionSelected;

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
                      Icons.local_gas_station,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GasOMeter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
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
                        value: 'coleta',
                        child: Text('Coleta de Informações'),
                      ),
                      const PopupMenuItem(
                        value: 'logdata',
                        child: Text('Log Data'),
                      ),
                      const PopupMenuItem(
                        value: 'cookies',
                        child: Text('Cookies'),
                      ),
                      const PopupMenuItem(
                        value: 'providers',
                        child: Text('Provedores de Serviço'),
                      ),
                      const PopupMenuItem(
                        value: 'security',
                        child: Text('Segurança'),
                      ),
                      const PopupMenuItem(
                        value: 'links',
                        child: Text('Links'),
                      ),
                      const PopupMenuItem(
                        value: 'children',
                        child: Text('Privacidade Infantil'),
                      ),
                      const PopupMenuItem(
                        value: 'changes',
                        child: Text('Alterações'),
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
                    _navBarButton(
                        'Introdução', () => onSectionSelected('intro')),
                    _navBarButton(
                        'Coleta', () => onSectionSelected('coleta')),
                    _navBarButton(
                        'Log Data', () => onSectionSelected('logdata')),
                    _navBarButton(
                        'Cookies', () => onSectionSelected('cookies')),
                    _navBarButton('Provedores',
                        () => onSectionSelected('providers')),
                    _navBarButton(
                        'Segurança', () => onSectionSelected('security')),
                    _navBarButton(
                        'Links', () => onSectionSelected('links')),
                    _navBarButton(
                        'Crianças', () => onSectionSelected('children')),
                    _navBarButton(
                        'Alterações', () => onSectionSelected('changes')),
                    _navBarButton(
                        'Contato', () => onSectionSelected('contact')),
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
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }
}
