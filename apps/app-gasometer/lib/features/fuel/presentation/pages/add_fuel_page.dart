import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_form_provider.dart';
import '../providers/fuel_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../widgets/fuel_form_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddFuelPage extends StatefulWidget {
  final String? vehicleId;
  final String? editFuelRecordId;
  
  const AddFuelPage({
    super.key,
    this.vehicleId,
    this.editFuelRecordId,
  });

  @override
  State<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends State<AddFuelPage> {
  late FuelFormProvider _formProvider;
  late FuelProvider _fuelProvider;
  late VehiclesProvider _vehiclesProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() async {
    _vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
    _fuelProvider = Provider.of<FuelProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _formProvider = FuelFormProvider(
      _vehiclesProvider,
      initialVehicleId: widget.vehicleId,
      userId: authProvider.userId,
    );

    try {
      await _formProvider.initialize(
        vehicleId: widget.vehicleId,
        userId: authProvider.userId,
      );
      
      // Se está editando um registro, carregá-lo
      if (widget.editFuelRecordId != null) {
        await _loadFuelRecordForEdit();
      }
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorDialog('Erro ao inicializar formulário: $e');
    }
  }

  Future<void> _loadFuelRecordForEdit() async {
    // TODO: Implementar carregamento do registro para edição
    // final record = _fuelProvider.getFuelRecordById(widget.editFuelRecordId!);
    // if (record != null) {
    //   _formProvider.loadFromFuelRecord(record);
    // }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _formProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.editFuelRecordId != null 
                ? 'Editar Abastecimento' 
                : 'Novo Abastecimento',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _formProvider,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.editFuelRecordId != null 
                ? 'Editar Abastecimento' 
                : 'Novo Abastecimento',
          ),
          actions: [
            Consumer<FuelFormProvider>(builder: (context, formProvider, _) {
              return TextButton(
                onPressed: formProvider.formModel.canSubmit 
                    ? () => _submitForm()
                    : null,
                child: Text(
                  widget.editFuelRecordId != null ? 'Salvar' : 'Adicionar',
                  style: TextStyle(
                    color: formProvider.formModel.canSubmit
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                ),
              );
            }),
          ],
        ),
        body: Consumer<FuelFormProvider>(builder: (context, formProvider, _) {
          if (formProvider.formModel.lastError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorDialog(formProvider.formModel.lastError!);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formProvider.formKey,
              child: FuelFormView(
                formProvider: formProvider,
                onSubmit: _submitForm,
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formProvider.validateForm()) {
      _showErrorDialog('Por favor, corrija os erros no formulário');
      return;
    }

    try {
      final fuelRecord = _formProvider.formModel.toFuelRecord();
      
      bool success;
      if (widget.editFuelRecordId != null) {
        success = await _fuelProvider.updateFuelRecord(fuelRecord);
      } else {
        success = await _fuelProvider.addFuelRecord(fuelRecord);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showErrorDialog(
          _fuelProvider.errorMessage ?? 'Erro ao salvar abastecimento'
        );
      }
    } catch (e) {
      _showErrorDialog('Erro inesperado: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
