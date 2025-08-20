// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../models/pre_register_model.dart';
import '../services/notification_service.dart';

class PreRegisterController extends ChangeNotifier {
  // Services
  late final NotificationService _notificationService;

  // State
  PreRegisterForm _form = const PreRegisterForm();
  List<PreRegisterData> _registrations = [];
  PreRegisterStatistics _statistics = const PreRegisterStatistics();
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isDialogOpen = false;
  AppPlatform? _selectedPlatform;

  // Getters
  PreRegisterForm get form => _form;
  List<PreRegisterData> get registrations => _registrations;
  PreRegisterStatistics get statistics => _statistics;
  NotificationPreferences get preferences => _preferences;
  bool get isSubmitting => _isSubmitting;
  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isDialogOpen => _isDialogOpen;
  AppPlatform? get selectedPlatform => _selectedPlatform;

  // Form state getters
  String get name => _form.name;
  String get email => _form.email;
  bool get isFormValid => _form.isValid;
  bool get canSubmit => _form.canSubmit && !_isSubmitting;
  Map<String, String> get formErrors => _form.errors;

  PreRegisterController() {
    _initializeServices();
  }

  void _initializeServices() {
    _notificationService = NotificationService();
  }

  Future<void> initialize() async {
    try {
      await _loadRegistrations();
      await _loadStatistics();
      await _loadPreferences();
    } catch (e) {
      _setError('Erro ao inicializar pré-registro: $e');
    }
  }

