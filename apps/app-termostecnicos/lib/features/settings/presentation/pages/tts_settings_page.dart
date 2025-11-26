import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

/// TTS Settings Page with Riverpod
class TTSSettingsPage extends ConsumerStatefulWidget {
  const TTSSettingsPage({super.key});

  @override
  ConsumerState<TTSSettingsPage> createState() => _TTSSettingsPageState();
}

class _TTSSettingsPageState extends ConsumerState<TTSSettingsPage> {
  final String _testPhrase =
      'O que é Geografia? A Geografia é uma ciência que estuda o espaço geográfico, ou seja, a relação entre o homem e o meio ambiente.';

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de TTS'),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar configurações: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(settings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Column(
              children: [
                // Test phrase card
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'O que é Geografia?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'A Geografia é uma ciência que estuda o espaço geográfico, ou seja, a relação entre o homem e o meio ambiente.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Settings card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Configurações de Voz'),
                        const Divider(),

                        // Speech rate slider
                        const Text('Taxa de Fala'),
                        Slider(
                          value: settings.ttsSpeed,
                          min: 0.1,
                          max: 1.0,
                          divisions: 10,
                          label: settings.ttsSpeed.toStringAsFixed(1),
                          onChanged: (value) async {
                            await ref.read(settingsProvider.notifier).updateTTSSettings(speed: value);
                          },
                        ),

                        // Volume slider
                        const Text('Volume'),
                        Slider(
                          value: settings.ttsVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: settings.ttsVolume.toStringAsFixed(1),
                          onChanged: (value) async {
                            await ref.read(settingsProvider.notifier).updateTTSSettings(volume: value);
                          },
                        ),

                        // Pitch slider
                        const Text('Tom de Voz'),
                        Slider(
                          value: settings.ttsPitch,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: settings.ttsPitch.toStringAsFixed(1),
                          onChanged: (value) async {
                            await ref.read(settingsProvider.notifier).updateTTSSettings(pitch: value);
                          },
                        ),

                        // Test button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Integrate with TTS service from core
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'TTS test functionality - integrate with core service'),
                                  ),
                                );
                              },
                              child: const Text('Testar Voz'),
                            ),
                          ],
                        ),

                        const Divider(),

                        // Save button (auto-saved, but kept for UX)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Configurações salvas automaticamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: const Text('Salvar Configurações'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget to add TTS settings option to config page
Widget configOptionTTSPage(BuildContext context, bool isDarkMode) {
  return ListTile(
    title: const Text('Configurações de Voz'),
    subtitle: const Text('Configurações de velocidade e tonalidade de voz'),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
    ),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TTSSettingsPage(),
        ),
      );
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
