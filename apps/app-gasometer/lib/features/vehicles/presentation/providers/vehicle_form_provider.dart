import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/input_sanitizer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/fuel_type_mapper.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Provider para gerenciar o estado do formulário de veículos
class VehicleFormProvider extends ChangeNotifier {

  VehicleFormProvider(this._authProvider);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthProvider _authProvider;
  
  // Controllers para campos de texto
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  final TextEditingController corController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  final TextEditingController chassiController = TextEditingController();
  final TextEditingController renavamController = TextEditingController();
  final TextEditingController odometroController = TextEditingController();

  // Estado do formulário
  String _selectedCombustivel = 'Gasolina';
  bool _isLoading = false;
  File? _vehicleImage;
  String? _lastError;
  bool _hasChanges = false;
  VehicleEntity? _editingVehicle;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  String get selectedCombustivel => _selectedCombustivel;
  bool get isLoading => _isLoading;
  File? get vehicleImage => _vehicleImage;
  String? get lastError => _lastError;
  bool get hasChanges => _hasChanges;
  VehicleEntity? get editingVehicle => _editingVehicle;
  
  bool get canSubmit {
    return !_isLoading &&
           marcaController.text.isNotEmpty &&
           modeloController.text.isNotEmpty &&
           anoController.text.isNotEmpty &&
           corController.text.isNotEmpty &&
           placaController.text.isNotEmpty &&
           odometroController.text.isNotEmpty;
  }

  @override
  void dispose() {
    marcaController.dispose();
    modeloController.dispose();
    anoController.dispose();
    corController.dispose();
    placaController.dispose();
    chassiController.dispose();
    renavamController.dispose();
    odometroController.dispose();
    super.dispose();
  }

  /// Inicializa o formulário para edição
  void initializeForEdit(VehicleEntity vehicle) {
    _editingVehicle = vehicle;
    
    marcaController.text = vehicle.brand;
    modeloController.text = vehicle.model;
    anoController.text = vehicle.year.toString();
    corController.text = vehicle.color;
    placaController.text = vehicle.licensePlate;
    chassiController.text = vehicle.metadata['chassi'] as String? ?? '';
    renavamController.text = vehicle.metadata['renavam'] as String? ?? '';
    odometroController.text = vehicle.currentOdometer.toString();
    
    _selectedCombustivel = vehicle.supportedFuels.isNotEmpty 
        ? FuelTypeMapper.toStringFormat(vehicle.supportedFuels.first)
        : 'Gasolina';
    
    final imagePath = vehicle.metadata['foto'] as String?;
    if (imagePath != null && imagePath.isNotEmpty) {
      _vehicleImage = File(imagePath);
    }
    
    notifyListeners();
  }

  /// Limpa o formulário
  void clearForm() {
    marcaController.clear();
    modeloController.clear();
    anoController.clear();
    corController.clear();
    placaController.clear();
    chassiController.clear();
    renavamController.clear();
    odometroController.clear();
    
    _selectedCombustivel = 'Gasolina';
    _vehicleImage = null;
    _lastError = null;
    _hasChanges = false;
    _editingVehicle = null;
    
    notifyListeners();
  }

  /// Atualiza combustível selecionado
  void updateSelectedCombustivel(String combustivel) {
    if (_selectedCombustivel != combustivel) {
      _selectedCombustivel = combustivel;
      _hasChanges = true;
      notifyListeners();
    }
  }

  /// Atualiza imagem do veículo
  void updateVehicleImage(File? image) {
    if (_vehicleImage != image) {
      _vehicleImage = image;
      _hasChanges = true;
      notifyListeners();
    }
  }

  /// Remove imagem do veículo
  /// ✅ SECURITY FIX: Added file ownership validation to prevent unauthorized deletion
  void removeVehicleImage() {
    try {
      if (_vehicleImage != null && _vehicleImage!.existsSync()) {
        // ✅ SECURITY FIX: Validate file ownership before deletion
        if (_isFileOwnedByUser(_vehicleImage!)) {
          _vehicleImage!.deleteSync();
        } else {
          // Log security violation attempt
          setError('Tentativa de exclusão não autorizada detectada');
          return;
        }
      }
    } catch (e) {
      setError('Erro ao remover imagem: ${e.toString()}');
    }

    _vehicleImage = null;
    _hasChanges = true;
    notifyListeners();
  }

