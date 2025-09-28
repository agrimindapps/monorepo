import 'package:flutter/material.dart';

import '../../../../core/presentation/forms/forms.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../forms/vehicle_form_config.dart';

/// Vehicle form widget using SOLID architecture
/// 
/// This widget demonstrates the new form architecture following SOLID principles:
/// - Single Responsibility: Each field handles its own logic
/// - Open/Closed: Easy to extend with new field types  
/// - Liskov Substitution: Field factories can be replaced
/// - Interface Segregation: Clean field configuration interfaces
/// - Dependency Inversion: Depends on abstractions, not concrete implementations
class SolidVehicleFormWidget extends StatefulWidget {

  const SolidVehicleFormWidget({
    super.key,
    this.initialVehicle,
    this.onSubmit,
    this.onCancel,
  });
  final VehicleEntity? initialVehicle;
  final Function(VehicleEntity)? onSubmit;
  final VoidCallback? onCancel;

  @override
  State<SolidVehicleFormWidget> createState() => _SolidVehicleFormWidgetState();
}

class _SolidVehicleFormWidgetState extends State<SolidVehicleFormWidget> {
  late final VehicleFormConfig _formConfig;
  late final MaterialFieldFactory _fieldFactory;
  late final FormStateManager<VehicleEntity> _stateManager;
  
  final Map<String, dynamic> _fieldValues = {};
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _formConfig = VehicleFormConfig();
    _fieldFactory = MaterialFieldFactory();
    _stateManager = FormStateManager<VehicleEntity>();
    
    // Initialize form with existing vehicle data if provided
    if (widget.initialVehicle != null) {
      _initializeFormData();
    }
  }

  void _initializeFormData() {
    final vehicle = widget.initialVehicle!;
    _fieldValues.addAll({
      'marca': vehicle.brand,
      'modelo': vehicle.model,
      'ano': vehicle.year,
      'cor': vehicle.color,
      'placa': vehicle.licensePlate,
      'combustivel': _mapFuelTypesToCombustivel(vehicle.supportedFuels),
      'odometro': vehicle.currentOdometer.toInt(),
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formConfig.title),
        actions: [
          if (widget.onCancel != null)
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancelar'),
            ),
        ],
      ),
      body: _buildForm(),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_formConfig.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                _formConfig.subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          
          ..._buildFormFields(),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = _formConfig.buildFields();
    final widgets = <Widget>[];
    
    for (final fieldConfig in fields) {
      final widget = _createFieldWidget(fieldConfig);
      widgets.add(widget);
      widgets.add(const SizedBox(height: 16.0));
    }
    
    return widgets;
  }

  Widget _createFieldWidget(FieldConfig config) {
    // Create field widget based on type using factory
    Widget fieldWidget;
    
    switch (config.fieldType) {
      case 'text':
        fieldWidget = _fieldFactory.createTextField(config as TextFieldConfig);
        break;
      case 'number':
        fieldWidget = _fieldFactory.createNumberField(config as NumberFieldConfig);
        break;
      case 'dropdown':
        fieldWidget = _fieldFactory.createDropdownField(config as DropdownFieldConfig);
        break;
      case 'date':
        fieldWidget = _fieldFactory.createDateField(config as DateFieldConfig);
        break;
      case 'time':
        fieldWidget = _fieldFactory.createTimeField(config as TimeFieldConfig);
        break;
      case 'switch':
        fieldWidget = _fieldFactory.createSwitchField(config as SwitchFieldConfig);
        break;
      case 'checkbox':
        fieldWidget = _fieldFactory.createCheckboxField(config as CheckboxFieldConfig);
        break;
      default:
        fieldWidget = const Text('Unsupported field type');
    }
    
    // Wrap with change listener to update field values
    return _wrapWithChangeListener(fieldWidget, config);
  }

  Widget _wrapWithChangeListener(Widget fieldWidget, FieldConfig config) {
    // For now, return the widget as-is
    // In a full implementation, this would wrap the widget to capture value changes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              config.label!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        fieldWidget,
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Text('Salvar Veículo'),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Transform field values to entity
      final vehicle = _formConfig.transformDataForValidation(_fieldValues);
      if (vehicle == null) {
        throw Exception('Dados do formulário inválidos');
      }

      // Submit through form config
      final result = await _formConfig.submitForm(vehicle);
      
      if (result.isSuccess && result.data != null) {
        // Success - call callback if provided
        widget.onSubmit?.call(result.data!);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veículo salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Handle submission error
        setState(() {
          _errorMessage = result.errorMessage ?? 'Erro desconhecido ao salvar veículo';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao salvar veículo: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }
}

/// State manager for form following Command pattern
class FormStateManager<T> {
  void dispose() {
    // Cleanup resources if needed
  }
}