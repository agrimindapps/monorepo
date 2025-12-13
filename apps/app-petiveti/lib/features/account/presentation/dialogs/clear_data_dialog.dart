import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

/// Dialog para confirmar limpeza de dados locais
class ClearDataDialog extends ConsumerStatefulWidget {
  const ClearDataDialog({super.key});

  @override
  ConsumerState<ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends ConsumerState<ClearDataDialog> {
  bool _isClearing = false;
  final Set<String> _selectedTypes = {
    'animals',
    'appointments',
    'medications',
    'vaccines',
    'weight',
    'reminders',
  };

  final Map<String, String> _dataTypes = {
    'animals': 'Animais',
    'appointments': 'Consultas',
    'medications': 'Medicamentos',
    'vaccines': 'Vacinas',
    'weight': 'Registros de Peso',
    'reminders': 'Lembretes',
    'expenses': 'Despesas',
  };

  Future<void> _clearData() async {
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um tipo de dado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isClearing = true);

    try {
      // Simular limpeza (aqui você implementaria a lógica real)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedTypes.length} tipo(s) de dados limpo(s) com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isClearing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delete_sweep, color: Colors.red.shade700),
          const SizedBox(width: 12),
          const Expanded(child: Text('Limpar Dados Locais')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dados sincronizados na nuvem não serão afetados',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione os dados a serem limpos:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._dataTypes.entries.map((entry) {
              return CheckboxListTile(
                value: _selectedTypes.contains(entry.key),
                onChanged: _isClearing
                    ? null
                    : (value) {
                        setState(() {
                          if (value == true) {
                            _selectedTypes.add(entry.key);
                          } else {
                            _selectedTypes.remove(entry.key);
                          }
                        });
                      },
                title: Text(entry.value),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isClearing ? null : _clearData,
          icon: _isClearing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.delete_sweep),
          label: Text(_isClearing ? 'Limpando...' : 'Limpar Dados'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