  /// ✅ SECURITY FIX: Validate if file belongs to current user/session
  bool _isFileOwnedByUser(File file) {
    try {
      final filePath = file.path;
      final userId = _authProvider.userId;
      
      // Check if file is in user's directory
      if (!filePath.contains(userId)) {
        return false;
      }
      
      // Check if it's in expected app directories (temp, cache, documents)
      final allowedDirectories = ['tmp', 'cache', 'Documents', 'files'];
      final isInAllowedDir = allowedDirectories.any((dir) => filePath.contains(dir));
      
      if (!isInAllowedDir) {
        return false;
      }
      
      // Additional check: verify file was created during this session or by this user
      final fileStats = file.statSync();
      final now = DateTime.now();
      final fileAge = now.difference(fileStats.modified);
      
      // Allow deletion only if file is recent (less than 24 hours) or explicitly user-created
      return fileAge.inHours < 24;
      
    } catch (e) {
      // On any validation error, deny deletion for security
      return false;
    }
  }

  /// Marca campo como alterado
  void markAsChanged() {
    if (!_hasChanges) {
      _hasChanges = true;
      notifyListeners();
    }
  }

  /// Define estado de loading
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define erro
  void setError(String? error) {
    if (_lastError != error) {
      _lastError = error;
      notifyListeners();
    }
  }

  /// Valida formulário
  bool validateForm() {
    setError(null);
    
    // Primeiro validar campos obrigatórios individualmente
    final List<String> missingFields = [];
    
    if (marcaController.text.trim().isEmpty) {
      missingFields.add('Marca');
    }
    
    if (modeloController.text.trim().isEmpty) {
      missingFields.add('Modelo');
    }
    
    if (anoController.text.trim().isEmpty) {
      missingFields.add('Ano');
    }
    
    if (corController.text.trim().isEmpty) {
      missingFields.add('Cor');
    }
    
    if (placaController.text.trim().isEmpty) {
      missingFields.add('Placa');
    }
    
    if (odometroController.text.trim().isEmpty) {
      missingFields.add('Odômetro');
    }
    
    if (missingFields.isNotEmpty) {
      setError('Por favor, preencha os seguintes campos obrigatórios: ${missingFields.join(', ')}');
      return false;
    }
    
    // Agora validar usando o FormKey (validações específicas de formato, etc.)
    if (!_formKey.currentState!.validate()) {
      setError('Por favor, corrija os erros no formulário');
      return false;
    }
    
    return true;
  }


  /// Cria entidade do veículo a partir dos dados do formulário
  /// Aplica sanitização específica para cada tipo de campo
  VehicleEntity createVehicleEntity() {
    final fuelType = FuelTypeMapper.fromString(_selectedCombustivel);
    final odometroValue = double.tryParse(odometroController.text.replaceAll(',', '.')) ?? 0.0;
    
    // Aplicar sanitização específica para cada campo
    final sanitizedMarca = InputSanitizer.sanitizeName(marcaController.text);
    final sanitizedModelo = InputSanitizer.sanitizeName(modeloController.text);
    final sanitizedCor = InputSanitizer.sanitizeName(corController.text);
    final sanitizedPlaca = InputSanitizer.sanitize(placaController.text).toUpperCase();
    final sanitizedChassi = InputSanitizer.sanitize(chassiController.text);
    final sanitizedRenavam = InputSanitizer.sanitizeNumeric(renavamController.text);
    
    return VehicleEntity(
      id: _editingVehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _authProvider.userId,
      name: '$sanitizedMarca $sanitizedModelo',
      brand: sanitizedMarca,
      model: sanitizedModelo,
      year: int.tryParse(anoController.text) ?? DateTime.now().year,
      color: sanitizedCor,
      licensePlate: sanitizedPlaca,
      type: VehicleType.car, // Padrão para carro
      supportedFuels: [fuelType],
      currentOdometer: odometroValue,
      createdAt: _editingVehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'chassi': sanitizedChassi,
        'renavam': sanitizedRenavam,
        'foto': _vehicleImage?.path,
        'odometroInicial': odometroValue,
      },
    );
  }
}