// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'statistics_page.dart';

/// Página de configurações do jogo Snake
class SettingsPage extends StatefulWidget {
  final SnakeGameLogic gameLogic;

  const SettingsPage({
    super.key,
    required this.gameLogic,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late GameDifficulty _selectedDifficulty;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _swipeEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.gameLogic.difficulty;
    // TODO: Carregar outras configurações do persistence service
  }

  Future<void> _saveSettings() async {
    // Atualiza dificuldade no game logic (que já salva automaticamente)
    widget.gameLogic.updateDifficulty(_selectedDifficulty);

    // TODO: Salvar outras configurações

    // Mostra confirmação
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Salvar Configurações',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Configurações',
              subtitle: 'Personalize sua experiência de jogo',
              icon: Icons.settings,
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveSettings,
                  tooltip: 'Salvar Configurações',
                ),
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildGameplaySection(),
                const SizedBox(height: 24),
                _buildControlsSection(),
                const SizedBox(height: 24),
                _buildAudioSection(),
                const SizedBox(height: 24),
                _buildActionsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplaySection() {
    return _buildSection(
      title: 'Gameplay',
      icon: Icons.gamepad,
      children: [
        _buildDifficultySelector(),
      ],
    );
  }

  Widget _buildControlsSection() {
    return _buildSection(
      title: 'Controles',
      icon: Icons.touch_app,
      children: [
        _buildSwitchTile(
          title: 'Gestos de Swipe',
          subtitle: 'Permite controlar a cobra deslizando na tela',
          value: _swipeEnabled,
          onChanged: (value) {
            setState(() {
              _swipeEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return _buildSection(
      title: 'Áudio e Vibração',
      icon: Icons.volume_up,
      children: [
        _buildSwitchTile(
          title: 'Sons',
          subtitle: 'Reproduzir efeitos sonoros do jogo',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Vibração',
          subtitle: 'Vibrar o dispositivo em eventos do jogo',
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

  Widget _buildActionsSection() {
    return _buildSection(
      title: 'Ações',
      icon: Icons.settings_backup_restore,
      children: [
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Ver Estatísticas'),
          subtitle: const Text('Visualizar seu progresso e estatísticas'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StatisticsPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Resetar Dados',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          subtitle: const Text('Apagar todas as estatísticas e configurações'),
          onTap: _showResetDialog,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dificuldade Padrão',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha a dificuldade que será usada por padrão em novos jogos',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        ...GameDifficulty.values.map((difficulty) {
          return RadioListTile<GameDifficulty>(
            title: Text(difficulty.label),
            subtitle: Text(_getDifficultyDescription(difficulty)),
            value: difficulty,
            groupValue: _selectedDifficulty,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDifficulty = value;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  String _getDifficultyDescription(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Velocidade lenta - ideal para iniciantes';
      case GameDifficulty.medium:
        return 'Velocidade média - balanceado';
      case GameDifficulty.hard:
        return 'Velocidade alta - para jogadores experientes';
    }
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Todos os Dados'),
        content: const Text(
          'Esta ação irá apagar todas as suas estatísticas, recordes e '
          'configurações. Esta ação não pode ser desfeita.\n\n'
          'Deseja realmente continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _resetAllData();
    }
  }

  Future<void> _resetAllData() async {
    try {
      // TODO: Implementar reset de dados no persistence service
      // await widget.gameLogic._persistenceService.clearAllData();

      // Reinicia configurações para padrões
      setState(() {
        _selectedDifficulty = GameDifficulty.medium;
        _soundEnabled = true;
        _vibrationEnabled = true;
        _swipeEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os dados foram resetados!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao resetar dados: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
