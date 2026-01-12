import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/publish_catalog_button.dart';
import 'bovines_list_page.dart';

/// Admin page for livestock catalog management
///
/// Provides access to:
/// - Full CRUD operations (inherited from BovinesListPage)
/// - Publish catalog button (admin-only)
/// - Catalog statistics and metadata
class AdminLivestockPage extends ConsumerWidget {
  const AdminLivestockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Gestão de Catálogo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Admin control panel
          Container(
            color: Colors.deepPurple.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.deepPurple.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Administrador',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Você tem acesso completo para gerenciar o catálogo',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Publish button
                const PublishCatalogButton(),
                const SizedBox(height: 8),
                // Instructions
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use o botão "Publicar" após adicionar ou editar animais para disponibilizar as atualizações aos usuários.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Bovines list (inherited functionality)
          const Expanded(
            child: BovinesListPage(),
          ),
        ],
      ),
    );
  }
}
