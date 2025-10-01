import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../../core/widgets/money_form_field.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/widgets/receipt_section.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../core/constants/expense_constants.dart';
import '../providers/expense_form_provider.dart';
import 'expense_type_selector.dart';

/// Widget principal do formulário de despesas
class ExpenseFormView extends StatelessWidget {

  const ExpenseFormView({super.key, required this.formProvider});
  final ExpenseFormProvider formProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseFormProvider>(
      builder: (context, provider, child) {
        return Form(
          key: provider.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1ª Seção: Informações da Despesa (O QUE foi gasto e QUANDO)
              FormSectionHeader(
                title: 'Informações da Despesa',
                icon: Icons.shopping_cart,
                child: Column(
                  children: [
                    // Seletor de tipo de despesa
                    ExpenseTypeSelector(
                      selectedType: provider.formModel.expenseType,
                      onTypeSelected: provider.updateExpenseType,
                      error: provider.formModel.getFieldError('expenseType'),
                    ),

                    const SizedBox(height: GasometerDesignTokens.spacingMd),

                    // Descrição com validação em tempo real
                    DescriptionField(
                      controller: provider.descriptionController,
                      label: 'Descrição da Despesa',
                      hint: ExpenseConstants.descriptionPlaceholder,
                      required: true,
                      onChanged: (value) {
                        // O provider já está conectado ao controller
                      },
                    ),

                    const SizedBox(height: GasometerDesignTokens.spacingMd),

                    // Data e Hora unified
                    DateTimeField(
                      value: provider.formModel.date,
                      onChanged: (newDate) => provider.updateDate(newDate),
                      label: 'Data e Hora',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // 2ª Seção: Informações Financeiras e Técnicas (QUANTO custou e quilometragem)
              FormSectionHeader(
                title: 'Informações Financeiras e Técnicas',
                icon: Icons.monetization_on,
                child: Column(
                  children: [
                    FormFieldRow.standard(
                      children: [
                        // Valor com validação monetária
                        AmountFormField(
                          controller: provider.amountController,
                          label: 'Valor Total',
                          required: true,
                          onChanged: (value) {
                            // O provider já está conectado ao controller
                          },
                        ),
                        // Odômetro
                        OdometerField(
                          controller: provider.odometerController,
                          label: 'Quilometragem Atual',
                          hint: ExpenseConstants.odometerPlaceholder,
                          currentOdometer: provider.formModel.vehicle?.currentOdometer,
                          onChanged: (value) {
                            // Provider já está conectado ao controller
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // 3ª Seção: Detalhes Adicionais (ONDE foi realizada)
              FormSectionHeader(
                title: 'Detalhes Adicionais',
                icon: Icons.location_on,
                child: Column(
                  children: [
                    // Localização (opcional)
                    LocationField(
                      controller: provider.locationController,
                      label: 'Local da Despesa',
                      hint: ExpenseConstants.locationPlaceholder,
                      required: false,
                      onChanged: (value) {
                        // O provider já está conectado ao controller
                      },
                    ),

                    const SizedBox(height: GasometerDesignTokens.spacingMd),

                    // Observações
                    ObservationsField(
                      controller: provider.notesController,
                      label: 'Observações Adicionais',
                      hint: ExpenseConstants.notesPlaceholder,
                      required: false,
                      onChanged: (value) {
                        // O provider já está conectado ao controller
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // 4ª Seção: Comprovante da Despesa
              OptionalReceiptSection(
                imagePath: provider.receiptImagePath,
                hasImage: provider.hasReceiptImage,
                isUploading: provider.isUploadingImage,
                uploadError: provider.imageUploadError,
                onCameraSelected: () => provider.captureReceiptImage(),
                onGallerySelected: () => provider.selectReceiptImageFromGallery(),
                onImageRemoved: () => provider.removeReceiptImage(),
                title: 'Comprovante da Despesa',
                description: 'Anexe uma foto do comprovante da despesa (opcional)',
              ),

              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // Resumo do formulário (se tem dados válidos)
              if (provider.formModel.hasMinimumData)
                _buildFormSummary(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormSummary(BuildContext context, ExpenseFormProvider provider) {
    final model = provider.formModel;

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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GasometerDesignTokens.spacingMd),

            _buildSummaryRow('Tipo:', model.expenseType.displayName),
            _buildSummaryRow(
              'Valor:',
              'R\$ ${model.amount.toStringAsFixed(2)}',
            ),
            _buildSummaryRow('Data:', _formatDate(model.date)),
            _buildSummaryRow(
              'Odômetro:',
              '${model.odometer.toStringAsFixed(0)} km',
            ),

            if (model.location.isNotEmpty)
              _buildSummaryRow('Local:', model.location),

            if (model.hasReceipt) ...[
              const SizedBox(height: GasometerDesignTokens.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: GasometerDesignTokens.iconSizeXs,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: GasometerDesignTokens.spacingXs),
                  Text(
                    'Comprovante anexado',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeBody,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],

            // Indicadores de status
            const SizedBox(height: GasometerDesignTokens.spacingMd),
            Row(
              children: [
                // Status de validação
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GasometerDesignTokens.spacingSm,
                    vertical: GasometerDesignTokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        model.canSubmit
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        model.canSubmit ? Icons.check_circle : Icons.warning,
                        size: 14,
                        color: model.canSubmit ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: GasometerDesignTokens.spacingXs),
                      Text(
                        model.canSubmit ? 'Pronto' : 'Pendente',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: model.canSubmit ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: GasometerDesignTokens.spacingSm),

                // Indicador de valor alto
                if (model.isHighValue)
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

                // Indicador de recorrente
                if (model.isRecurring) ...[
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GasometerDesignTokens.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: GasometerDesignTokens.fontSizeCaption,
                color: GasometerDesignTokens.colorTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: GasometerDesignTokens.fontSizeBody,
                color: GasometerDesignTokens.colorTextPrimary,
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

  // Campo de data/hora removido - agora usa DateTimeField

  // Método de seleção de data removido - agora é tratado pelo DateTimeField






  // Validador de odômetro removido - agora é tratado pelo OdometerField
}
