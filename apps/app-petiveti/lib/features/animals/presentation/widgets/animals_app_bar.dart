import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/animals_provider.dart';

class AnimalsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AnimalsAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Meus Pets'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Busca - Em breve!')),
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'sync':
                _syncAnimals(context, ref);
                break;
              case 'settings':
                context.go('/settings');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync',
              child: Row(
                children: [
                  Icon(Icons.sync),
                  SizedBox(width: 8),
                  Text('Sincronizar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _syncAnimals(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Sincronizando...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Trigger sync through repository
    await ref.read(animalsProvider.notifier).loadAnimals();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}