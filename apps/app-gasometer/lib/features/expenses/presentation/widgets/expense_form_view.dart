import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/form_section_widget.dart';
import '../../../../core/presentation/widgets/validated_datetime_field.dart';
import '../../../../core/presentation/widgets/validated_text_field.dart';
import '../../../../core/theme/design_tokens.dart';
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
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeXl,
                      fontWeight: GasometerDesignTokens.fontWeightBold,
                      color: GasometerDesignTokens.colorTextPrimary,
                    ),
                  ),
                  SizedBox(height: GasometerDesignTokens.spacingMd),
                ],

                // Seção: Informações Básicas
                FormSectionWidget.withTitle(
                  title: ExpenseConstants.basicInfoSectionTitle,
                  icon: Icons.info_outline,
                  content: Column(
                    children: [
                      // Seletor de tipo de despesa
                      ExpenseTypeSelector(
                        selectedType: provider.formModel.expenseType,
                        onTypeSelected: provider.updateExpenseType,
                        error: provider.formModel.getFieldError('expenseType'),
                      ),
                      
                      SizedBox(height: GasometerDesignTokens.spacingMd),

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
                        debounceDuration: const Duration(milliseconds: 300),
                      ),

                      SizedBox(height: GasometerDesignTokens.spacingMd),

                      // Data e Hora unified  
                      _buildDateTimeField(context, provider),
                    ],
                  ),
                ),

                SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

                // Seção: Valores
                FormSectionWidget.withTitle(
                  title: ExpenseConstants.expenseSectionTitle,
                  icon: Icons.attach_money,
                  content: Column(
                    children: [
                      FormFieldRow.standard(
                        children: [
                          // Valor com validação monetária
                          ValidatedTextField(
                            controller: provider.amountController,
                            label: 'Valor *',
                            hint: ExpenseConstants.amountPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.attach_money,
                            required: true,
                            validator: CommonValidators.moneyValidator,
                            debounceDuration: const Duration(milliseconds: 500),
                          ),
                          // Odômetro
                          ValidatedTextField(
                            controller: provider.odometerController,
                            label: 'Odômetro *',
                            hint: ExpenseConstants.odometerPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.speed,
                            suffix: Text(
                              ExpenseConstants.kilometerUnit,
                              style: TextStyle(
                                color: GasometerDesignTokens.colorTextSecondary,
                                fontSize: GasometerDesignTokens.fontSizeBody,
                              ),
                            ),
                            required: true,
                            validator: (value) => CommonValidators.intValidator(
                              value,
                              min: 0,
                              max: 999999,
                            ),
                            debounceDuration: const Duration(milliseconds: 400),
                          ),
                        ],
                      ),

                      SizedBox(height: GasometerDesignTokens.spacingMd),

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
                        debounceDuration: const Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

                // Seção: Comprovante e Observações
                FormSectionWidget.withTitle(
                  title: ExpenseConstants.additionalSectionTitle,
                  icon: Icons.attachment,
                  content: Column(
                    children: [
                      // Comprovante (imagem)
                      ReceiptImagePicker(
                        imagePath: provider.formModel.receiptImagePath,
                        onImageSelected: provider.addReceiptImage,
                        onImageRemoved: provider.removeReceiptImage,
                        hasImage: provider.hasReceiptImage,
                      ),

                      SizedBox(height: GasometerDesignTokens.spacingMd),

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
                        debounceDuration: const Duration(milliseconds: 800),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

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



  Widget _buildFormSummary(BuildContext context, ExpenseFormProvider provider) {
    final model = provider.formModel;
    
    return Card(
      color: GasometerDesignTokens.colorPrimaryLight.withOpacity(0.3),
      child: Padding(
        padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: GasometerDesignTokens.colorPrimary,
                  size: GasometerDesignTokens.iconSizeSm,
                ),
                SizedBox(width: GasometerDesignTokens.spacingSm),
                Text(
                  'Resumo',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightMedium,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            
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
                    size: GasometerDesignTokens.iconSizeXs,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingXs),
                  Text(
                    'Comprovante anexado',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeBody,
                      color: GasometerDesignTokens.colorPrimary,
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
      padding: EdgeInsets.only(bottom: GasometerDesignTokens.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeCaption,
                color: GasometerDesignTokens.colorTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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

  Widget _buildDateTimeField(BuildContext context, ExpenseFormProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDateTime(context, provider),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Data e Hora',
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy').format(provider.formModel.date),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 20,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TimeOfDay.fromDateTime(provider.formModel.date).format(context),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, ExpenseFormProvider provider) async {
    // Select date first
    final date = await showDatePicker(
      context: context,
      initialDate: provider.formModel.date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      // Then select time
      final currentTime = TimeOfDay.fromDateTime(provider.formModel.date);
      final time = await showTimePicker(
        context: context,
        initialTime: currentTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            ),
          );
        },
      );

      if (time != null) {
        // Update provider with combined date and time
        final combinedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        provider.updateDate(combinedDateTime);
      }
    }
  }
}