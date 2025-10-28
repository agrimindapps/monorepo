import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_providers.dart';

/// Settings/Configuration page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
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
                  ref.read(settingsNotifierProvider.notifier).toggleTheme();
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar configurações'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(settingsNotifierProvider);
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