  Future<void> _loadRegistrations() async {
    try {
      // In a real implementation, load from storage/API
      _registrations = [];
    } catch (e) {
      debugPrint('Error loading registrations: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      _statistics = PreRegisterRepository.getMockStatistics();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      _preferences = PreRegisterRepository.getDefaultPreferences();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Form management
  void updateName(String name) {
    _form = _form.copyWith(name: name);
    _validateForm();
  }

  void updateEmail(String email) {
    _form = _form.copyWith(email: email);
    _validateForm();
  }

  void selectPlatform(AppPlatform platform) {
    _form = _form.copyWith(selectedPlatform: platform);
    _selectedPlatform = platform;
    _validateForm();
  }

  void _validateForm() {
    _form = PreRegisterRepository.validateAndUpdateForm(_form);
    notifyListeners();
  }

  void clearForm() {
    _form = const PreRegisterForm();
    _selectedPlatform = null;
    _clearMessages();
    notifyListeners();
  }

  // Registration submission
  Future<void> submitRegistration(String name, String email, AppPlatform platform) async {
    if (_isSubmitting) return;

    _setSubmitting(true);
    _clearMessages();

    try {
      // Update form with submitted data
      _form = _form.copyWith(
        name: name,
        email: email,
        selectedPlatform: platform,
      );
      _validateForm();

      if (!_form.isValid) {
        _setError('Por favor, corrija os erros no formulário');
        return;
      }

      // Check if email is already registered
      if (!PreRegisterRepository.canRegisterEmail(email, _registrations)) {
        _setError('Este email já está registrado');
        return;
      }

      // Create registration data
      final registrationData = PreRegisterRepository.createRegistrationData(
        name: name,
        email: email,
        platform: platform,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Add to local list
      _registrations.add(registrationData);

      // Send notification
      await _notificationService.sendRegistrationConfirmation(
        email: email,
        name: name,
        platform: platform,
      );

      // Update statistics
      await _updateStatistics();

      _setSuccess('Obrigado! Você será notificado quando o app for lançado.');
      clearForm();

    } catch (e) {
      _setError('Erro ao registrar: $e');
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> _updateStatistics() async {
    try {
      _statistics = PreRegisterRepository.calculateStatistics(_registrations);
    } catch (e) {
      debugPrint('Error updating statistics: $e');
    }
  }

  // Dialog management
  void showRegistrationDialog(AppPlatform platform) {
    _selectedPlatform = platform;
    _isDialogOpen = true;
    _form = _form.copyWith(selectedPlatform: platform);
    notifyListeners();
  }

  void closeRegistrationDialog() {
    _isDialogOpen = false;
    _selectedPlatform = null;
    clearForm();
    notifyListeners();
  }

  // Platform management
  List<AppPlatform> getAvailablePlatforms() {
    return PreRegisterRepository.getAvailablePlatforms();
  }

  String getPlatformStoreName(AppPlatform platform) {
    return PreRegisterRepository.getPlatformStoreName(platform);
  }

  String getPlatformDisplayName(AppPlatform platform) {
    return PreRegisterRepository.getPlatformDisplayName(platform);
  }

  String? getStoreUrlForPlatform(AppPlatform platform) {
    return PreRegisterRepository.getStoreUrlForPlatform(platform);
  }

  // Registration management
  List<PreRegisterData> getRegistrationsByPlatform(AppPlatform platform) {
    return PreRegisterRepository.filterByPlatform(_registrations, platform);
  }

  List<PreRegisterData> getRegistrationsByStatus(RegistrationStatus status) {
    return PreRegisterRepository.filterByStatus(_registrations, status);
  }

  PreRegisterData? getRegistrationByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      return _registrations.firstWhere((reg) => reg.email == normalizedEmail);
    } catch (e) {
      return null;
    }
  }

  bool isEmailRegistered(String email) {
    return getRegistrationByEmail(email) != null;
  }

  // Statistics and analytics
  int getTotalRegistrations() {
    return _statistics.totalRegistrations;
  }

  int getRegistrationsForPlatform(AppPlatform platform) {
    return _statistics.getRegistrationsForPlatform(platform);
  }

  double getAndroidPercentage() {
    return _statistics.androidPercentage;
  }

  double getIOSPercentage() {
    return _statistics.iosPercentage;
  }

  Map<String, dynamic> getRegistrationStatistics() {
    return {
      'totalRegistrations': _statistics.totalRegistrations,
      'androidRegistrations': getRegistrationsForPlatform(AppPlatform.android),
      'iosRegistrations': getRegistrationsForPlatform(AppPlatform.ios),
      'androidPercentage': getAndroidPercentage(),
      'iosPercentage': getIOSPercentage(),
      'averagePerDay': _statistics.averageRegistrationsPerDay,
      'formIsValid': _form.isValid,
      'isSubmitting': _isSubmitting,
      'hasError': hasError,
      'hasSuccess': hasSuccess,
    };
  }

  // Notification preferences
  void updateNotificationPreferences(NotificationPreferences preferences) {
    _preferences = preferences;
    notifyListeners();
  }

  void toggleEmailNotifications(bool enabled) {
    _preferences = _preferences.copyWith(enableEmailNotifications: enabled);
    notifyListeners();
  }

  void toggleLaunchNotifications(bool enabled) {
    _preferences = _preferences.copyWith(enableLaunchNotification: enabled);
    notifyListeners();
  }

  void toggleUpdatesNotifications(bool enabled) {
    _preferences = _preferences.copyWith(enableUpdatesNotification: enabled);
    notifyListeners();
  }

  void togglePromotionalEmails(bool enabled) {
    _preferences = _preferences.copyWith(enablePromotionalEmails: enabled);
    notifyListeners();
  }

  // Validation helpers
  String? validateName(String name) {
    if (name.trim().isEmpty) return 'Nome é obrigatório';
    if (name.trim().length < 2) return 'Nome deve ter pelo menos 2 caracteres';
    return null;
  }

  String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email é obrigatório';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      return 'Email inválido';
    }
    if (isEmailRegistered(email)) return 'Este email já está registrado';
    return null;
  }

  bool isValidForm() {
    return validateName(_form.name) == null &&
           validateEmail(_form.email) == null &&
           _form.selectedPlatform != null;
  }

  // Bulk operations
  Future<void> notifyAllUsers() async {
    if (_isSubmitting) return;

    _setSubmitting(true);

    try {
      final confirmedRegistrations = getRegistrationsByStatus(RegistrationStatus.confirmed);
      
      for (final registration in confirmedRegistrations) {
        await _notificationService.sendLaunchNotification(
          email: registration.email,
          name: registration.name,
          platform: registration.platform,
        );
        
        // Update status to notified
        final index = _registrations.indexOf(registration);
        if (index != -1) {
          _registrations[index] = registration.copyWith(status: RegistrationStatus.notified);
        }
      }

      await _updateStatistics();
      _setSuccess('Notificações enviadas para ${confirmedRegistrations.length} usuários');

    } catch (e) {
      _setError('Erro ao enviar notificações: $e');
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> exportRegistrations() async {
    try {
      // In a real implementation, export to CSV or other format
      debugPrint('Exporting ${_registrations.length} registrations');
      _setSuccess('Dados exportados com sucesso');
    } catch (e) {
      _setError('Erro ao exportar dados: $e');
    }
  }

  // Refresh and cleanup
  Future<void> refresh() async {
    _clearMessages();
    await initialize();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    debugPrint('PreRegisterController Error: $error');
    notifyListeners();
  }

  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

}
