import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/reversi_settings.dart';
import '../providers/reversi_data_providers.dart';

class ReversiSettingsPage extends ConsumerWidget {
  const ReversiSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(reversiSettingsProvider);

    return GamePageLayout(
      title: 'Configurações - Reversi',
      accentColor: const Color(0xFF2E7D32),
      maxGameWidth: 600,
      child: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Áudio'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: SwitchListTile(
                  title: const Text('Sons', style: TextStyle(color: Colors.white)),
                  value: settings.soundEnabled,
                  onChanged: (value) => _updateSettings(ref, settings.copyWith(soundEnabled: value)),
                  activeColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Visualização'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Mostrar Jogadas Válidas', style: TextStyle(color: Colors.white)),
                      value: settings.showValidMoves,
                      onChanged: (value) => _updateSettings(ref, settings.copyWith(showValidMoves: value)),
                      activeColor: const Color(0xFF2E7D32),
                    ),
                    SwitchListTile(
                      title: const Text('Mostrar Contador de Jogadas', style: TextStyle(color: Colors.white)),
                      value: settings.showMoveCount,
                      onChanged: (value) => _updateSettings(ref, settings.copyWith(showMoveCount: value)),
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Dificuldade'),
              Card(
                color: Colors.black.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: ReversiDifficulty.values.map((difficulty) {
                      return RadioListTile<ReversiDifficulty>(
                        title: Text(difficulty.label, style: const TextStyle(color: Colors.white)),
                        value: difficulty,
                        groupValue: settings.difficulty,
                        onChanged: (value) {
                          if (value != null) _updateSettings(ref, settings.copyWith(difficulty: value));
                        },
                        activeColor: const Color(0xFF2E7D32),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
        error: (error, _) => Center(child: Text('Erro: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  void _updateSettings(WidgetRef ref, ReversiSettings settings) {
    final updater = ref.read(reversiSettingsUpdaterProvider.notifier);
    updater.updateSettings(settings);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text('Deseja restaurar todas as configurações para os valores padrão?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restaurar')),
        ],
      ),
    );

    if (confirmed == true) {
      final updater = ref.read(reversiSettingsUpdaterProvider.notifier);
      await updater.updateSettings(const ReversiSettings());
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
        style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
