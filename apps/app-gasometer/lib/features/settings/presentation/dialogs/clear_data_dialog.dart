import 'package:flutter/material.dart';

import '../../../../core/services/data_cleaner_service.dart';

/// 🏗️ REFACTORED COMPONENT: Extracted from SettingsPage monolith
/// 
/// Handles data clearing functionality with proper state management
/// and memory leak prevention.
class ClearDataDialog extends StatefulWidget {
  const ClearDataDialog({super.key});

  @override
  State<ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends State<ClearDataDialog> {
  final _dataCleaner = DataCleanerService.instance;
  
  bool _isLoading = true;
  bool _isClearing = false;
  Map<String, dynamic>? _currentStats;
  String _selectedClearType = 'all'; // 'all', 'selective'
  final Set<String> _selectedModules = {};
  Map<String, dynamic>? _lastClearResult;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  Future<void> _loadCurrentStats() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _dataCleaner.getDataStatsBeforeCleaning();
      setState(() {
        _currentStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Erro ao carregar estatísticas: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cleaning_services, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Limpar Dados'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação irá remover dados armazenados localmente. Use com cautela.',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_currentStats != null)
                _CurrentStatsCard(stats: _currentStats!),
              
              const SizedBox(height: 16),
              _ClearTypeSelector(
                selectedType: _selectedClearType,
                onChanged: (type) => setState(() => _selectedClearType = type),
              ),
              if (_selectedClearType == 'selective')
                _ModuleSelector(
                  selectedModules: _selectedModules,
                  onModuleToggle: _toggleModule,
                ),
              
              const SizedBox(height: 16),
              if (_lastClearResult != null)
                _ClearResults(results: _lastClearResult!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _isClearing || _isLoading || !_canClear() ? null : _performClear,
          child: _isClearing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Limpar Dados'),
        ),
      ],
    );
  }

  void _toggleModule(String module) {
    setState(() {
      if (_selectedModules.contains(module)) {
        _selectedModules.remove(module);
      } else {
        _selectedModules.add(module);
      }
    });
  }

  bool _canClear() {
    if (_selectedClearType == 'all') return true;
    return _selectedModules.isNotEmpty;
  }

  Future<void> _performClear() async {
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isClearing = true);
    
    try {
      Map<String, dynamic> result;
      
      if (_selectedClearType == 'all') {
        result = await _dataCleaner.clearAllData();
        if (mounted) {
          _showSnackBar(
            'Limpeza completa concluída! '
            '${result['totalClearedBoxes']} boxes e '
            '${result['totalClearedPreferences']} preferências removidas.',
          );
        }
      } else {
        result = {
          'totalClearedBoxes': 0,
          'totalClearedPreferences': 0,
          'errors': <String>[],
          'duration': 0,
        };
        
        final startTime = DateTime.now();
        
        for (final module in _selectedModules) {
          final moduleResult = await _dataCleaner.clearModuleData(module);
          result['totalClearedBoxes'] += (moduleResult['clearedBoxes'] as List).length;
          if (moduleResult['errors'] != null) {
            (result['errors'] as List).addAll(moduleResult['errors'] as Iterable? ?? []);
          }
        }
        
        result['duration'] = DateTime.now().difference(startTime).inMilliseconds;
        if (mounted) {
          _showSnackBar(
            'Limpeza seletiva concluída! '
            '${result['totalClearedBoxes']} boxes removidos de ${_selectedModules.length} módulos.',
          );
        }
      }
      if (mounted) {
        setState(() {
          _lastClearResult = result;
          _isClearing = false;
          _selectedModules.clear();
        });
      }
      await _loadCurrentStats();
      
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        _showSnackBar('Erro durante a limpeza: $e', isError: true);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: Text(
          _selectedClearType == 'all'
            ? 'Tem certeza que deseja remover TODOS os dados? Esta ação é irreversível.'
            : 'Tem certeza que deseja limpar os módulos selecionados: ${_selectedModules.join(", ")}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// 🎯 Component to display current data statistics
class _CurrentStatsCard extends StatelessWidget {

  const _CurrentStatsCard({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Dados atuais:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Boxes: ${stats['totalBoxes'] ?? 0}'),
          Text('Registros: ${stats['totalRecords'] ?? 0}'),
          Text('Preferências: ${stats['totalPreferences'] ?? 0}'),
        ],
      ),
    );
  }
}

/// 🎯 Component for clear type selection
class _ClearTypeSelector extends StatelessWidget {

  const _ClearTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });
  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de limpeza:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Limpeza completa'),
          subtitle: const Text('Remove todos os dados locais'),
          value: 'all',
          groupValue: selectedType,
          onChanged: (value) => onChanged(value!),
        ),
        RadioListTile<String>(
          title: const Text('Limpeza seletiva'),
          subtitle: const Text('Escolha módulos específicos'),
          value: 'selective',
          groupValue: selectedType,
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }
}

/// 🎯 Component for module selection
class _ModuleSelector extends StatelessWidget {

  const _ModuleSelector({
    required this.selectedModules,
    required this.onModuleToggle,
  });
  final Set<String> selectedModules;
  final ValueChanged<String> onModuleToggle;

  static const List<String> _availableModules = [
    'vehicles',
    'fuel',
    'expenses',
    'maintenance',
    'settings',
    'user_preferences',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Módulos:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ..._availableModules.map((module) => CheckboxListTile(
          title: Text(module),
          value: selectedModules.contains(module),
          onChanged: (_) => onModuleToggle(module),
        )),
      ],
    );
  }
}

/// 🎯 Component to display clear results
class _ClearResults extends StatelessWidget {

  const _ClearResults({required this.results});
  final Map<String, dynamic> results;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Última limpeza:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Boxes removidos: ${results['totalClearedBoxes'] ?? 0}'),
          Text('Preferências removidas: ${results['totalClearedPreferences'] ?? 0}'),
          if (results['duration'] != null)
            Text('Tempo: ${results['duration']}ms'),
          if (results['errors'] != null && (results['errors'] as List).isNotEmpty)
            Text('Erros: ${(results['errors'] as List).length}', 
                 style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}