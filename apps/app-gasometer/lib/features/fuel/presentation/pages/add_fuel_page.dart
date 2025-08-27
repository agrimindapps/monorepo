import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/forms/base_form_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/fuel_form_provider.dart';
import '../providers/fuel_provider.dart';
import '../widgets/fuel_form_view.dart';

class AddFuelPage extends BaseFormPage<FuelFormProvider> {
  final String? vehicleId;
  final String? editFuelRecordId;
  
  const AddFuelPage({
    super.key,
    this.vehicleId,
    this.editFuelRecordId,
  });

  @override
  BaseFormPageState<FuelFormProvider> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends BaseFormPageState<FuelFormProvider> {
  AddFuelPage get _widget => widget as AddFuelPage;
  
  @override
  bool get isEditMode => _widget.editFuelRecordId != null;
  
  @override
  String get pageTitle => 'Abastecimento';
  
  @override
  FuelFormProvider createFormProvider() {
    final authProvider = context.read<AuthProvider>();
    
    return FuelFormProvider(
      initialVehicleId: _widget.vehicleId,
      userId: authProvider.userId,
    );
  }
  
  @override
  Future<void> initializeFormProvider(FuelFormProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    
    // Set context for dependency injection access
    provider.setContext(context);

    await provider.initialize(
      vehicleId: _widget.vehicleId,
      userId: authProvider.userId,
    );
    
    if (_widget.editFuelRecordId != null) {
      await _loadFuelRecordForEdit(provider);
    }
  }

  Future<void> _loadFuelRecordForEdit(FuelFormProvider provider) async {
    try {
      final fuelProvider = context.read<FuelProvider>();
      // Primeiro garantir que os dados foram carregados
      await fuelProvider.loadAllFuelRecords();
      
      final record = fuelProvider.getFuelRecordById(_widget.editFuelRecordId!);
      
      if (record != null) {
        await provider.loadFromFuelRecord(record);
      } else {
        throw Exception('Registro de abastecimento não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao carregar registro para edição: $e');
    }
  }


  @override
  Widget buildFormContent(BuildContext context, FuelFormProvider provider) {
    return FuelFormView(
      formProvider: provider,
      onSubmit: () => onSubmitForm(context, provider),
    );
  }

  @override
  Future<bool> onSubmitForm(BuildContext context, FuelFormProvider provider) async {
    if (!provider.validateForm()) {
      return false;
    }

    try {
      final fuelProvider = context.read<FuelProvider>();
      final fuelRecord = provider.formModel.toFuelRecord();
      
      bool success;
      if (_widget.editFuelRecordId != null) {
        success = await fuelProvider.updateFuelRecord(fuelRecord);
      } else {
        success = await fuelProvider.addFuelRecord(fuelRecord);
      }

      if (!success) {
        onFormSubmitFailure(
          fuelProvider.errorMessage ?? 'Erro ao salvar abastecimento'
        );
      }
      
      return success;
    } catch (e) {
      onFormSubmitFailure('Erro inesperado: $e');
      return false;
    }
  }

}
