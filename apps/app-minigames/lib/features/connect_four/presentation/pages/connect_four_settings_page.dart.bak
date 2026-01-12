import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/connect_four_settings.dart';
import '../providers/connect_four_data_providers.dart';

class ConnectFourSettingsPage extends ConsumerWidget {
  const ConnectFourSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(connect_fourSettingsProvider);

    return GamePageLayout(
      title: 'Configurações - ConnectFour',
      accentColor: const Color(0xFF4CAF50),
      maxGameWidth: 600,
      child: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Áudio'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Sons', style: TextStyle(color: Colors.white)),
                      value: settings.soundEnabled,
                      onChanged: (value) => _updateSettings(ref, settings.copyWith(soundEnabled: value)),
                      activeColor: const Color(0xFF4CAF50),
                    ),
                    SwitchListTile(
                      title: const Text('Música', style: TextStyle(color: Colors.white)),
                      value: settings.musicEnabled,
                      onChanged: (value) => _updateSettings(ref, settings.copyWith(musicEnabled: value)),
                      activeColor: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Modo de Jogo'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: ConnectFourDifficulty.values.map((difficulty) {
                      return RadioListTile<ConnectFourDifficulty>(
                        title: Text(difficulty.label, style: const TextStyle(color: Colors.white)),
                        value: difficulty,
                        groupValue: settings.difficulty,
                        onChanged: (value) {
                          if (value != null) _updateSettings(ref, settings.copyWith(difficulty: value));
                        },
                        activeColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
        error: (error, _) => Center(child: Text('Erro: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  void _updateSettings(WidgetRef ref, ConnectFourSettings settings) {
    final updater = ref.read(connect_fourSettingsUpdaterProvider.notifier);
    updater.updateSettings(settings);
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
        style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
