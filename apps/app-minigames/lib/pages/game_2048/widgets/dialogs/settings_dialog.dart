// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/services/game_state_persistence_service.dart';

class SettingsDialog extends StatefulWidget {
  final TileColorScheme currentColorScheme;
  final BoardSize currentBoardSize;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final AutoSaveSettings autoSaveSettings;
  final Function(TileColorScheme) onColorSchemeChanged;
  final Function(BoardSize) onBoardSizeChanged;
  final Function(bool) onSoundChanged;
  final Function(bool) onVibrationChanged;
  final Function(AutoSaveSettings) onAutoSaveSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.currentColorScheme,
    required this.currentBoardSize,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.autoSaveSettings,
    required this.onColorSchemeChanged,
    required this.onBoardSizeChanged,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.onAutoSaveSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TileColorScheme _currentColorScheme;
  late BoardSize _currentBoardSize;
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late AutoSaveSettings _autoSaveSettings;

  @override
  void initState() {
    super.initState();
    _currentColorScheme = widget.currentColorScheme;
    _currentBoardSize = widget.currentBoardSize;
    _soundEnabled = widget.soundEnabled;
    _vibrationEnabled = widget.vibrationEnabled;
    _autoSaveSettings = widget.autoSaveSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configurações',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGameSettingsSection(),
                    const SizedBox(height: 24),
                    _buildAutoSaveSettingsSection(),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações do Jogo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Color Scheme
        _buildSettingTile(
          title: 'Esquema de Cores',
          subtitle: 'Alterar cores dos tiles',
          child: DropdownButton<TileColorScheme>(
            value: _currentColorScheme,
            underline: const SizedBox(),
            items: TileColorScheme.values.map((scheme) {
              return DropdownMenuItem(
                value: scheme,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: scheme.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(scheme.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newScheme) {
              if (newScheme != null) {
                setState(() {
                  _currentColorScheme = newScheme;
                });
              }
            },
          ),
        ),

        // Board Size
        _buildSettingTile(
          title: 'Tamanho do Tabuleiro',
          subtitle: 'Alterar dimensões do tabuleiro',
          child: DropdownButton<BoardSize>(
            value: _currentBoardSize,
            underline: const SizedBox(),
            items: BoardSize.values.map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text(size.label),
              );
            }).toList(),
            onChanged: (newSize) {
              if (newSize != null) {
                setState(() {
                  _currentBoardSize = newSize;
                });
              }
            },
          ),
        ),

        // Sound
        _buildSwitchTile(
          title: 'Som',
          subtitle: 'Ativar efeitos sonoros',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),

        // Vibration
        _buildSwitchTile(
          title: 'Vibração',
          subtitle: 'Ativar feedback háptico',
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAutoSaveSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações de Autosave',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // AutoSave Enabled
        _buildSwitchTile(
          title: 'Autosave Ativado',
          subtitle: 'Salvar automaticamente o progresso',
          value: _autoSaveSettings.autoSaveEnabled,
          onChanged: (value) {
            setState(() {
              _autoSaveSettings = _autoSaveSettings.copyWith(
                autoSaveEnabled: value,
              );
            });
          },
        ),

        if (_autoSaveSettings.autoSaveEnabled) ...[
          // AutoSave Interval
          _buildSettingTile(
            title: 'Intervalo de Autosave',
            subtitle: 'Frequência do salvamento automático',
            child: DropdownButton<int>(
              value: _autoSaveSettings.autoSaveInterval.inSeconds,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 segundos')),
                DropdownMenuItem(value: 30, child: Text('30 segundos')),
                DropdownMenuItem(value: 60, child: Text('1 minuto')),
                DropdownMenuItem(value: 120, child: Text('2 minutos')),
              ],
              onChanged: (seconds) {
                if (seconds != null) {
                  setState(() {
                    _autoSaveSettings = _autoSaveSettings.copyWith(
                      autoSaveInterval: Duration(seconds: seconds),
                    );
                  });
                }
              },
            ),
          ),

          // Save on App Pause
          _buildSwitchTile(
            title: 'Salvar ao Pausar App',
            subtitle: 'Salvar quando app vai para segundo plano',
            value: _autoSaveSettings.saveOnAppPause,
            onChanged: (value) {
              setState(() {
                _autoSaveSettings = _autoSaveSettings.copyWith(
                  saveOnAppPause: value,
                );
              });
            },
          ),

          // Save on Movement
          _buildSwitchTile(
            title: 'Salvar por Movimento',
            subtitle: 'Salvar a cada poucos movimentos',
            value: _autoSaveSettings.saveOnMovement,
            onChanged: (value) {
              setState(() {
                _autoSaveSettings = _autoSaveSettings.copyWith(
                  saveOnMovement: value,
                );
              });
            },
          ),

          if (_autoSaveSettings.saveOnMovement) ...[
            // Movement Save Frequency
            _buildSettingTile(
              title: 'Frequência por Movimento',
              subtitle: 'Número de movimentos entre saves',
              child: DropdownButton<int>(
                value: _autoSaveSettings.movementSaveFrequency,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('A cada 3 movimentos')),
                  DropdownMenuItem(value: 5, child: Text('A cada 5 movimentos')),
                  DropdownMenuItem(value: 10, child: Text('A cada 10 movimentos')),
                ],
                onChanged: (frequency) {
                  if (frequency != null) {
                    setState(() {
                      _autoSaveSettings = _autoSaveSettings.copyWith(
                        movementSaveFrequency: frequency,
                      );
                    });
                  }
                },
              ),
            ),
          ],

