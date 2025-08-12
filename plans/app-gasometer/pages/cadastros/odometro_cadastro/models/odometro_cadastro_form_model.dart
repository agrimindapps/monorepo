// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/20_odometro_model.dart';
import '../../../../database/21_veiculos_model.dart';
import '../constants/constants.dart';
import '../services/odometro_formatter.dart';
import '../services/odometro_validator.dart';

class OdometroCadastroFormModel extends GetxController {
  // Static/rarely changing fields (non-reactive)
  String _vehicleId = '';
  VeiculoCar? _vehicle;
  String _registrationType = OdometroConstants.defaultTipoRegistro;

  // Frequently changing fields (reactive)
  final RxInt _registrationDate = DateTime.now().millisecondsSinceEpoch.obs;
  final RxDouble _odometer = 0.0.obs;
  final RxString _description = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters for reactive state (only for frequently changing fields)
  RxInt get registrationDateRx => _registrationDate;
  RxDouble get odometerRx => _odometer;
  RxString get descriptionRx => _description;
  RxBool get isLoadingRx => _isLoading;
  RxString get errorRx => _error;

  // Getters for current values
  String get vehicleId => _vehicleId;
  int get registrationDate => _registrationDate.value;
  double get odometer => _odometer.value;
  String get description => _description.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  VeiculoCar? get vehicle => _vehicle;
  String get registrationType => _registrationType;

  // Computed properties
  DateTime get registrationDateTime =>
      DateTime.fromMillisecondsSinceEpoch(_registrationDate.value);
  bool get hasError => _error.value.isNotEmpty;
  bool get hasVehicle => _vehicle != null;
  String get formattedOdometer =>
      OdometroFormatter.formatOdometer(_odometer.value);

  // Setters
  void setVehicleId(String value) {
    _vehicleId = value;
    update(); // Notify listeners for non-reactive field
  }

  void setRegistrationDate(int value) => _registrationDate.value = value;

  void setRegistrationDateFromDateTime(DateTime dateTime) {
    _registrationDate.value = dateTime.millisecondsSinceEpoch;
  }

  void setOdometer(double value) => _odometer.value = value;

  void setOdometerFromString(String value) {
    _odometer.value = OdometroFormatter.parseOdometer(value);
  }

  void setDescription(String value) => _description.value = value.trim();

  void setRegistrationType(String value) {
    _registrationType = value;
    update(); // Notify listeners for non-reactive field
  }

  void setIsLoading(bool value) => _isLoading.value = value;

  void setError(String value) => _error.value = value;

  void clearError() => _error.value = '';

  void setVehicle(VeiculoCar? value) {
    _vehicle = value;
    update(); // Notify listeners for non-reactive field
  }

  // Date and time manipulation
  void setDate(DateTime date) {
    final currentDateTime = registrationDateTime;
    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      currentDateTime.hour,
      currentDateTime.minute,
    );
    setRegistrationDateFromDateTime(newDateTime);
  }

  void setTime(int hour, int minute) {
    final currentDateTime = registrationDateTime;
    final newDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      hour,
      minute,
    );
    setRegistrationDateFromDateTime(newDateTime);
  }

  // Initialize from existing odometer record
  void initializeFromOdometer(OdometroCar odometer) {
    _vehicleId = odometer.idVeiculo;
    _registrationDate.value = odometer.data;
    _odometer.value = odometer.odometro;
    _description.value = odometer.descricao;
    _registrationType =
        odometer.tipoRegistro ?? OdometroConstants.defaultTipoRegistro;
    update(); // Notify for non-reactive fields
  }

  // Initialize for new odometer record
  void initializeForNew(String vehicleId) {
    _vehicleId = vehicleId;
    _registrationDate.value = DateTime.now().millisecondsSinceEpoch;
    _odometer.value = OdometroConstants.defaultOdometro;
    _description.value = OdometroConstants.defaultDescricao;
    _registrationType = OdometroConstants.defaultTipoRegistro;
    clearError();
    update(); // Notify for non-reactive fields
  }

  // Reset form to initial state
  void resetForm() {
    _vehicleId = '';
    _registrationDate.value = DateTime.now().millisecondsSinceEpoch;
    _odometer.value = OdometroConstants.defaultOdometro;
    _description.value = OdometroConstants.defaultDescricao;
    _registrationType = OdometroConstants.defaultTipoRegistro;
    _isLoading.value = false;
    _error.value = '';
    _vehicle = null;
    update(); // Notify for non-reactive fields
  }

  // Validation methods - delegated to centralized validator
  bool get isValid {
    return OdometroValidator.validateForm(
      idVeiculo: _vehicleId,
      odometro: _odometer.value,
      dataRegistro: registrationDateTime,
      descricao: _description.value,
    );
  }

  String? validateOdometer(String? value) {
    return OdometroValidator.validateOdometer(value);
  }

  String? validateDescription(String? value) {
    return OdometroValidator.validateDescription(value);
  }

  bool validateDate() {
    return OdometroValidator.validateDate(registrationDateTime);
  }

  /// Comprehensive validation for form submission
  Map<String, dynamic> validateForSubmission() {
    return OdometroValidator.validateForSubmission(
      idVeiculo: _vehicleId,
      odometerText: _odometer.value.toString(),
      dataRegistro: registrationDateTime,
      descricao: _description.value,
    );
  }

  // Create OdometroCar object from form data
  OdometroCar toOdometroCar({
    String? id,
    int? createdAt,
  }) {
    return OdometroCar(
      id: id ?? '',
      createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      idVeiculo: _vehicleId,
      data: _registrationDate.value,
      odometro: _odometer.value,
      descricao: _description.value,
      tipoRegistro: _registrationType,
    );
  }

  // Get form data as Map for debugging or serialization
  Map<String, dynamic> toMap() {
    return {
      'idVeiculo': _vehicleId,
      'dataRegistro': _registrationDate.value,
      'odometro': _odometer.value,
      'descricao': _description.value,
      'tipoRegistro': _registrationType,
      'isLoading': _isLoading.value,
      'error': _error.value,
      'hasVehicle': hasVehicle,
    };
  }

  // Load data from Map
  void fromMap(Map<String, dynamic> map) {
    _vehicleId = map['idVeiculo'] ?? '';
    _registrationDate.value =
        map['dataRegistro'] ?? DateTime.now().millisecondsSinceEpoch;
    _odometer.value =
        map['odometro']?.toDouble() ?? OdometroConstants.defaultOdometro;
    _description.value =
        map['descricao']?.toString() ?? OdometroConstants.defaultDescricao;
    _registrationType = map['tipoRegistro']?.toString() ??
        OdometroConstants.defaultTipoRegistro;
    _isLoading.value = map['isLoading'] ?? false;
    _error.value = map['error'] ?? '';
    update(); // Notify for non-reactive fields
  }
}
