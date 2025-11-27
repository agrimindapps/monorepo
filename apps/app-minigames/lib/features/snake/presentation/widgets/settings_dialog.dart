// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/snake_settings.dart';
import '../../domain/entities/enums.dart';

/// Dialog for game settings
class SettingsDialog extends StatefulWidget {
  final SnakeSettings settings;
  final Function(SnakeSettings) onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SnakeSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(SnakeSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚙️ CONFIGURAÇÕES',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sound Toggle
                  _buildToggleRow(
                    icon: Icons.volume_up,
                    label: 'Som',
                    value: _settings.soundEnabled,
                    onChanged: (value) => _updateSettings(
                      _settings.copyWith(soundEnabled: value),
                    ),
                  ),

                  // Vibration Toggle
                  _buildToggleRow(
                    icon: Icons.vibration,
                    label: 'Vibração',
                    value: _settings.vibrationEnabled,
                    onChanged: (value) => _updateSettings(
                      _settings.copyWith(vibrationEnabled: value),
                    ),
                  ),

                  // Show Grid Toggle
                  _buildToggleRow(
                    icon: Icons.grid_on,
                    label: 'Mostrar Grade',
                    value: _settings.showGrid,
                    onChanged: (value) => _updateSettings(
                      _settings.copyWith(showGrid: value),
                    ),
                  ),

                  // Color Blind Mode Toggle
                  _buildToggleRow(
                    icon: Icons.visibility,
                    label: 'Modo Daltônico',
                    value: _settings.colorBlindMode,
                    onChanged: (value) => _updateSettings(
                      _settings.copyWith(colorBlindMode: value),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),

                  // Sensitivity Slider
                  _buildSliderRow(
                    icon: Icons.swipe,
                    label: 'Sensibilidade do Swipe',
                    value: _settings.swipeSensitivity,
                    min: SnakeSettings.minSensitivity,
                    max: SnakeSettings.maxSensitivity,
                    onChanged: (value) => _updateSettings(
                      _settings.copyWith(swipeSensitivity: value),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),

                  // Grid Size Dropdown
                  _buildDropdownRow<int>(
                    icon: Icons.grid_4x4,
                    label: 'Tamanho da Grade',
                    value: _settings.gridSize,
                    items: SnakeSettings.availableGridSizes
                        .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text('$size x $size'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSettings(_settings.copyWith(gridSize: value));
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Default Game Mode Dropdown
                  _buildDropdownRow<SnakeGameMode>(
                    icon: Icons.sports_esports,
                    label: 'Modo Padrão',
                    value: _settings.defaultGameMode,
                    items: SnakeGameMode.values
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Row(
                                children: [
                                  Text(mode.emoji),
                                  const SizedBox(width: 8),
                                  Text(mode.label),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSettings(_settings.copyWith(defaultGameMode: value));
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Default Difficulty Dropdown
                  _buildDropdownRow<SnakeDifficulty>(
                    icon: Icons.speed,
                    label: 'Dificuldade Padrão',
                    value: _settings.defaultDifficulty,
                    items: SnakeDifficulty.values
                        .map((diff) => DropdownMenuItem(
                              value: diff,
                              child: Text(diff.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSettings(_settings.copyWith(defaultDifficulty: value));
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Reset Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _updateSettings(SnakeSettings.defaults.copyWith(
                        tutorialShown: _settings.tutorialShown,
                      ));
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('RESTAURAR PADRÕES'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.blueAccent.withValues(alpha: 0.5),
            thumbColor: WidgetStatePropertyAll(
              value ? Colors.blueAccent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 15,
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 1,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
