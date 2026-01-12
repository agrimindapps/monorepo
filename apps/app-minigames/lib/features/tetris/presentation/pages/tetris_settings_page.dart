import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/tetris_settings.dart';
import '../providers/tetris_data_providers.dart';

/// Tela de Configurações do Tetris
class TetrisSettingsPage extends ConsumerWidget {
  const TetrisSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(tetrisSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF9C27B0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 12),
            Text('Configurações'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, ref),
            tooltip: 'Restaurar padrões',
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (error, _) => Center(
          child: Text(
            'Erro ao carregar configurações',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        data: (settings) => _buildSettingsList(context, ref, settings, isDark, primaryColor),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    TetrisSettings settings,
    bool isDark,
    Color primaryColor,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Audio Section
        _buildSectionHeader('Áudio', Icons.volume_up, isDark),
        const SizedBox(height: 8),
        _buildCard(
          isDark,
          Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Sons',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Efeitos sonoros do jogo',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                value: settings.soundEnabled,
                activeColor: primaryColor,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(soundEnabled: value),
                ),
              ),
              if (settings.soundEnabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_down,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.soundVolume,
                          activeColor: primaryColor,
                          onChanged: (value) => _updateSettings(
                            ref,
                            settings.copyWith(soundVolume: value),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                title: Text(
                  'Música',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Música de fundo',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                value: settings.musicEnabled,
                activeColor: primaryColor,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(musicEnabled: value),
                ),
              ),
              if (settings.musicEnabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.musicVolume,
                          activeColor: primaryColor,
                          onChanged: (value) => _updateSettings(
                            ref,
                            settings.copyWith(musicVolume: value),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.music_note,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Gameplay Section
        _buildSectionHeader('Gameplay', Icons.sports_esports, isDark),
        const SizedBox(height: 8),
        _buildCard(
          isDark,
          SwitchListTile(
            title: Text(
              'Ghost Piece',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Mostra onde a peça vai cair',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            value: settings.ghostPieceEnabled,
            activeColor: primaryColor,
            onChanged: (value) => _updateSettings(
              ref,
              settings.copyWith(ghostPieceEnabled: value),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Visual Section
        _buildSectionHeader('Visual', Icons.palette, isDark),
        const SizedBox(height: 8),
        _buildCard(
          isDark,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tema',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...TetrisTheme.values.map((theme) {
                return RadioListTile<TetrisTheme>(
                  title: Text(
                    theme.displayName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: theme,
                  groupValue: settings.theme,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(
                        ref,
                        settings.copyWith(theme: value),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info
        Center(
          child: Text(
            'As configurações são salvas automaticamente',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, Widget child) {
    return Card(
      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  void _updateSettings(WidgetRef ref, TetrisSettings settings) {
    final actions = ref.read(tetrisSettingsActionsProvider.notifier);
    actions.updateSettings(settings);
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Restaurar Padrões',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja restaurar todas as configurações para os valores padrão?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final actions = ref.read(tetrisSettingsActionsProvider.notifier);
              actions.resetSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
