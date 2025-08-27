import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/odometer_entity.dart';
import '../constants/odometer_constants.dart';
import '../providers/odometer_form_provider.dart';
import '../providers/odometer_provider.dart';
import '../services/odometer_validation_service.dart';

class AddOdometerPage extends StatefulWidget {
  final OdometerEntity? odometer;

  const AddOdometerPage({super.key, this.odometer});

  @override
  State<AddOdometerPage> createState() => _AddOdometerPageState();
}

class _AddOdometerPageState extends State<AddOdometerPage> {
  final _formKey = GlobalKey<FormState>();
  late OdometerFormProvider _formProvider;
  late OdometerValidationService _validationService;
  
  // Controllers for form fields
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialization will be done in didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeProviders();
      _setupFormControllers();
      _populateFields();
      _isInitialized = true;
    }
  }
  
  void _initializeProviders() {
    _formProvider = Provider.of<OdometerFormProvider>(context, listen: false);
    final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
    _validationService = OdometerValidationService(vehiclesProvider);
    
    // Initialize form data
    if (widget.odometer != null) {
      _formProvider.initializeFromOdometer(widget.odometer!);
    } else {
      // Get selected vehicle ID from vehicles provider
      // Selected vehicle from provider pending
      // final selectedVehicle = vehiclesProvider.selectedVehicle;
      // For now, initialize with empty vehicle ID
      const selectedVehicleId = '';
      if (selectedVehicleId.isNotEmpty) {
        _formProvider.initializeForNew(selectedVehicleId);
        // Vehicle data loading implementation pending
      }
    }
  }
  
  void _setupFormControllers() {
    try {
      // Setup listeners for reactive updates
      _formProvider.addListener(_updateControllersFromProvider);
      
      // Setup controllers with initial values
      _updateControllersFromProvider();
      
      // Add listeners for user input
      _odometerController.addListener(_onOdometerChanged);
      _descriptionController.addListener(_onDescriptionChanged);
    } catch (e) {
      // Em caso de erro, limpar listeners já adicionados
      _formProvider.removeListener(_updateControllersFromProvider);
      _odometerController.removeListener(_onOdometerChanged);
      _descriptionController.removeListener(_onDescriptionChanged);
      debugPrint('Error setting up form controllers: $e');
      rethrow;
    }
  }
  
  void _updateControllersFromProvider() {
    // Update odometer controller
    final formattedOdometer = _formProvider.formattedOdometer;
    if (_odometerController.text != formattedOdometer) {
      _odometerController.text = formattedOdometer;
    }
    
    // Update description controller
    if (_descriptionController.text != _formProvider.description) {
      _descriptionController.text = _formProvider.description;
    }
    
    // Trigger UI update
    if (mounted) setState(() {});
  }
  
  void _onOdometerChanged() {
    final text = _odometerController.text;
    if (text != _formProvider.formattedOdometer) {
      _formProvider.setOdometerFromString(text);
    }
  }
  
  void _onDescriptionChanged() {
    final text = _descriptionController.text;
    if (text != _formProvider.description) {
      _formProvider.setDescription(text);
    }
  }

  void _populateFields() {
    // Initial population is handled by the provider setup
    // Controllers are updated via _updateControllersFromProvider
  }


  @override
  void dispose() {
    _formProvider.removeListener(_updateControllersFromProvider);
    _odometerController.removeListener(_onOdometerChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return FormDialog(
      title: 'Odômetro',
      subtitle: 'Gerencie seus registros de quilometr...',
      headerIcon: Icons.speed,
      isLoading: context.watch<OdometerFormProvider>().isLoading,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitForm,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        final title = formProvider.isEditing 
            ? OdometerConstants.dialogMessages['tituloEdicao']!
            : OdometerConstants.dialogMessages['tituloNovo']!;
            
        return Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.event_note,
      children: [
        Column(
          children: [
            _buildOdometerField(),
            const SizedBox(height: 12),
            _buildRegistrationTypeField(),
            const SizedBox(height: 12),
            _buildDateTimeField(),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      children: [
        Column(
          children: [
            _buildDescriptionField(),
          ],
        ),
      ],
    );
  }


  // New specialized field builders
  Widget _buildOdometerField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return TextFormField(
          controller: _odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['odometro'],
            hintText: OdometerConstants.fieldHints['odometro'],
            suffixText: OdometerConstants.units['odometro'],
            suffixIcon: formProvider.odometerValue > 0
                ? IconButton(
                    icon: Icon(OdometerConstants.sectionIcons['clear']),
                    onPressed: () => formProvider.clearOdometer(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          inputFormatters: _getOdometroFormatters(),
          validator: formProvider.validateOdometer,
          onChanged: (value) {
            // Controller listener will handle the update
          },
        );
      },
    );
  }
  
  Widget _buildRegistrationTypeField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return DropdownButtonFormField<OdometerType>(
          value: formProvider.registrationType,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['tipoRegistro'],
            hintText: OdometerConstants.fieldHints['tipoRegistro'],
            prefixIcon: Icon(OdometerConstants.sectionIcons['tipoRegistro']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          items: OdometerType.allTypes.map((type) {
            return DropdownMenuItem<OdometerType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              formProvider.setRegistrationType(type);
            }
          },
          validator: (value) {
            return value == null ? OdometerConstants.validationMessages['tipoObrigatorio'] : null;
          },
        );
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return TextFormField(
          controller: _descriptionController,
          maxLength: OdometerConstants.maxDescriptionLength,
          maxLines: OdometerConstants.descriptionMaxLines,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['descricao'],
            hintText: OdometerConstants.fieldHints['descricao'],
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          validator: formProvider.validateDescription,
          onChanged: (value) {
            // Controller listener will handle the update
          },
        );
      },
    );
  }
  
  Widget _buildDateTimeField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return InkWell(
          onTap: () => _selectDateTime(formProvider),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: OdometerConstants.fieldLabels['dataHora'],
              suffixIcon: Icon(
                OdometerConstants.sectionIcons['dataHora'],
                size: OdometerConstants.dimensions['calendarIconSize'],
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
                    DateFormat('dd/MM/yyyy').format(formProvider.registrationDate),
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
                    TimeOfDay.fromDateTime(formProvider.registrationDate).format(context),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Formatadores de entrada
  List<TextInputFormatter> _getOdometroFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        var text = newValue.text.replaceAll('.', ',');
        if (text.contains(',')) {
          final parts = text.split(',');
          if (parts.length == 2 && parts[1].length > 2) {
            text = '${parts[0]},${parts[1].substring(0, 2)}';
          }
        }
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }),
    ];
  }


  Future<void> _selectDateTime(OdometerFormProvider formProvider) async {
    // Select date first
    final date = await showDatePicker(
      context: context,
      initialDate: formProvider.registrationDate,
      firstDate: OdometerConstants.minDate,
      lastDate: OdometerConstants.maxDate,
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

    if (date != null) {
      // Then select time
      if (mounted) {
        final currentTime = TimeOfDay.fromDateTime(formProvider.registrationDate);
        final time = await showTimePicker(
          context: context,
          initialTime: currentTime,
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

        if (time != null) {
          // Update provider instead of local state
          formProvider.setDate(date);
          formProvider.setTime(time.hour, time.minute);
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final formProvider = _formProvider;
    final odometerProvider = Provider.of<OdometerProvider>(context, listen: false);

    // Validate form with context
    final validationResult = await _validationService.validateFormWithContext(
      vehicleId: formProvider.vehicleId,
      odometerValue: formProvider.odometerValue,
      registrationDate: formProvider.registrationDate,
      description: formProvider.description,
      type: formProvider.registrationType,
      currentOdometerId: formProvider.isEditing ? formProvider.currentOdometer?.id : null,
    );

    if (!validationResult.isValid) {
      // Show first validation error
      final firstError = validationResult.errors.values.first;
      _showError(OdometerConstants.dialogMessages['erro']!, firstError);
      return;
    }

    // Show warnings if any (but allow to continue)
    if (validationResult.hasWarnings) {
      final shouldContinue = await _showWarningDialog(validationResult.warnings);
      if (!shouldContinue) return;
    }

    formProvider.setIsLoading(true);

    try {
      bool success;
      if (formProvider.isEditing) {
        // Update existing odometer
        final updatedOdometer = formProvider.toOdometerEntity(
          id: formProvider.currentOdometer!.id,
          createdAt: formProvider.currentOdometer!.createdAt,
        );
        success = await odometerProvider.updateOdometer(updatedOdometer);
      } else {
        // Create new odometer
        final newOdometer = formProvider.toOdometerEntity();
        success = await odometerProvider.addOdometer(newOdometer);
      }

      if (success) {
        if (mounted) {
          final successMessage = formProvider.isEditing 
              ? OdometerConstants.successMessages['edicaoSucesso']!
              : OdometerConstants.successMessages['cadastroSucesso']!;
              
          _showSuccess(successMessage);
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          _showError(
            OdometerConstants.dialogMessages['erro']!,
            odometerProvider.error.isNotEmpty 
                ? odometerProvider.error 
                : OdometerConstants.validationMessages['erroGenerico']!,
          );
        }
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        _showError(
          OdometerConstants.dialogMessages['erro']!,
          'Erro inesperado: $e',
        );
      }
    } finally {
      formProvider.setIsLoading(false);
    }
  }
  
  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  Future<bool> _showWarningDialog(Map<String, String> warnings) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foram encontrados os seguintes avisos:'),
              const SizedBox(height: 8),
              ...warnings.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${entry.value}'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Deseja continuar mesmo assim?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(OdometerConstants.dateTimeLabels['cancelar']!),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(OdometerConstants.dateTimeLabels['confirmar']!),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
}