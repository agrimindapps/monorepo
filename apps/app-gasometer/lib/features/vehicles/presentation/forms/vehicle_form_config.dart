import 'package:flutter/material.dart';
import '../../../../core/validation/forms.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Form configuration for vehicle registration following SOLID principles
/// 
/// This configuration defines the complete form structure for vehicle
/// registration and editing, implementing the Template Method pattern
/// and ensuring separation of concerns.
class VehicleFormConfig extends FormConfig<VehicleEntity> {
  @override
  String get formId => 'vehicle_form';
  
  @override
  String get title => 'Cadastro de Veículo';
  
  @override
  String? get subtitle => 'Preencha as informações do seu veículo';
  
  @override
  FormValidationMode get validationMode => FormValidationMode.onInteraction;
  
  @override
  bool get autoSaveEnabled => true;
  
  @override
  bool get allowOfflineSubmission => true;
  
  @override
  List<FieldConfig> buildFields() {
    return [
      FieldTemplates.name(
        key: 'marca',
        label: 'Marca',
        isRequired: true,
      ),
      FieldTemplates.name(
        key: 'modelo', 
        label: 'Modelo',
        isRequired: true,
      ),
      NumberFieldConfig(
        key: 'ano',
        label: 'Ano',
        isRequired: true,
        minValue: 1900,
        maxValue: DateTime.now().year + 1,
        decimalPlaces: 0,
        allowNegative: false,
      ),
      const TextFieldConfig(
        key: 'cor',
        label: 'Cor',
        isRequired: true,
        maxLength: 50,
      ),
      const TextFieldConfig(
        key: 'placa',
        label: 'Placa',
        isRequired: true,
        maxLength: 8,
        validationPattern: r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$',
        hint: 'Ex: ABC1234 ou ABC1D23',
      ),
      const TextFieldConfig(
        key: 'chassi',
        label: 'Chassi',
        isRequired: false,
        maxLength: 17,
        validationPattern: r'^[A-HJ-NPR-Z0-9]{17}$',
        hint: '17 caracteres alfanuméricos',
      ),
      const TextFieldConfig(
        key: 'renavam',
        label: 'RENAVAM',
        isRequired: false,
        maxLength: 11,
        validationPattern: r'^[0-9]{9,11}$',
        hint: '9 a 11 dígitos',
        keyboardType: TextInputType.number,
      ),
      const DropdownFieldConfig(
        key: 'combustivel',
        label: 'Tipo de Combustível',
        isRequired: true,
        options: [
          DropdownOption(value: 'Gasolina', label: 'Gasolina'),
          DropdownOption(value: 'Etanol', label: 'Etanol'),
          DropdownOption(value: 'Flex', label: 'Flex (Gasolina/Etanol)'),
          DropdownOption(value: 'Diesel', label: 'Diesel'),
          DropdownOption(value: 'GNV', label: 'GNV (Gás Natural)'),
          DropdownOption(value: 'Híbrido', label: 'Híbrido'),
          DropdownOption(value: 'Elétrico', label: 'Elétrico'),
        ],
        initialValue: 'Gasolina',
      ),
      const NumberFieldConfig(
        key: 'odometro',
        label: 'Quilometragem Atual (km)',
        isRequired: true,
        minValue: 0,
        maxValue: 9999999,
        decimalPlaces: 0,
        allowNegative: false,
        hint: 'Digite a quilometragem atual do veículo',
      ),
    ];
  }
  
  @override
  List<IFieldValidator> buildValidators() {
    return [
    ];
  }
  
  @override
  VehicleEntity? transformDataForValidation(Map<String, dynamic> fieldValues) {
    try {
      return _createVehicleFromFormData(fieldValues);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Map<String, dynamic> transformDataForSubmission(VehicleEntity data) {
    return _vehicleToFormData(data);
  }
  
  /// Convert form data to VehicleEntity
  VehicleEntity _createVehicleFromFormData(Map<String, dynamic> data) {
    final now = DateTime.now();
    
    return VehicleEntity(
      id: '', // Will be set by repository
      userId: '', // Will be set by repository
      name: '${data['marca']?.toString() ?? ''} ${data['modelo']?.toString() ?? ''}',
      brand: data['marca']?.toString() ?? '',
      model: data['modelo']?.toString() ?? '',
      year: (data['ano'] as int?) ?? DateTime.now().year,
      color: data['cor']?.toString() ?? '',
      licensePlate: data['placa']?.toString() ?? '',
      type: VehicleType.car, // Default, could be made configurable
      supportedFuels: _mapCombustivelToFuelTypes(data['combustivel']?.toString()),
      currentOdometer: ((data['odometro'] as num?) ?? 0).toDouble(),
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// Convert VehicleEntity to form data
  Map<String, dynamic> _vehicleToFormData(VehicleEntity vehicle) {
    return {
      'marca': vehicle.brand,
      'modelo': vehicle.model,
      'ano': vehicle.year,
      'cor': vehicle.color,
      'placa': vehicle.licensePlate,
      'combustivel': _mapFuelTypesToCombustivel(vehicle.supportedFuels),
      'odometro': vehicle.currentOdometer.toInt(),
    };
  }
  
  /// Map combustivel string to FuelType list
  List<FuelType> _mapCombustivelToFuelTypes(String? combustivel) {
    switch (combustivel) {
      case 'Gasolina':
        return [FuelType.gasoline];
      case 'Etanol':
        return [FuelType.ethanol];
      case 'Flex':
        return [FuelType.gasoline, FuelType.ethanol];
      case 'Diesel':
        return [FuelType.diesel];
      case 'GNV':
        return [FuelType.gas];
      case 'Híbrido':
        return [FuelType.hybrid];
      case 'Elétrico':
        return [FuelType.electric];
      default:
        return [FuelType.gasoline];
    }
  }
  
  /// Map FuelType list to combustivel string
  String _mapFuelTypesToCombustivel(List<FuelType> fuelTypes) {
    if (fuelTypes.isEmpty) return 'Gasolina';
    
    if (fuelTypes.contains(FuelType.gasoline) && fuelTypes.contains(FuelType.ethanol)) {
      return 'Flex';
    }
    
    final primaryFuel = fuelTypes.first;
    switch (primaryFuel) {
      case FuelType.gasoline:
        return 'Gasolina';
      case FuelType.ethanol:
        return 'Etanol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.gas:
        return 'GNV';
      case FuelType.hybrid:
        return 'Híbrido';
      case FuelType.electric:
        return 'Elétrico';
    }
  }
  
  @override
  Future<FormSubmissionResult<VehicleEntity>> submitForm(VehicleEntity data) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return FormSubmissionResult.success(data);
    } catch (e) {
      return FormSubmissionResult.failure(
        'Erro ao salvar veículo: ${e.toString()}'
      );
    }
  }
  
  @override
  Future<VehicleEntity?> loadFormData(String? id) async {
    if (id == null) return null;
    
    try {
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  FormConfig<VehicleEntity> copyWith({
    FormValidationMode? validationMode,
    bool? autoSaveEnabled,
    int? autoSaveInterval,
    bool? allowOfflineSubmission,
    int? maxRetryAttempts,
  }) {
    return VehicleFormConfig();
  }
}
