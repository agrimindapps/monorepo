import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/design_tokens.dart';
import 'dialog_helpers.dart';
import 'upper_case_text_formatter.dart';

/// Dialog stateful para confirmação de limpeza de dados
class DataClearDialog extends ConsumerStatefulWidget {
  const DataClearDialog({super.key});

  @override
  ConsumerState<DataClearDialog> createState() => _DataClearDialogState();
}

class _DataClearDialogState extends ConsumerState<DataClearDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  bool _isLoading = false;
  static const _warningColor = GasometerDesignTokens.colorWarning;

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
    setState(() => _isConfirmationValid = _confirmationController.text.trim().toUpperCase() == 'LIMPAR');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      content: _buildContent(context, theme),
      actions: _buildActions(context, theme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: _warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.delete_sweep, size: 32, color: _warningColor),
        ),
        const SizedBox(height: 20),
        const Text('Limpar Dados do App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _warningColor), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        _buildInfoSection(context, theme),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Esta ação limpará todos os dados em todos seus dispositivos:', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 16),
        buildDialogInfoItem(context, Icons.directions_car, 'Todos os seus veículos', iconColor: _warningColor),
        buildDialogInfoItem(context, Icons.local_gas_station, 'Todos os abastecimentos', iconColor: _warningColor),
        buildDialogInfoItem(context, Icons.build, 'Todas as manutenções', iconColor: _warningColor),
        buildDialogInfoItem(context, Icons.attach_money, 'Todas as despesas registradas', iconColor: _warningColor),
        const SizedBox(height: 16),
        const Row(children: [
          Icon(Icons.warning, color: _warningColor, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Esta ação não pode ser desfeita', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _warningColor))),
        ]),
        const SizedBox(height: 20),
        Text('Para confirmar, digite LIMPAR abaixo:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmationController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Digite LIMPAR para confirmar',
            border: OutlineInputBorder(borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton)),
            focusedBorder: OutlineInputBorder(
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              borderSide: const BorderSide(color: _warningColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [UpperCaseTextFormatter()],
          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, ThemeData theme) {
    final isEnabled = _isConfirmationValid && !_isLoading;
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
      ),
      ElevatedButton(
        onPressed: isEnabled ? _handleClearData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? _warningColor : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: isEnabled ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton)),
        ),
        child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Limpar Dados'),
      ),
    ];
  }

  Future<void> _handleClearData() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement data clearing logic
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
