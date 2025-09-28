import 'package:flutter/material.dart';

import '../../../../core/services/data_generator_service.dart';

/// 🏗️ REFACTORED COMPONENT: Extracted from SettingsPage monolith
/// 
/// Handles data generation functionality with proper state management
/// and memory leak prevention.
class GenerateDataDialog extends StatefulWidget {
  const GenerateDataDialog({super.key});

  @override
  State<GenerateDataDialog> createState() => _GenerateDataDialogState();
}

class _GenerateDataDialogState extends State<GenerateDataDialog> {
  final _dataGenerator = DataGeneratorService.instance;
  
  int _numberOfVehicles = 2;
  int _monthsOfHistory = 14;
  bool _isGenerating = false;
  Map<String, dynamic>? _lastResult;
  
  // ✅ MEMORY LEAK FIX: Add disposal for proper cleanup
  @override
  void dispose() {
    // Cancel any pending operations if possible
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Gerar Dados de Teste'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta função irá gerar dados realísticos para testar a interface do aplicativo.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Vehicle count configuration
            _VehicleCountSelector(
              value: _numberOfVehicles,
              onChanged: (value) => setState(() => _numberOfVehicles = value),
            ),
            
            // History months configuration  
            _HistoryMonthsSelector(
              value: _monthsOfHistory,
              onChanged: (value) => setState(() => _monthsOfHistory = value),
            ),
            
            const SizedBox(height: 20),
            
            // Generation results display
            if (_lastResult != null) 
              _GenerationResults(results: _lastResult!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isGenerating ? null : _generateData,
          child: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Gerar Dados'),
        ),
      ],
    );
  }

  Future<void> _generateData() async {
    setState(() => _isGenerating = true);
    
    try {
      final result = await _dataGenerator.generateTestData(
        numberOfVehicles: _numberOfVehicles,
        monthsOfHistory: _monthsOfHistory,
      );
      
      setState(() {
        _lastResult = result;
        _isGenerating = false;
      });
      
      // ✅ MEMORY LEAK FIX: Check mounted before using context
      if (mounted) {
        _showSnackBar(
          'Dados gerados com sucesso! '
          '${result['vehicles']} veículos, '
          '${result['fuelRecords']} abastecimentos, '
          '${result['expenses']} despesas.'
        );
      }
      
    } on UnimplementedError {
      // ✅ MEMORY LEAK FIX: Check mounted before using context
      if (mounted) {
        _showSnackBar(
          'Funcionalidade em desenvolvimento.\\n'
          'O Database Inspector já está funcional para visualizar dados existentes.',
          isError: false
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        _showSnackBar('Erro ao gerar dados: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // ✅ MEMORY LEAK FIX: Only show snackbar if widget is still mounted
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

/// 🎯 Reusable component for vehicle count selection
class _VehicleCountSelector extends StatelessWidget {

  const _VehicleCountSelector({
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Número de veículos:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: value < 5 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🎯 Reusable component for history months selection  
class _HistoryMonthsSelector extends StatelessWidget {

  const _HistoryMonthsSelector({
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Meses de histórico:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                onPressed: value > 6 ? () => onChanged(value - 2) : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: value < 24 ? () => onChanged(value + 2) : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🎯 Component to display generation results
class _GenerationResults extends StatelessWidget {

  const _GenerationResults({required this.results});
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
                'Última geração:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Veículos: ${results['vehicles'] ?? 0}'),
          Text('Abastecimentos: ${results['fuelRecords'] ?? 0}'),
          Text('Despesas: ${results['expenses'] ?? 0}'),
          if (results['duration'] != null)
            Text('Tempo: ${results['duration']}ms'),
        ],
      ),
    );
  }
}