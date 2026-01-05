import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page for configuring sync preferences
class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  static const String routeName = '/sync-settings';

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  static const String _autoSyncKey = 'sync_auto_enabled';
  static const String _wifiOnlyKey = 'sync_wifi_only';
  static const String _syncIntervalKey = 'sync_interval_minutes';

  bool _autoSyncEnabled = true;
  bool _wifiOnly = false;
  int _syncIntervalMinutes = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSyncEnabled = prefs.getBool(_autoSyncKey) ?? true;
      _wifiOnly = prefs.getBool(_wifiOnlyKey) ?? false;
      _syncIntervalMinutes = prefs.getInt(_syncIntervalKey) ?? 15;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncKey, _autoSyncEnabled);
    await prefs.setBool(_wifiOnlyKey, _wifiOnly);
    await prefs.setInt(_syncIntervalKey, _syncIntervalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Sincronização'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sincronização automática'),
                  subtitle: const Text(
                    'Sincronizar dados automaticamente em segundo plano',
                  ),
                  value: _autoSyncEnabled,
                  onChanged: (value) {
                    setState(() => _autoSyncEnabled = value);
                    _saveSettings();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Apenas WiFi'),
                  subtitle: const Text(
                    'Sincronizar apenas quando conectado ao WiFi',
                  ),
                  value: _wifiOnly,
                  onChanged: _autoSyncEnabled
                      ? (value) {
                          setState(() => _wifiOnly = value);
                          _saveSettings();
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intervalo de sincronização',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sincronizar a cada $_syncIntervalMinutes minutos',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: _syncIntervalMinutes.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '$_syncIntervalMinutes min',
                  onChanged: _autoSyncEnabled
                      ? (value) {
                          setState(() => _syncIntervalMinutes = value.toInt());
                        }
                      : null,
                  onChangeEnd: (value) {
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Informações',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• A sincronização automática mantém seus dados seguros na nuvem\n'
                    '• Você sempre pode forçar sincronização manual\n'
                    '• Intervalos menores consomem mais bateria',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
