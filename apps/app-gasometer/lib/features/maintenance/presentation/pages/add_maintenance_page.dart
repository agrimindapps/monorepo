import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _workshopController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final Map<String, ValidationResult> _validationResults = {};
  
  String _selectedVehicle = '';
  String _selectedCategory = 'preventiva';
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;

  @override
  void dispose() {
    _typeController.dispose();
    _workshopController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Nova Manutenção',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    FormSpacing.section(),
                    _buildVehicleSelection(),
                    _buildBasicInfo(),
                    _buildCostAndOdometer(),
                    _buildDescription(),
                    _buildNextServiceDate(),
                    FormSpacing.section(),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
            ),
            child: Icon(
              Icons.build,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: GasometerDesignTokens.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Manutenção',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeXl,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Adicione informações sobre a manutenção realizada',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return FormSectionWidget.withTitle(
      title: 'Veículo',
      icon: Icons.directions_car,
      content: Container(
        padding: GasometerDesignTokens.paddingHorizontal(GasometerDesignTokens.spacingLg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: DropdownButton<String>(
          value: _selectedVehicle.isEmpty ? null : _selectedVehicle,
          hint: Text(
            'Selecione o veículo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          isExpanded: true,
          underline: const SizedBox(),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Honda Civic')),
            DropdownMenuItem(value: '2', child: Text('Toyota Corolla')),
          ],
          onChanged: (value) => setState(() => _selectedVehicle = value!),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return FormSectionWidget.withTitle(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      content: Column(
        children: [
          ValidatedFormField(
            controller: _typeController,
            label: 'Tipo de Manutenção',
            hint: 'Ex: Troca de óleo, Revisão completa...',
            required: true,
            validationType: ValidationType.length,
            minLength: 3,
            maxLengthValidation: 100,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)]'))],
            onValidationChanged: (result) => _validationResults['type'] = result,
          ),
          FormSpacing.large(),
          ValidatedFormField(
            controller: _workshopController,
            label: 'Oficina/Local',
            hint: 'Nome da oficina ou local da manutenção',
            required: true,
            validationType: ValidationType.length,
            minLength: 2,
            maxLengthValidation: 100,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)\/&]'))],
            onValidationChanged: (result) => _validationResults['workshop'] = result,
          ),
          FormSpacing.large(),
          FormFieldRow.standard(
            children: [
              Container(
                padding: GasometerDesignTokens.paddingHorizontal(GasometerDesignTokens.spacingLg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'preventiva', child: Text('Preventiva')),
                    DropdownMenuItem(value: 'corretiva', child: Text('Corretiva')),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: GasometerDesignTokens.paddingOnly(
                    left: GasometerDesignTokens.spacingLg,
                    right: GasometerDesignTokens.spacingLg,
                    top: GasometerDesignTokens.spacingLg,
                    bottom: GasometerDesignTokens.spacingLg,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: GasometerDesignTokens.spacingSm),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostAndOdometer() {
    return FormSectionWidget.withTitle(
      title: 'Valores e Medições',
      icon: Icons.monetization_on_outlined,
      content: FormFieldRow.standard(
        children: [
          ValidatedFormField(
            controller: _costController,
            label: 'Custo',
            hint: '0,00',
            required: true,
            validationType: ValidationType.money,
            minValue: 0.0,
            maxValue: 999999.99,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
            ),
            onValidationChanged: (result) => _validationResults['cost'] = result,
          ),
          ValidatedFormField(
            controller: _odometerController,
            label: 'Odômetro',
            hint: '0,0',
            required: true,
            validationType: ValidationType.decimal,
            minValue: 0.0,
            maxValue: 9999999.0,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            decoration: const InputDecoration(
              suffixText: 'km',
            ),
            onValidationChanged: (result) => _validationResults['odometer'] = result,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return FormSectionWidget.withTitle(
      title: 'Descrição',
      icon: Icons.description_outlined,
      content: ValidatedFormField(
        controller: _descriptionController,
        label: 'Detalhes da manutenção',
        hint: 'Descreva os serviços realizados, peças trocadas, etc.',
        required: true,
        validationType: ValidationType.length,
        minLength: 5,
        maxLengthValidation: 500,
        maxLines: 4,
        maxLength: 500,
        showCharacterCount: true,
        onValidationChanged: (result) => _validationResults['description'] = result,
      ),
    );
  }

  Widget _buildNextServiceDate() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notification_important,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: GasometerDesignTokens.spacingSm),
                Text(
                  'Próxima Manutenção (Opcional)',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            InkWell(
              onTap: () => _selectNextServiceDate(context),
              child: Container(
                padding: GasometerDesignTokens.paddingOnly(
                      left: GasometerDesignTokens.spacingLg,
                      right: GasometerDesignTokens.spacingLg,
                      top: GasometerDesignTokens.spacingLg,
                      bottom: GasometerDesignTokens.spacingLg,
                    ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: GasometerDesignTokens.spacingSm),
                    Text(
                      _nextServiceDate != null
                          ? '${_nextServiceDate!.day.toString().padLeft(2, '0')}/${_nextServiceDate!.month.toString().padLeft(2, '0')}/${_nextServiceDate!.year}'
                          : 'Definir data da próxima manutenção',
                      style: TextStyle(
                        color: _nextServiceDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_nextServiceDate != null)
              Padding(
                padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
                child: TextButton(
                  onPressed: () => setState(() => _nextServiceDate = null),
                  child: Text(
                    'Remover data',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FormActionButtons.standard(
      secondaryButton: OutlinedButton(
        onPressed: () => context.pop(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          padding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingLg),
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
          ),
        ),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: GasometerDesignTokens.fontSizeLg,
          ),
        ),
      ),
      primaryButton: ElevatedButton(
        onPressed: _saveMaintenance,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingLg),
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
          ),
        ),
        child: Text(
          'Salvar Manutenção',
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeLg,
            fontWeight: GasometerDesignTokens.fontWeightSemiBold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectNextServiceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _nextServiceDate = date);
    }
  }

  void _saveMaintenance() {
    // Valida todos os campos primeiro
    final hasErrors = _validationResults.values.any((result) => !result.isValid);
    if (hasErrors || !(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, corrija os erros no formulário'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    if (_selectedVehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um veículo'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Aqui você implementaria a lógica para salvar a manutenção
    // Por exemplo: chamar um repository, service, etc.
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Manutenção salva com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    
    context.pop();
  }
}
