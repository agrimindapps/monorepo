import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/data_cleaner_providers.dart';
import '../../../../../core/theme/app_colors.dart';
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
  static const _warningColor = Colors.orange;

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
    setState(
      () => _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'LIMPAR',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
          decoration: BoxDecoration(
            color: _warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.delete_sweep, size: 32, color: _warningColor),
        ),
        const SizedBox(height: 20),
        const Text(
          'Limpar Dados do App',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _warningColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildInfoSection(context, theme),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esta ação limpará todos os dados em todos seus dispositivos:',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        buildDialogInfoItem(
          context,
          Icons.pets,
          'Todos os seus pets',
          iconColor: _warningColor,
        ),
        buildDialogInfoItem(
          context,
          Icons.vaccines,
          'Todas as vacinas registradas',
          iconColor: _warningColor,
        ),
        buildDialogInfoItem(
          context,
          Icons.medication,
          'Todos os medicamentos',
          iconColor: _warningColor,
        ),
        buildDialogInfoItem(
          context,
          Icons.calendar_today,
          'Todas as consultas e agendamentos',
          iconColor: _warningColor,
        ),
        buildDialogInfoItem(
          context,
          Icons.monitor_weight,
          'Todos os registros de peso',
          iconColor: _warningColor,
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.warning, color: _warningColor, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Esta ação não pode ser desfeita',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _warningColor,
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
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmationController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Digite LIMPAR para confirmar',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _warningColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: isEnabled ? _handleClearData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? _warningColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: isEnabled
              ? Colors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Text('Limpar Dados'),
      ),
    ];
  }

  Future<void> _handleClearData() async {
    setState(() => _isLoading = true);
    try {
      final dataCleaner = ref.read(petivetiDataCleanerProvider);
      final result = await dataCleaner.clearAllAppData();
      
      if (mounted) {
        Navigator.of(context).pop();
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dados limpos com sucesso! ${result['totalRecordsCleared']} registros removidos.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          final errors = result['errors'] as List<dynamic>? ?? [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Alguns erros ocorreram: ${errors.take(2).join(', ')}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
