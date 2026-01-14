import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tetris_settings.dart';
import '../providers/tetris_data_providers.dart';
import '../providers/tetris_controller.dart';

class TetrisGameOptionsDialog extends ConsumerWidget {
  const TetrisGameOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(tetrisSettingsProvider);
    const primaryColor = Color(0xFF9C27B0);

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

                // Audio Section
                const _SectionLabel('Áudio'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Sons', style: TextStyle(color: Colors.white)),
                        value: settings.soundEnabled,
                        onChanged: (value) {
                          _updateSettings(
                            ref,
                            settings.copyWith(soundEnabled: value),
                          );
                        },
                        activeColor: primaryColor,
                        dense: true,
                      ),
                      if (settings.soundEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Slider(
                            value: settings.soundVolume,
                            onChanged: (value) {
                              _updateSettings(
                                ref,
                                settings.copyWith(soundVolume: value),
                              );
                            },
                            activeColor: primaryColor,
                            inactiveColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      const Divider(color: Colors.white24, height: 1),
                      SwitchListTile(
                        title: const Text('Música', style: TextStyle(color: Colors.white)),
                        value: settings.musicEnabled,
                        onChanged: (value) {
                          _updateSettings(
                            ref,
                            settings.copyWith(musicEnabled: value),
                          );
                        },
                        activeColor: primaryColor,
                        dense: true,
                      ),
                      if (settings.musicEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Slider(
                            value: settings.musicVolume,
                            onChanged: (value) {
                              _updateSettings(
                                ref,
                                settings.copyWith(musicVolume: value),
                              );
                            },
                            activeColor: primaryColor,
                            inactiveColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Gameplay Section
                const _SectionLabel('Gameplay'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text('Ghost Piece', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'Mostra onde a peça vai cair',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                    value: settings.ghostPieceEnabled,
                    onChanged: (value) {
                      _updateSettings(
                        ref,
                        settings.copyWith(ghostPieceEnabled: value),
                      );
                    },
                    activeColor: primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Visual Section
                const _SectionLabel('Visual'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: TetrisTheme.values.map((theme) {
                      return RadioListTile<TetrisTheme>(
                        title: Text(
                          theme.displayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: theme,
                        groupValue: settings.theme,
                        onChanged: (value) {
                          if (value != null) {
                            _updateSettings(
                              ref,
                              settings.copyWith(theme: value),
                            );
                          }
                        },
                        activeColor: primaryColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Start Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(tetrisControllerProvider.notifier).startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'INICIAR JOGO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: primaryColor),
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
    );
  }

  void _updateSettings(WidgetRef ref, TetrisSettings settings) {
    final actions = ref.read(tetrisSettingsActionsProvider.notifier);
    actions.updateSettings(settings);
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
        color: Color(0xFF9C27B0),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
