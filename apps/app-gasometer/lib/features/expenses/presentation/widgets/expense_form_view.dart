import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/form_section_widget.dart';
import '../../../../core/presentation/widgets/validated_text_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../core/constants/expense_constants.dart';
import '../providers/expense_form_provider.dart';
import 'expense_type_selector.dart';
import 'receipt_image_picker.dart';

/// Widget principal do formulário de despesas
class ExpenseFormView extends StatelessWidget {
  final ExpenseFormProvider formProvider;

  const ExpenseFormView({super.key, required this.formProvider});

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
              _buildSectionWithoutPadding(
                title: 'Informações da Despesa',
                icon: Icons.shopping_cart,
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
                      label: 'Descrição da Despesa *',
                      hint: ExpenseConstants.descriptionPlaceholder,
                      maxLength: ExpenseConstants.maxDescriptionLength,
                      required: true,
                      showCharacterCount: true,
                      prefixIcon: Icons.description,
                      validator:
                          (value) =>
                              provider.validateField('description', value),
                      debounceDuration: const Duration(milliseconds: 300),
                    ),

                    SizedBox(height: GasometerDesignTokens.spacingMd),

                    // Data e Hora unified
                    _buildDateTimeField(context, provider),
                  ],
                ),
              ),

              SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // 2ª Seção: Informações Financeiras e Técnicas (QUANTO custou e quilometragem)
              _buildSectionWithoutPadding(
                title: 'Informações Financeiras e Técnicas',
                icon: Icons.monetization_on,
                content: Column(
                  children: [
                    FormFieldRow.standard(
                      children: [
                        // Valor com validação monetária
                        ValidatedTextField(
                          controller: provider.amountController,
                          label: 'Valor Total *',
                          hint: ExpenseConstants.amountPlaceholder,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Icons.attach_money,
                          required: true,
                          validator: _validateMoney,
                          debounceDuration: const Duration(milliseconds: 500),
                        ),
                        // Odômetro
                        ValidatedTextField(
                          controller: provider.odometerController,
                          label: 'Quilometragem Atual *',
                          hint: ExpenseConstants.odometerPlaceholder,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Icons.speed,
                          suffix: Text(
                            ExpenseConstants.kilometerUnit,
                            style: TextStyle(
                              color: GasometerDesignTokens.colorTextSecondary,
                              fontSize: GasometerDesignTokens.fontSizeBody,
                            ),
                          ),
                          required: true,
                          validator: _validateOdometer,
                          debounceDuration: const Duration(milliseconds: 400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),

              // 3ª Seção: Detalhes Adicionais (ONDE foi realizada)
              _buildSectionWithoutPadding(
                title: 'Detalhes Adicionais',
                icon: Icons.location_on,
                content: Column(
                  children: [
                    // Localização (opcional)
                    ValidatedTextField(
                      controller: provider.locationController,
                      label: 'Local da Despesa',
                      hint: ExpenseConstants.locationPlaceholder,
                      maxLength: ExpenseConstants.maxLocationLength,
                      prefixIcon: Icons.location_on,
                      showCharacterCount: true,
                      validator: (value) {
                        if (value != null &&
                            value.length > ExpenseConstants.maxLocationLength) {
                          return 'Localização muito longa';
                        }
                        return null;
                      },
                      debounceDuration: const Duration(milliseconds: 600),
                    ),

                    SizedBox(height: GasometerDesignTokens.spacingMd),

                    // Observações
                    ValidatedTextField(
                      controller: provider.notesController,
                      label: 'Observações Adicionais',
                      hint: ExpenseConstants.notesPlaceholder,
                      maxLines: 3,
                      maxLength: ExpenseConstants.maxNotesLength,
                      prefixIcon: Icons.note_alt,
                      showCharacterCount: true,
                      validator: (value) {
                        if (value != null &&
                            value.length > ExpenseConstants.maxNotesLength) {
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

              // 4ª Seção: Comprovante da Despesa
              _buildSectionWithoutPadding(
                title: 'Comprovante da Despesa',
                icon: Icons.receipt,
                content: Column(
                  children: [
                    Text(
                      'Anexe uma foto do comprovante da despesa (opcional)',
                      style: TextStyle(
                        fontSize: GasometerDesignTokens.fontSizeCaption,
                        color: GasometerDesignTokens.colorTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: GasometerDesignTokens.spacingSm),
                    // Comprovante (imagem)
                    ReceiptImagePicker(
                      imagePath: provider.receiptImagePath,
                      hasImage: provider.hasReceiptImage,
                      onImageSelected:
                          () => _showImagePickerOptions(context, provider),
                      onImageRemoved: () => provider.removeReceiptImage(),
                    ),
                    if (provider.isUploadingImage) _buildUploadingIndicator(),
                    if (provider.imageUploadError != null)
                      _buildErrorIndicator(provider.imageUploadError!),
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
                SizedBox(width: GasometerDesignTokens.spacingSm),
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
            SizedBox(height: GasometerDesignTokens.spacingMd),

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
              SizedBox(height: GasometerDesignTokens.spacingSm),
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: GasometerDesignTokens.iconSizeXs,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: GasometerDesignTokens.spacingXs),
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
            SizedBox(height: GasometerDesignTokens.spacingMd),
            Row(
              children: [
                // Status de validação
                Container(
                  padding: EdgeInsets.symmetric(
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
                      SizedBox(width: GasometerDesignTokens.spacingXs),
                      Text(
                        model.canSubmit ? 'Pronto' : 'Pendente',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: model.canSubmit ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: GasometerDesignTokens.spacingSm),

                // Indicador de valor alto
                if (model.isHighValue)
                  Container(
                    padding: EdgeInsets.symmetric(
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
                        SizedBox(width: GasometerDesignTokens.spacingXs),
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
                  SizedBox(width: GasometerDesignTokens.spacingSm),
                  Container(
                    padding: EdgeInsets.symmetric(
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
                        SizedBox(width: GasometerDesignTokens.spacingXs),
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

  Widget _buildDateTimeField(
    BuildContext context,
    ExpenseFormProvider provider,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDateTime(context, provider),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Data e Hora',
            suffixIcon: const Icon(Icons.calendar_today, size: 24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
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
                  TimeOfDay.fromDateTime(
                    provider.formModel.date,
                  ).format(context),
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

  Future<void> _selectDateTime(
    BuildContext context,
    ExpenseFormProvider provider,
  ) async {
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
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

  // Helper para criar seções sem padding lateral
  Widget _buildSectionWithoutPadding({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: GasometerDesignTokens.spacingMd,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: GasometerDesignTokens.iconSizeSm,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: GasometerDesignTokens.spacingSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeLg,
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                  color: GasometerDesignTokens.colorTextPrimary,
                ),
              ),
            ],
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildUploadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(width: GasometerDesignTokens.spacingSm),
          Text(
            'Processando imagem...',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeSm,
              color: GasometerDesignTokens.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(String error) {
    return Padding(
      padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: GasometerDesignTokens.colorError,
          ),
          SizedBox(width: GasometerDesignTokens.spacingSm),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeSm,
                color: GasometerDesignTokens.colorError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(
    BuildContext context,
    ExpenseFormProvider provider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                subtitle: const Text('Tirar uma nova foto'),
                onTap: () {
                  Navigator.pop(context);
                  provider.captureReceiptImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                subtitle: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  provider.selectReceiptImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Validadores locais
  String? _validateMoney(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove formatação e tenta converter
    final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    final doubleValue = double.tryParse(cleanValue.replaceAll(',', '.'));

    if (doubleValue == null) {
      return 'Valor inválido';
    }

    if (doubleValue <= 0) {
      return 'Valor deve ser maior que zero';
    }

    return null;
  }

  String? _validateOdometer(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';

    final intValue = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));

    if (intValue == null) {
      return 'Valor inválido';
    }

    if (intValue < 0 || intValue > 999999) {
      return 'Valor deve estar entre 0 e 999999';
    }

    return null;
  }
}
