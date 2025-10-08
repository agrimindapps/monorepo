import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/design_tokens.dart';

/// Dialog para confirmação de limpeza de dados
class DataClearDialog extends StatefulWidget {
  const DataClearDialog({super.key});

  @override
  State<DataClearDialog> createState() => _DataClearDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DataClearDialog(),
    );
  }
}

class _DataClearDialogState extends State<DataClearDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'LIMPAR';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: GasometerDesignTokens.colorWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.delete_sweep,
              size: 32,
              color: GasometerDesignTokens.colorWarning,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Limpar Dados do App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GasometerDesignTokens.colorWarning,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação limpará todos os dados em todos seus dispositivos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildClearItem(
                context,
                Icons.directions_car,
                'Todos os seus veículos',
              ),
              _buildClearItem(
                context,
                Icons.local_gas_station,
                'Todos os abastecimentos',
              ),
              _buildClearItem(context, Icons.build, 'Todas as manutenções'),
              _buildClearItem(
                context,
                Icons.attach_money,
                'Todas as despesas registradas',
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: GasometerDesignTokens.colorWarning,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GasometerDesignTokens.colorWarning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Para confirmar, digite LIMPAR abaixo:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Digite LIMPAR para confirmar',
                  border: OutlineInputBorder(
                    borderRadius: GasometerDesignTokens.borderRadius(
                      GasometerDesignTokens.radiusButton,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: GasometerDesignTokens.borderRadius(
                      GasometerDesignTokens.radiusButton,
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [_UpperCaseTextFormatter()],
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid && !_isLoading
                  ? () => _performDataClear()
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid && !_isLoading
                    ? GasometerDesignTokens.colorWarning
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid && !_isLoading
                    ? Colors.white
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Limpar Dados'),
        ),
      ],
    );
  }

  Widget _buildClearItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: GasometerDesignTokens.colorWarning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDataClear() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementar limpeza de dados através do service
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulação

      if (context.mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados limpos com sucesso'),
            backgroundColor: GasometerDesignTokens.colorSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar dados: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Formatter que converte automaticamente o texto para uppercase
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