          // Show Restore Dialog
          _buildSwitchTile(
            title: 'Dialog de Restauração',
            subtitle: 'Perguntar ao abrir se deseja continuar jogo salvo',
            value: _autoSaveSettings.showRestoreDialog,
            onChanged: (value) {
              setState(() {
                _autoSaveSettings = _autoSaveSettings.copyWith(
                  showRestoreDialog: value,
                );
              });
            },
          ),

          // Auto Clean Old Saves
          _buildSwitchTile(
            title: 'Limpeza Automática',
            subtitle: 'Limpar saves antigos (7+ dias) automaticamente',
            value: _autoSaveSettings.autoCleanOldSaves,
            onChanged: (value) {
              setState(() {
                _autoSaveSettings = _autoSaveSettings.copyWith(
                  autoCleanOldSaves: value,
                );
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingTile(
      title: title,
      subtitle: subtitle,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _saveSettings() {
    // Apply all changes
    widget.onColorSchemeChanged(_currentColorScheme);
    widget.onBoardSizeChanged(_currentBoardSize);
    widget.onSoundChanged(_soundEnabled);
    widget.onVibrationChanged(_vibrationEnabled);
    widget.onAutoSaveSettingsChanged(_autoSaveSettings);

    Navigator.of(context).pop();
  }

  static Future<void> show({
    required BuildContext context,
    required TileColorScheme currentColorScheme,
    required BoardSize currentBoardSize,
    required bool soundEnabled,
    required bool vibrationEnabled,
    required AutoSaveSettings autoSaveSettings,
    required Function(TileColorScheme) onColorSchemeChanged,
    required Function(BoardSize) onBoardSizeChanged,
    required Function(bool) onSoundChanged,
    required Function(bool) onVibrationChanged,
    required Function(AutoSaveSettings) onAutoSaveSettingsChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        currentColorScheme: currentColorScheme,
        currentBoardSize: currentBoardSize,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        autoSaveSettings: autoSaveSettings,
        onColorSchemeChanged: onColorSchemeChanged,
        onBoardSizeChanged: onBoardSizeChanged,
        onSoundChanged: onSoundChanged,
        onVibrationChanged: onVibrationChanged,
        onAutoSaveSettingsChanged: onAutoSaveSettingsChanged,
      ),
    );
  }
}
