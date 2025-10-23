import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../constants/settings_design_tokens.dart';
import '../domain/entities/tts_settings_entity.dart';
import '../presentation/providers/tts_notifier.dart';
import '../widgets/shared/settings_card.dart';
import '../widgets/shared/settings_list_tile.dart';

/// Dedicated page for TTS (Text-to-Speech) settings
/// Allows users to configure all voice reading parameters
class TtsSettingsPage extends ConsumerWidget {
  const TtsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsSettingsAsync = ref.watch(ttsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Leitura de Voz (TTS)'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ttsSettingsAsync.when(
          data: (settings) => _buildSettingsContent(context, ref, settings),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar configurações de TTS',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    TTSSettingsEntity settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Enable/Disable Section
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.volume_up,
                title: 'Habilitar Leitura de Voz',
                subtitle: settings.enabled
                    ? 'Leitura de texto habilitada'
                    : 'Leitura de texto desabilitada',
                trailing: Switch.adaptive(
                  value: settings.enabled,
                  onChanged: (_) =>
                      ref.read(ttsNotifierProvider.notifier).toggleEnabled(),
                ),
              ),
            ],
          ),
        ),

        if (settings.enabled) ...[
          const SizedBox(height: 16),

          // Voice Parameters Section
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Parâmetros de Voz',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),

                // Speech Rate
                _buildSliderTile(
                  context: context,
                  icon: Icons.speed,
                  title: 'Velocidade',
                  subtitle: _getRateLabel(settings.rate),
                  value: settings.rate,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) =>
                      ref.read(ttsNotifierProvider.notifier).updateRate(value),
                ),

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),

                // Pitch
                _buildSliderTile(
                  context: context,
                  icon: Icons.graphic_eq,
                  title: 'Tom de Voz',
                  subtitle: _getPitchLabel(settings.pitch),
                  value: settings.pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) =>
                      ref.read(ttsNotifierProvider.notifier).updatePitch(value),
                ),

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),

                // Volume
                _buildSliderTile(
                  context: context,
                  icon: Icons.volume_down,
                  title: 'Volume',
                  subtitle: '${(settings.volume * 100).round()}%',
                  value: settings.volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) => ref
                      .read(ttsNotifierProvider.notifier)
                      .updateVolume(value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test Voice Section
          SettingsCard(
            child: SettingsListTile(
              leadingIcon: Icons.play_circle_outline,
              title: 'Testar Voz',
              subtitle: 'Ouvir um exemplo de leitura',
              onTap: () => _testVoice(context, ref),
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(SettingsDesignTokens.cardBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use os botões de TTS nas páginas de pragas e defensivos para ouvir o conteúdo',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider.adaptive(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  String _getRateLabel(double rate) {
    if (rate < 0.7) return 'Muito lenta (${rate.toStringAsFixed(1)}x)';
    if (rate < 0.9) return 'Lenta (${rate.toStringAsFixed(1)}x)';
    if (rate < 1.1) return 'Normal (${rate.toStringAsFixed(1)}x)';
    if (rate < 1.5) return 'Rápida (${rate.toStringAsFixed(1)}x)';
    return 'Muito rápida (${rate.toStringAsFixed(1)}x)';
  }

  String _getPitchLabel(double pitch) {
    if (pitch < 0.8) return 'Muito grave (${pitch.toStringAsFixed(1)})';
    if (pitch < 0.95) return 'Grave (${pitch.toStringAsFixed(1)})';
    if (pitch < 1.05) return 'Normal (${pitch.toStringAsFixed(1)})';
    if (pitch < 1.2) return 'Agudo (${pitch.toStringAsFixed(1)})';
    return 'Muito agudo (${pitch.toStringAsFixed(1)})';
  }

  Future<void> _testVoice(BuildContext context, WidgetRef ref) async {
    const testText = 'Olá, esta é a voz do ReceitaAgro. '
        'Use este recurso para ouvir informações sobre pragas e defensivos agrícolas.';

    try {
      await ref.read(ttsNotifierProvider.notifier).speak(testText);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reproduzindo teste de voz...'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
            'Erro ao reproduzir teste de voz',
          ),
        );
      }
    }
  }
}
