import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/tts_service.dart';
import '../themes/manager.dart';
import '../widgets/appbar.dart';

class TTsSettingsPage extends StatefulWidget {
  const TTsSettingsPage({super.key});

  @override
  State<TTsSettingsPage> createState() => _TtsSettingsPageState();
}

class _TtsSettingsPageState extends State<TTsSettingsPage> {
  final TtsService _ttsService = TtsService();
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  String _language = 'pt-BR';
  final String _testPhrase =
      'O que é Geografia? A Geografia é uma ciência que estuda o espaço geográfico, ou seja, a relação entre o homem e o meio ambiente.';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
      _language = prefs.getString('tts_language') ?? 'pt-BR';
    });
  }

  void _saveSettings() async {
    await _ttsService.saveSettings(_language, _speechRate, _volume, _pitch);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações salvas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Configurações de TTS'),
      // ),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1020,
              child: Column(
                children: [
                  const SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('O que é Geografia?',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text(
                              'A Geografia é uma ciência que estuda o espaço geográfico, ou seja, a relação entre o homem e o meio ambiente. ',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Configurações de Voz'),
                          const Divider(),
                          const Text('Taxa de Fala'),
                          Slider(
                            value: _speechRate,
                            min: 0.1,
                            max: 1.0,
                            divisions: 10,
                            label: _speechRate.toString(),
                            onChanged: (value) {
                              setState(() {
                                _speechRate = value;
                              });
                              _ttsService.setSpeechRate(value);
                            },
                          ),
                          const Text('Volume'),
                          Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: _volume.toString(),
                            onChanged: (value) {
                              setState(() {
                                _volume = value;
                              });
                              _ttsService.setVolume(value);
                            },
                          ),
                          const Text('Tom de Voz'),
                          Slider(
                            value: _pitch,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: _pitch.toString(),
                            onChanged: (value) {
                              setState(() {
                                _pitch = value;
                              });
                              _ttsService.setPitch(value);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _ttsService.speak(_testPhrase);
                                },
                                child: const Text('Testar Voz'),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: _saveSettings,
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
      ),
    );
  }
}

Widget configOptionTSSPage(BuildContext context) {
  return ListTile(
    title: const Text('Configurações de Voz'),
    subtitle: const Text('Configurações de velocidade e tonalidade de voz'),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: ThemeManager().isDark.value
          ? Colors.grey.shade300
          : Colors.grey.shade600,
    ),
    onTap: () {
      Navigator.of(context).pushNamed('/config/tts');
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
