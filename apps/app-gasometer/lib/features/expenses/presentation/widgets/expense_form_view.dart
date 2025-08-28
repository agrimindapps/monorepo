import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/validated_text_field.dart';
import '../../core/constants/expense_constants.dart';
import '../providers/expense_form_provider.dart';
import 'expense_type_selector.dart';
import 'receipt_image_picker.dart';

/// Widget principal do formulário de despesas
class ExpenseFormView extends StatelessWidget {
  final ExpenseFormProvider formProvider;
  final bool showTitle;
  final EdgeInsets? padding;

  const ExpenseFormView({
    super.key,
    required this.formProvider,
    this.showTitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Consumer<ExpenseFormProvider>(
        builder: (context, provider, child) {
          return Form(
            key: provider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle) ...[
                  Text(
                    'Nova Despesa',
                    style: AppTheme.textStyles.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                ],

                // Seção: Informações Básicas
                _buildSection(
                  context,
                  title: ExpenseConstants.basicInfoSectionTitle,
                  children: [
                    // Seletor de tipo de despesa
                    ExpenseTypeSelector(
                      selectedType: provider.formModel.expenseType,
                      onTypeSelected: provider.updateExpenseType,
                      error: provider.formModel.getFieldError('expenseType'),
                    ),
                    
                    const SizedBox(height: ExpenseConstants.fieldSpacing),

                    // Descrição com validação em tempo real
                    ValidatedTextField(
                      controller: provider.descriptionController,
                      label: 'Descrição *',
                      hint: ExpenseConstants.descriptionPlaceholder,
                      maxLength: ExpenseConstants.maxDescriptionLength,
                      required: true,
                      showCharacterCount: true,
                      prefixIcon: Icons.description,
                      validator: (value) => provider.validateField('description', value),
                      // onChanged será tratado automaticamente pelo controller
                      debounceDuration: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: ExpenseConstants.fieldSpacing),

                    // Data e Hora
                    _buildDateTimeFields(context, provider),
                  ],
                ),

                const SizedBox(height: ExpenseConstants.sectionSpacing),

                // Seção: Valores
                _buildSection(
                  context,
                  title: ExpenseConstants.expenseSectionTitle,
                  children: [
                    Row(
                      children: [
                        // Valor com validação monetária
                        Expanded(
                          flex: 2,
                          child: ValidatedTextField(
                            controller: provider.amountController,
                            label: 'Valor *',
                            hint: ExpenseConstants.amountPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.attach_money,
                            required: true,
                            validator: CommonValidators.moneyValidator,
                            // onChanged será tratado automaticamente pelo controller
                            debounceDuration: const Duration(milliseconds: 500),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Odômetro
                        Expanded(
                          flex: 2,
                          child: ValidatedTextField(
                            controller: provider.odometerController,
                            label: 'Odômetro *',
                            hint: ExpenseConstants.odometerPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.speed,
                            suffix: const Text(
                              ExpenseConstants.kilometerUnit,
                              style: TextStyle(color: Colors.grey),
                            ),
                            required: true,
                            validator: (value) => CommonValidators.intValidator(
                              value,
                              min: 0,
                              max: 999999,
                            ),
                            // onChanged será tratado automaticamente pelo controller
                            debounceDuration: const Duration(milliseconds: 400),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: ExpenseConstants.fieldSpacing),

                    // Localização (opcional)
                    ValidatedTextField(
                      controller: provider.locationController,
                      label: 'Localização',
                      hint: ExpenseConstants.locationPlaceholder,
                      maxLength: ExpenseConstants.maxLocationLength,
                      prefixIcon: Icons.location_on,
                      showCharacterCount: true,
                      validator: (value) {
                        if (value != null && value.length > ExpenseConstants.maxLocationLength) {
                          return 'Localização muito longa';
                        }
                        return null;
                      },
                      // onChanged será tratado automaticamente pelo controller
                      debounceDuration: const Duration(milliseconds: 600),
                    ),
                  ],
                ),

                const SizedBox(height: ExpenseConstants.sectionSpacing),

                // Seção: Comprovante e Observações
                _buildSection(
                  context,
                  title: ExpenseConstants.additionalSectionTitle,
                  children: [
                    // Comprovante (imagem)
                    ReceiptImagePicker(
                      imagePath: provider.formModel.receiptImagePath,
                      onImageSelected: provider.addReceiptImage,
                      onImageRemoved: provider.removeReceiptImage,
                      hasImage: provider.hasReceiptImage,
                    ),

                    const SizedBox(height: ExpenseConstants.fieldSpacing),

                    // Observações
                    ValidatedTextField(
                      controller: provider.notesController,
                      label: 'Observações',
                      hint: ExpenseConstants.notesPlaceholder,
                      maxLines: 3,
                      maxLength: ExpenseConstants.maxNotesLength,
                      prefixIcon: Icons.note_alt,
                      showCharacterCount: true,
                      validator: (value) {
                        if (value != null && value.length > ExpenseConstants.maxNotesLength) {
                          return 'Observação muito longa';
                        }
                        return null;
                      },
                      // onChanged será tratado automaticamente pelo controller
                      debounceDuration: const Duration(milliseconds: 800),
                    ),
                  ],
                ),

                const SizedBox(height: ExpenseConstants.sectionSpacing),

                // Resumo do formulário (se tem dados válidos)
                if (provider.formModel.hasMinimumData)
                  _buildFormSummary(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDateTimeFields(BuildContext context, ExpenseFormProvider provider) {
    return Row(
      children: [
        // Data
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: () => provider.pickDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data *',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: provider.formModel.getFieldError('date'),
              ),
              child: Text(
                _formatDate(provider.formModel.date),
                style: AppTheme.textStyles.bodyLarge,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Hora
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () => provider.pickTime(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Hora',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _formatTime(provider.formModel.date),
                style: AppTheme.textStyles.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSummary(BuildContext context, ExpenseFormProvider provider) {
    final model = provider.formModel;
    
    return Card(
      color: AppTheme.colors.primaryLight.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: AppTheme.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo',
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildSummaryRow('Tipo:', model.expenseType.displayName),
            _buildSummaryRow('Valor:', 'R\$ ${model.amount.toStringAsFixed(2)}'),
            _buildSummaryRow('Data:', _formatDate(model.date)),
            _buildSummaryRow('Odômetro:', '${model.odometer.toStringAsFixed(0)} km'),
            
            if (model.location.isNotEmpty)
              _buildSummaryRow('Local:', model.location),
              
            if (model.hasReceipt) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: AppTheme.colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Comprovante anexado',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.primary,
                    ),
                  ),
                ],
              ),
            ],

            // Indicadores de status
            const SizedBox(height: 12),
            Row(
              children: [
                // Status de validação
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: model.canSubmit 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.orange.withOpacity(0.2),
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
                      const SizedBox(width: 4),
                      Text(
                        model.canSubmit ? 'Pronto' : 'Pendente',
                        style: AppTheme.textStyles.labelSmall?.copyWith(
                          color: model.canSubmit ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Indicador de valor alto
                if (model.isHighValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
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
                        const SizedBox(width: 4),
                        Text(
                          'Alto valor',
                          style: AppTheme.textStyles.labelSmall?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Indicador de recorrente
                if (model.isRecurring) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
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
                        const SizedBox(width: 4),
                        Text(
                          'Recorrente',
                          style: AppTheme.textStyles.labelSmall?.copyWith(
                            color: Colors.purple,
                          ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTheme.textStyles.labelSmall?.copyWith(
                color: AppTheme.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.textStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}