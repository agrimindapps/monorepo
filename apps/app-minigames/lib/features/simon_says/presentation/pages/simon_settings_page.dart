import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/simon_settings.dart';
import '../providers/simon_data_providers.dart';

class SimonSettingsPage extends ConsumerWidget {
  const SimonSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(simonSettingsProvider);

    return GamePageLayout(
      title: 'Configurações - Genius',
      accentColor: const Color(0xFFE91E63),
      maxGameWidth: 600,
      child: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio Section
              _SectionTitle(title: 'Áudio'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Sons',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.soundEnabled,
                        onChanged: (value) {
                          _updateSettings(
                            ref,
                            settings.copyWith(soundEnabled: value),
                          );
                        },
                        activeColor: const Color(0xFFE91E63),
                      ),
                      if (settings.soundEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.volume_down,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              Expanded(
                                child: Slider(
                                  value: settings.soundVolume,
                                  onChanged: (value) {
                                    _updateSettings(
                                      ref,
                                      settings.copyWith(soundVolume: value),
                                    );
                                  },
                                  activeColor: const Color(0xFFE91E63),
                                  inactiveColor: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              Icon(
                                Icons.volume_up,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),
                      const Divider(color: Colors.white24),
                      SwitchListTile(
                        title: const Text(
                          'Música',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: settings.musicEnabled,
                        onChanged: (value) {
                          _updateSettings(
                            ref,
                            settings.copyWith(musicEnabled: value),
                          );
                        },
                        activeColor: const Color(0xFFE91E63),
                      ),
                      if (settings.musicEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.volume_down,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              Expanded(
                                child: Slider(
                                  value: settings.musicVolume,
                                  onChanged: (value) {
                                    _updateSettings(
                                      ref,
                                      settings.copyWith(musicVolume: value),
                                    );
                                  },
                                  activeColor: const Color(0xFFE91E63),
                                  inactiveColor: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              Icon(
                                Icons.volume_up,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Gameplay Section
              _SectionTitle(title: 'Jogabilidade'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dificuldade',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...SimonDifficulty.values.map((difficulty) {
                        return RadioListTile<SimonDifficulty>(
                          title: Row(
                            children: [
                              Text(
                                difficulty.label,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${difficulty.sequenceDelayMs}ms)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          value: difficulty,
                          groupValue: settings.difficulty,
                          onChanged: (value) {
                            if (value != null) {
                              _updateSettings(
                                ref,
                                settings.copyWith(difficulty: value),
                              );
                            }
                          },
                          activeColor: const Color(0xFFE91E63),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Accessibility Section
              _SectionTitle(title: 'Acessibilidade'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: SwitchListTile(
                  title: const Text(
                    'Modo Daltonismo',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Adiciona símbolos às cores',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  value: settings.colorblindMode,
                  onChanged: (value) {
                    _updateSettings(
                      ref,
                      settings.copyWith(colorblindMode: value),
                    );
                  },
                  activeColor: const Color(0xFFE91E63),
                ),
              ),

              const SizedBox(height: 32),

              // Reset Button
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar Padrões'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE91E63),
          ),
        ),
        error: (error, _) => Center(
          child: Text(
            'Erro ao carregar configurações: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _updateSettings(WidgetRef ref, SimonSettings settings) {
    final updater = ref.read(simonSettingsUpdaterProvider.notifier);
    updater.updateSettings(settings);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text(
          'Deseja restaurar todas as configurações para os valores padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updater = ref.read(simonSettingsUpdaterProvider.notifier);
      await updater.updateSettings(const SimonSettings());
    }
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
        style: const TextStyle(
          color: Color(0xFFE91E63),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
