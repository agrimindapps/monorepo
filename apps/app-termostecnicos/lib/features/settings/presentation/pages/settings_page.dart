import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_providers.dart';

/// Settings/Configuration page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          // Theme Section
          ListTile(
            leading: Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Tema'),
            subtitle: Text(
              settings.isDarkMode ? 'Modo Escuro' : 'Modo Claro',
            ),
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(
                      (state) => state.copyWith(isDarkMode: value),
                    );
              },
            ),
          ),
          const Divider(),

          // TTS Settings
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Configurações de Voz'),
            subtitle: const Text('Ajustar velocidade, tom e idioma'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/config/tts');
            },
          ),
          const Divider(),

          // Premium Section (if needed)
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Premium'),
            subtitle: const Text('Gerenciar assinatura'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/premium');
            },
          ),
          const Divider(),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/sobre');
            },
          ),
        ],
      ),
    );
  }
}
