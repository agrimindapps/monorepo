import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/forms/base_form_page.dart';
import '../../../../core/presentation/widgets/enhanced_dropdown.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_form_provider.dart';
import '../providers/maintenance_provider.dart';

class AddMaintenancePage extends BaseFormPage<MaintenanceFormProvider> {
  final MaintenanceEntity? maintenanceToEdit;
  final String? vehicleId;

  const AddMaintenancePage({
    super.key,
    this.maintenanceToEdit,
    this.vehicleId,
  });

  @override
  BaseFormPageState<MaintenanceFormProvider> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends BaseFormPageState<MaintenanceFormProvider> {
  final Map<String, ValidationResult> _validationResults = {};
  
  @override
  String get pageTitle => (widget as AddMaintenancePage).maintenanceToEdit != null ? 'Editar Manutenção' : 'Nova Manutenção';
  
  @override
  MaintenanceFormProvider createFormProvider() {
    final authProvider = context.read<AuthProvider>();
    return MaintenanceFormProvider(
      userId: authProvider.userId,
      initialVehicleId: (widget as AddMaintenancePage).vehicleId,
    );
  }
  
  @override
  Future<void> initializeFormProvider(MaintenanceFormProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    final maintenanceToEdit = (widget as AddMaintenancePage).maintenanceToEdit;
    
    // Set context for dependency injection access
    provider.setContext(context);

    await provider.initialize(
      vehicleId: (widget as AddMaintenancePage).vehicleId,
      userId: authProvider.userId,
    );
    
    // If editing, populate form with existing data
    if (maintenanceToEdit != null) {
      await provider.initializeWithMaintenance(maintenanceToEdit);
    }
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
              _buildVehicleInfoCard(),
              FormSpacing.section(),
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
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorHeaderBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
            blurRadius: 9,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.build,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Registrar Manutenção',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Adicione informações sobre a manutenção realizada',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
              /// ✅ UX ENHANCEMENT: Enhanced maintenance type dropdown
              EnhancedDropdown<String>(
                label: 'Tipo',
                value: formProvider.formModel.type == MaintenanceType.preventive ? 'preventiva' : 'corretiva',
                prefixIcon: Icon(
                  formProvider.formModel.type == MaintenanceType.preventive 
                    ? Icons.schedule 
                    : Icons.build,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                items: const [
                  EnhancedDropdownItem(
                    value: 'preventiva',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Preventiva', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Manutenção planejada', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  EnhancedDropdownItem(
                    value: 'corretiva',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Corretiva', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Reparo de problema', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => formProvider.updateType(
                  value == 'preventiva' ? MaintenanceType.preventive : MaintenanceType.corrective
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
      final maintenanceToEdit = (widget as AddMaintenancePage).maintenanceToEdit;
      
      // Criar entidade usando o FormProvider
      final maintenanceEntity = provider.formModel.toMaintenanceEntity();
      
      bool success;
      if (maintenanceToEdit != null) {
        // Modo edição - preservar ID da entidade original
        final updatedEntity = maintenanceEntity.copyWith(id: maintenanceToEdit.id);
        success = await maintenanceProvider.updateMaintenanceRecord(updatedEntity);
      } else {
        // Modo criação
        success = await maintenanceProvider.addMaintenanceRecord(maintenanceEntity);
      }

      if (success) {
        final message = maintenanceToEdit != null 
            ? 'Manutenção atualizada com sucesso!' 
            : 'Manutenção salva com sucesso!';
        showSuccessSnackbar(message);
      } else {
        onFormSubmitFailure('Erro ao salvar: ${maintenanceProvider.errorMessage ?? "Erro desconhecido"}');
      }
      
      return success;
    } catch (e) {
      onFormSubmitFailure('Erro ao salvar manutenção: ${e.toString()}');
      return false;
    }
  }

  /// Card informativo do veículo selecionado
  Widget _buildVehicleInfoCard() {
    final vehicle = formProvider.formModel.vehicle;
    
    if (vehicle == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Veículo não foi informado',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.color} • ${vehicle.licensePlate}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ REMOVED: Old dropdown method no longer needed with EnhancedDropdown
}
