import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/forms/base_form_page.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_form_provider.dart';
import '../providers/maintenance_provider.dart';

class AddMaintenancePage extends BaseFormPage<MaintenanceFormProvider> {
  const AddMaintenancePage({super.key});

  @override
  BaseFormPageState<MaintenanceFormProvider> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends BaseFormPageState<MaintenanceFormProvider> {
  final Map<String, ValidationResult> _validationResults = {};
  
  @override
  String get pageTitle => 'Manutenção';
  
  @override
  MaintenanceFormProvider createFormProvider() {
    final authProvider = context.read<AuthProvider>();
    return MaintenanceFormProvider(
      userId: authProvider.userId,
    );
  }
  
  @override
  Future<void> initializeFormProvider(MaintenanceFormProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    
    // Set context for dependency injection access
    provider.setContext(context);

    await provider.initialize(
      userId: authProvider.userId,
    );
  }

  @override
  Widget buildFormContent(BuildContext context, MaintenanceFormProvider provider) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
          value: formProvider.formModel.vehicleId.isEmpty ? null : formProvider.formModel.vehicleId,
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
          items: _buildVehicleDropdownItems(),
          onChanged: (value) {
            // TODO: Implementar updateVehicle no FormProvider
            // formProvider.updateVehicle(value!);
          },
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
            controller: formProvider.titleController,
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
            controller: formProvider.workshopNameController,
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
                  value: formProvider.formModel.type == MaintenanceType.preventive ? 'preventiva' : 'corretiva',
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'preventiva', child: const Text('Preventiva')),
                    DropdownMenuItem(value: 'corretiva', child: const Text('Corretiva')),
                  ],
                  onChanged: (value) => formProvider.updateType(
                    value == 'preventiva' ? MaintenanceType.preventive : MaintenanceType.corrective
                  ),
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
                        '${formProvider.formModel.serviceDate.day.toString().padLeft(2, '0')}/${formProvider.formModel.serviceDate.month.toString().padLeft(2, '0')}/${formProvider.formModel.serviceDate.year}',
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
            controller: formProvider.costController,
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
            controller: formProvider.odometerController,
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
        controller: formProvider.descriptionController,
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
                      formProvider.formModel.nextServiceDate != null
                          ? '${formProvider.formModel.nextServiceDate!.day.toString().padLeft(2, '0')}/${formProvider.formModel.nextServiceDate!.month.toString().padLeft(2, '0')}/${formProvider.formModel.nextServiceDate!.year}'
                          : 'Definir data da próxima manutenção',
                      style: TextStyle(
                        color: formProvider.formModel.nextServiceDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (formProvider.formModel.nextServiceDate != null)
              Padding(
                padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
                child: TextButton(
                  onPressed: () => formProvider.updateNextServiceDate(null),
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
        onPressed: () => onSubmitForm(context, formProvider),
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
    await formProvider.pickServiceDate(context);
  }

  Future<void> _selectNextServiceDate(BuildContext context) async {
    await formProvider.pickNextServiceDate(context);
  }

  @override
  Future<bool> onSubmitForm(BuildContext context, MaintenanceFormProvider provider) async {
    if (!provider.validateForm()) {
      return false;
    }

    try {
      final maintenanceProvider = context.read<MaintenanceProvider>();
      
      // Criar entidade usando o FormProvider
      final maintenanceEntity = provider.formModel.toMaintenanceEntity();
      
      final success = await maintenanceProvider.addMaintenanceRecord(maintenanceEntity);

      if (success) {
        showSuccessSnackbar('Manutenção salva com sucesso!');
      } else {
        onFormSubmitFailure('Erro ao salvar: ${maintenanceProvider.errorMessage ?? "Erro desconhecido"}');
      }
      
      return success;
    } catch (e) {
      onFormSubmitFailure('Erro ao salvar manutenção: ${e.toString()}');
      return false;
    }
  }

  /// Constrói os itens do dropdown de veículos
  List<DropdownMenuItem<String>> _buildVehicleDropdownItems() {
    return Provider.of<VehiclesProvider>(context, listen: false)
        .vehicles
        .map((vehicle) => DropdownMenuItem<String>(
              value: vehicle.id,
              child: Text('${vehicle.brand} ${vehicle.model}'),
            ))
        .toList();
  }
}
