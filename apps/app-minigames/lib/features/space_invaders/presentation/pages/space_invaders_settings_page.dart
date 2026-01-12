import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/space_invaders_settings.dart';
import '../providers/space_invaders_data_providers.dart';

class SpaceInvadersSettingsPage extends ConsumerWidget {
  const SpaceInvadersSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(spaceInvadersSettingsProvider);

    return GamePageLayout(
      title: 'Configurações - Space Invaders',
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
              _SectionTitle(title: 'Dificuldade'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: SpaceInvadersDifficulty.values.map((difficulty) {
                      return RadioListTile<SpaceInvadersDifficulty>(
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
              const SizedBox(height: 24),
              _SectionTitle(title: 'Debug'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: SwitchListTile(
                  title: const Text('Mostrar FPS', style: TextStyle(color: Colors.white)),
                  value: settings.showFPS,
                  onChanged: (value) => _updateSettings(ref, settings.copyWith(showFPS: value)),
                  activeColor: const Color(0xFF4CAF50),
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

  void _updateSettings(WidgetRef ref, SpaceInvadersSettings settings) {
    final updater = ref.read(spaceInvadersSettingsUpdaterProvider.notifier);
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
