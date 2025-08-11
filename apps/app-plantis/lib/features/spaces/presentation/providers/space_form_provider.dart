import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../domain/entities/space.dart';
import '../../domain/usecases/get_spaces_usecase.dart';
import '../../domain/usecases/add_space_usecase.dart';
import '../../domain/usecases/update_space_usecase.dart';

class SpaceFormProvider extends ChangeNotifier {
  final GetSpaceByIdUseCase getSpaceByIdUseCase;
  final AddSpaceUseCase addSpaceUseCase;
  final UpdateSpaceUseCase updateSpaceUseCase;

  SpaceFormProvider({
    required this.getSpaceByIdUseCase,
    required this.addSpaceUseCase,
    required this.updateSpaceUseCase,
  });

  // Form state
  Space? _originalSpace;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;

  // Form fields
  String _name = '';
  String _description = '';
  SpaceType _type = SpaceType.room;
  String? _imageBase64;

  // Space config fields
  double? _temperature;
  double? _humidity;
  String? _lightLevel;
  bool? _hasDirectSunlight;
  bool? _hasAirConditioning;
  String? _ventilation;
  int? _maxPlants;

  // Getters
  Space? get originalSpace => _originalSpace;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEditMode => _originalSpace != null;

  // Form field getters
  String get name => _name;
  String get description => _description;
  SpaceType get type => _type;
  String? get imageBase64 => _imageBase64;

  // Config getters
  double? get temperature => _temperature;
  double? get humidity => _humidity;
  String? get lightLevel => _lightLevel;
  bool? get hasDirectSunlight => _hasDirectSunlight;
  bool? get hasAirConditioning => _hasAirConditioning;
  String? get ventilation => _ventilation;
  int? get maxPlants => _maxPlants;

  // Form validation
  bool get isValid => _name.trim().isNotEmpty;
  
  Map<String, String> get fieldErrors {
    final errors = <String, String>{};
    
    if (_name.trim().isEmpty) {
      errors['name'] = 'Nome é obrigatório';
    }
    
    if (_name.trim().length < 2) {
      errors['name'] = 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (_name.trim().length > 50) {
      errors['name'] = 'Nome não pode ter mais de 50 caracteres';
    }
    
    if (_description.trim().length > 200) {
      errors['description'] = 'Descrição não pode ter mais de 200 caracteres';
    }
    
    if (_maxPlants != null && _maxPlants! <= 0) {
      errors['maxPlants'] = 'Número máximo de plantas deve ser maior que 0';
    }
    
    if (_temperature != null && (_temperature! < -50 || _temperature! > 60)) {
      errors['temperature'] = 'Temperatura deve estar entre -50°C e 60°C';
    }
    
    if (_humidity != null && (_humidity! < 0 || _humidity! > 100)) {
      errors['humidity'] = 'Umidade deve estar entre 0% e 100%';
    }
    
    return errors;
  }

  // Initialize form for editing
  Future<void> initializeForEdit(String spaceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getSpaceByIdUseCase(spaceId);
    
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _originalSpace = null;
      },
      (space) {
        _originalSpace = space;
        _populateFormFromSpace(space);
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Initialize form for adding new space
  void initializeForAdd() {
    _originalSpace = null;
    _clearForm();
    _errorMessage = null;
    notifyListeners();
  }

  // Form field setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setType(SpaceType value) {
    _type = value;
    notifyListeners();
  }

  void setImageBase64(String? value) {
    _imageBase64 = value;
    notifyListeners();
  }

  // Config setters
  void setTemperature(double? value) {
    _temperature = value;
    notifyListeners();
  }

  void setHumidity(double? value) {
    _humidity = value;
    notifyListeners();
  }

  void setLightLevel(String? value) {
    _lightLevel = value;
    notifyListeners();
  }

  void setHasDirectSunlight(bool? value) {
    _hasDirectSunlight = value;
    notifyListeners();
  }

  void setHasAirConditioning(bool? value) {
    _hasAirConditioning = value;
    notifyListeners();
  }

  void setVentilation(String? value) {
    _ventilation = value;
    notifyListeners();
  }

  void setMaxPlants(int? value) {
    _maxPlants = value;
    notifyListeners();
  }

  // Save space
  Future<bool> saveSpace() async {
    if (!isValid) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = isEditMode
        ? await updateSpaceUseCase(_buildUpdateParams())
        : await addSpaceUseCase(_buildAddParams());
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
      },
      (savedSpace) {
        success = true;
        _originalSpace = savedSpace;
        _populateFormFromSpace(savedSpace);
      },
    );

    _isSaving = false;
    notifyListeners();

    return success;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    if (isEditMode && _originalSpace != null) {
      _populateFormFromSpace(_originalSpace!);
    } else {
      _clearForm();
    }
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _populateFormFromSpace(Space space) {
    _name = space.name;
    _description = space.description ?? '';
    _type = space.type;
    _imageBase64 = space.imageBase64;

    final config = space.config;
    if (config != null) {
      _temperature = config.temperature;
      _humidity = config.humidity;
      _lightLevel = config.lightLevel;
      _hasDirectSunlight = config.hasDirectSunlight;
      _hasAirConditioning = config.hasAirConditioning;
      _ventilation = config.ventilation;
      _maxPlants = config.maxPlants;
    } else {
      _clearConfig();
    }
  }

  void _clearForm() {
    _name = '';
    _description = '';
    _type = SpaceType.room;
    _imageBase64 = null;
    _clearConfig();
  }

  void _clearConfig() {
    _temperature = null;
    _humidity = null;
    _lightLevel = null;
    _hasDirectSunlight = null;
    _hasAirConditioning = null;
    _ventilation = null;
    _maxPlants = null;
  }

  AddSpaceParams _buildAddParams() {
    final config = _hasConfigData()
        ? SpaceConfig(
            temperature: _temperature,
            humidity: _humidity,
            lightLevel: _lightLevel,
            hasDirectSunlight: _hasDirectSunlight,
            hasAirConditioning: _hasAirConditioning,
            ventilation: _ventilation,
            maxPlants: _maxPlants,
          )
        : null;

    return AddSpaceParams(
      name: _name.trim(),
      description: _description.trim().isEmpty ? null : _description.trim(),
      imageBase64: _imageBase64,
      type: _type,
      config: config,
    );
  }

  UpdateSpaceParams _buildUpdateParams() {
    final config = _hasConfigData()
        ? SpaceConfig(
            temperature: _temperature,
            humidity: _humidity,
            lightLevel: _lightLevel,
            hasDirectSunlight: _hasDirectSunlight,
            hasAirConditioning: _hasAirConditioning,
            ventilation: _ventilation,
            maxPlants: _maxPlants,
          )
        : null;

    return UpdateSpaceParams(
      id: _originalSpace!.id,
      name: _name.trim(),
      description: _description.trim().isEmpty ? null : _description.trim(),
      imageBase64: _imageBase64,
      type: _type,
      config: config,
    );
  }

  bool _hasConfigData() {
    return _temperature != null ||
           _humidity != null ||
           _lightLevel != null ||
           _hasDirectSunlight != null ||
           _hasAirConditioning != null ||
           _ventilation != null ||
           _maxPlants != null;
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return 'Espaço não encontrado';
      case NetworkFailure:
        return 'Sem conexão com a internet';
      case ServerFailure:
        return 'Erro no servidor. Tente novamente.';
      case CacheFailure:
        return 'Erro local. Verifique o armazenamento.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}