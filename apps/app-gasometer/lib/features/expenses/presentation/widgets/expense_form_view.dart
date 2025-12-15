import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../../core/widgets/money_form_field.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/widgets/readonly_field.dart';
import '../../../../core/widgets/receipt_section.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../notifiers/expense_form_notifier.dart';
import '../notifiers/expense_form_state.dart';
import 'expense_type_selector.dart';

/// Widget principal do formulário de despesas
class ExpenseFormView extends ConsumerWidget {
  const ExpenseFormView({
    super.key, 
    required this.focusNodes,
    this.isReadOnly = false,
  });
  final Map<String, FocusNode> focusNodes;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseFormProvider);
    final notifier = ref.read(expenseFormProvider.notifier);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(
            title: 'Informações da Despesa',
            icon: Icons.shopping_cart,
            child: Column(
              children: [
                if (isReadOnly)
                  ReadOnlyField(
                    label: 'Tipo de Despesa',
                    value: state.expenseType.displayName,
                    icon: Icons.category,
                  )
                else
                  ExpenseTypeSelector(
                    selectedType: state.expenseType,
                    onTypeSelected: notifier.updateExpenseType,
                    error: state.getFieldError('expenseType'),
                  ),

                const SizedBox(height: GasometerDesignTokens.spacingMd),
                if (isReadOnly)
                  ReadOnlyField(
                    label: 'Descrição da Despesa',
                    value: state.description.isEmpty ? 'Sem descrição' : state.description,
                    icon: Icons.description,
                  )
                else
                  DescriptionField(
                    controller: notifier.descriptionController,
                    focusNode: focusNodes['description'],
                    label: 'Descrição da Despesa',
                    hint: ExpenseConstants.descriptionPlaceholder,
                    required: true,
                    onChanged: (value) {},
                  ),

                const SizedBox(height: GasometerDesignTokens.spacingMd),
                if (isReadOnly)
                  ReadOnlyField(
                    label: 'Data e Hora',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(state.date ?? DateTime.now()),
                    icon: Icons.calendar_today,
                  )
                else
                  DateTimeField(
                    value: state.date ?? DateTime.now(),
                    onChanged: (newDate) => notifier.updateDate(newDate),
                    label: 'Data e Hora',
                  ),
              ],
            ),
          ),

          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          FormSectionHeader(
            title: 'Informações Financeiras e Técnicas',
            icon: Icons.monetization_on,
            child: Column(
              children: [
                if (isReadOnly)
                  ReadOnlyField(
                    label: 'Valor Total',
                    value: 'R\$ ${state.amount.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                  )
                else
                  AmountFormField(
                    controller: notifier.amountController,
                    focusNode: focusNodes['amount'],
                    label: 'Valor Total',
                    required: true,
                    onChanged: (value) {},
                  ),
                const SizedBox(height: GasometerDesignTokens.spacingMd),
                if (isReadOnly)
                  ReadOnlyField(
                    label: 'Quilometragem Atual',
                    value: state.odometer > 0 
                        ? '${NumberFormat('#,##0.00', 'pt_BR').format(state.odometer)} km'
                        : 'Não informado',
                    icon: Icons.speed,
                  )
                else
                  OdometerField(
                    controller: notifier.odometerController,
                    focusNode: focusNodes['odometer'],
                    label: 'Quilometragem Atual',
                    hint: ExpenseConstants.odometerPlaceholder,
                    currentOdometer: state.vehicle?.currentOdometer,
                    onChanged: (value) {},
                  ),
              ],
            ),
          ),

          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          // FormSectionHeader(
          //   title: 'Detalhes Adicionais',
          //   icon: Icons.location_on,
          //   child: Column(
          //     children: [
          //       LocationField(
          //         controller: notifier.locationController,
          //         focusNode: focusNodes['location'],
          //         label: 'Local da Despesa',
          //         hint: ExpenseConstants.locationPlaceholder,
          //         required: false,
          //         onChanged: (value) {},
          //       ),
          //
          //       const SizedBox(height: GasometerDesignTokens.spacingMd),
          //       ObservationsField(
          //         controller: notifier.notesController,
          //         focusNode: focusNodes['notes'],
          //         label: 'Observações Adicionais',
          //         hint: ExpenseConstants.notesPlaceholder,
          //         required: false,
          //         onChanged: (value) {},
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          OptionalReceiptSection(
            imagePath: state.receiptImagePath,
            hasImage: state.hasReceiptImage,
            isUploading: state.isUploadingImage,
            uploadError: state.imageUploadError,
            onCameraSelected: () => notifier.captureReceiptImage(),
            onGallerySelected: () => notifier.selectReceiptImageFromGallery(),
            onImageRemoved: () => notifier.removeReceiptImage(),
            title: 'Comprovante da Despesa',
            description: 'Anexe uma foto do comprovante da despesa (opcional)',
          ),

          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          if (state.hasMinimumData) _buildFormSummary(context, state),
        ],
      ),
    );
  }

  Widget _buildFormSummary(BuildContext context, ExpenseFormState state) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: GasometerDesignTokens.paddingAll(
          GasometerDesignTokens.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: Colors.grey.shade600,
                  size: GasometerDesignTokens.iconSizeSm,
                ),
                const SizedBox(width: GasometerDesignTokens.spacingSm),
                Text(
                  'Resumo',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GasometerDesignTokens.spacingMd),

            _buildSummaryRow(context, 'Tipo:', state.expenseType.displayName),
            _buildSummaryRow(
              context,
              'Valor:',
              'R\$ ${state.amount.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              context,
              'Data:',
              _formatDate(state.date ?? DateTime.now()),
            ),
            _buildSummaryRow(
              context,
              'Odômetro:',
              '${state.odometer.toStringAsFixed(0)} km',
            ),

            if (state.location.isNotEmpty)
              _buildSummaryRow(context, 'Local:', state.location),

            if (state.hasReceiptImage) ...[
              const SizedBox(height: GasometerDesignTokens.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: GasometerDesignTokens.iconSizeXs,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: GasometerDesignTokens.spacingXs),
                  Text(
                    'Comprovante anexado',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeBody,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: GasometerDesignTokens.spacingMd),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GasometerDesignTokens.spacingSm,
                    vertical: GasometerDesignTokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: state.canSubmit
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.canSubmit ? Icons.check_circle : Icons.warning,
                        size: 14,
                        color: state.canSubmit ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: GasometerDesignTokens.spacingXs),
                      Text(
                        state.canSubmit ? 'Pronto' : 'Pendente',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: state.canSubmit ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: GasometerDesignTokens.spacingSm),
                if (state.isHighValue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GasometerDesignTokens.spacingSm,
                      vertical: GasometerDesignTokens.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: GasometerDesignTokens.spacingXs),
                        Text(
                          'Alto valor',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                if (state.expenseType == ExpenseType.maintenance ||
                    state.expenseType == ExpenseType.insurance) ...[
                  const SizedBox(width: GasometerDesignTokens.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GasometerDesignTokens.spacingSm,
                      vertical: GasometerDesignTokens.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 14,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: GasometerDesignTokens.spacingXs),
                        Text(
                          'Recorrente',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.purple),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: GasometerDesignTokens.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeCaption,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeBody,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
