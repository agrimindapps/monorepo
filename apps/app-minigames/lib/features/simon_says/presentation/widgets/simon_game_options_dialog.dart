import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/simon_settings.dart';
import '../providers/simon_data_providers.dart';
import '../providers/simon_says_controller.dart';

class SimonGameOptionsDialog extends ConsumerWidget {
  const SimonGameOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(simonSettingsProvider);

    return Dialog(
      backgroundColor: const Color(0xFF2D2D2D).withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: settingsAsync.when(
          data: (settings) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configurações do Jogo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Colors Section
                  const _SectionLabel('Número de Cores'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [2, 3, 4, 5, 6].map((count) {
                      final isSelected = settings.colorCount == count;
                      return ChoiceChip(
                        label: Text(count.toString()),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _updateSettings(
                              ref,
                              settings.copyWith(colorCount: count),
                            );
                          }
                        },
                        selectedColor: const Color(0xFFE91E63),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Difficulty Section
                  const _SectionLabel('Dificuldade'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: SimonDifficulty.values.map((difficulty) {
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Audio Section
                  const _SectionLabel('Áudio'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          dense: true,
                        ),
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
                          dense: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Accessibility
                  const _SectionLabel('Acessibilidade'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Modo Daltonismo',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Símbolos nas cores',
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

                  // Start Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref
                            .read(simonSaysControllerProvider.notifier)
                            .startGame();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'Iniciar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            ),
          ),
          error: (err, stack) => SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Erro: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateSettings(WidgetRef ref, SimonSettings settings) {
    final updater = ref.read(simonSettingsUpdaterProvider.notifier);
    updater.updateSettings(settings);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE91E63),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
