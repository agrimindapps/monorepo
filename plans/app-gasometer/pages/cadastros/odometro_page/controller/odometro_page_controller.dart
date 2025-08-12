// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../../database/20_odometro_model.dart';
import '../../../../database/21_veiculos_model.dart';
import '../../../../repository/veiculos_repository.dart';
import '../models/odometro_page_constants.dart';
import '../models/odometro_page_model.dart';
import '../services/error_handler_service.dart';
import '../services/odometro_event_bus.dart';
import '../services/odometro_format_service.dart';
import '../services/odometro_navigation_service.dart';
import '../services/odometro_page_service.dart';

class OdometroPageController extends GetxController with OdometroEventMixin {
  final _model = OdometroPageModel();

  // Specialized services - dependency injection
  final _errorHandler = Get.put(ErrorHandlerService());
  final _formatService = Get.put(OdometroFormatService());
  final _navigationService = Get.put(OdometroNavigationService());
  final _pageService = Get.put(OdometroPageService());

  // Remove direct dependency on OdometroListController - use event bus instead

  // Getters for model properties - using reactive getters consistently
  OdometroPageModel get model => _model;
  RxMap<DateTime, List<OdometroCar>> get odometros => _model.odometros;
  RxBool get isLoading => _model.isLoading;
  RxBool get showHeader => _model.showHeader;
  RxInt get currentCarouselIndex => _model.currentCarouselIndex;
  RxString get error => _model.error;
  RxList<DateTime> get monthsList => _model.monthsList;
  Rx<DateTime?> get selectedMonth => _model.selectedMonth;
  CarouselSliderController get carouselController => _model.carouselController;

  // Computed properties - reactive
  bool get hasError => _model.hasError;
  bool get hasData => _model.hasData;

  // Vehicle selection - reactive variables
  final RxString _selectedVehicleId = ''.obs;
  final RxBool _hasSelectedVehicle = false.obs;
  final Rx<VeiculoCar?> _selectedVehicle = Rx<VeiculoCar?>(null);

  RxString get selectedVehicleId => _selectedVehicleId;
  RxBool get hasSelectedVehicle => _hasSelectedVehicle;
  Rx<VeiculoCar?> get selectedVehicle => _selectedVehicle;

  // Collapsing header states
  final RxBool isHeaderCollapsed = false.obs;
  final RxDouble scrollProgress = 0.0.obs; // Progresso do scroll de 0.0 a 1.0

  // Error handling
  ErrorHandlerService get errorHandler => _errorHandler;
  bool get hasActiveError => _errorHandler.hasActiveError;
  AppError? get currentError => _errorHandler.currentError;

  // Service accessors for UI layer
  OdometroFormatService get formatService => _formatService;
  OdometroNavigationService get navigationService => _navigationService;
  OdometroPageService get pageService => _pageService;

  @override
  void onInit() {
    super.onInit();

    // Subscribe to events from other controllers
    subscribeToEvent(OdometroEventType.dataLoaded, _handleDataLoaded);
    subscribeToEvent(OdometroEventType.vehicleChanged, _handleVehicleChanged);
    subscribeToEvent(OdometroEventType.errorOccurred, _handleExternalError);

    _initializeSelectedVehicle();
    loadData();
  }

  // Event handlers for decoupled communication
  void _handleDataLoaded(OdometroEvent event) {
    if (event.data is Map<DateTime, List<OdometroCar>>) {
      _model.setOdometros(event.data);
      final months = _pageService.getMonthsList();
      _model.setMonthsList(months);

      if (months.isNotEmpty && _model.selectedMonth.value == null) {
        _model.setSelectedMonth(months.first);
      }
    }
  }

  void _handleVehicleChanged(OdometroEvent event) {
    _initializeSelectedVehicle();
    loadData();
  }

  void _handleExternalError(OdometroEvent event) {
    if (event.data is String) {
      _errorHandler.handleError(event.data,
          context: 'external controller error');
    }
  }

  // Initialize selected vehicle from repository with error handling
  Future<void> _initializeSelectedVehicle() async {
    try {
      await ErrorHandlerService.withRetry(() async {
        final repository = Get.find<VeiculosRepository>();
        final selectedId = await repository.getSelectedVeiculoId();
        _selectedVehicleId.value = selectedId;
        _hasSelectedVehicle.value = selectedId.isNotEmpty;

        // Load vehicle data
        if (selectedId.isNotEmpty) {
          await _loadSelectedVehicleData();
        }
      });
    } catch (e, stackTrace) {
      _errorHandler.handleError(e,
          stackTrace: stackTrace, context: 'initializing selected vehicle');
      // Set safe defaults if initialization fails
      _selectedVehicleId.value = '';
      _hasSelectedVehicle.value = false;
      _selectedVehicle.value = null;
    }
  }

  // Update selected vehicle
  void updateSelectedVehicle(String vehicleId) {
    _selectedVehicleId.value = vehicleId;
    _hasSelectedVehicle.value = vehicleId.isNotEmpty;
  }

  // Load odometer data using service layer with event communication
  Future<void> loadData() async {
    _model.setIsLoading(true);
    _model.clearError();
    _errorHandler.clearError();

    // Emit loading started event
    emitEvent(OdometroEventType.loadingStarted);

    try {
      // Add small delay to show skeleton loading
      await Future.delayed(const Duration(milliseconds: 500));

      final data = await _pageService.loadOdometroData();
      _model.setOdometros(data);

      // Update months list using service
      final months = _pageService.getMonthsList();
      _model.setMonthsList(months);

      // Set initial selected month if available
      if (months.isNotEmpty && _model.selectedMonth.value == null) {
        _model.setSelectedMonth(months.first);
        // Emit month selection event instead of direct controller call
        emitEvent(OdometroEventType.monthSelected, data: months.first);
      }

      // Emit data loaded event
      emitEvent(OdometroEventType.dataLoaded, data: data);
    } catch (e, stackTrace) {
      final appError = _errorHandler.handleError(e,
          stackTrace: stackTrace, context: 'loading odometer data');
      _model.setError(appError.userMessage);

      // Emit error event
      emitEvent(OdometroEventType.errorOccurred, data: appError.userMessage);
    } finally {
      _model.setIsLoading(false);

      // Emit loading completed event
      emitEvent(OdometroEventType.loadingCompleted);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  // Handle vehicle selection change with event communication
  void onVeiculoSelected() {
    // Atualiza o estado do veículo selecionado
    _initializeSelectedVehicle().catchError((e, stackTrace) {
      _errorHandler.handleError(e,
          stackTrace: stackTrace, context: 'vehicle selection change');
    });

    // Emit vehicle changed event instead of direct method call
    emitEvent(OdometroEventType.vehicleChanged);

    // Carrega os dados
    loadData();
  }

  // Load selected vehicle data
  Future<void> _loadSelectedVehicleData() async {
    if (_hasSelectedVehicle.value && _selectedVehicleId.value.isNotEmpty) {
      try {
        final repository = Get.find<VeiculosRepository>();
        final vehicle =
            await repository.getVeiculoById(_selectedVehicleId.value);
        _selectedVehicle.value = vehicle;
        debugPrint('Veículo carregado: ${vehicle?.marca} ${vehicle?.modelo}');
      } catch (e) {
        debugPrint('Erro ao carregar dados do veículo: $e');
        _selectedVehicle.value = null;
      }
    } else {
      _selectedVehicle.value = null;
    }
  }

  // Get selected vehicle name for collapsed header
  String getSelectedVehicleName() {
    if (!_hasSelectedVehicle.value || _selectedVehicle.value == null) {
      return 'Nenhum veículo';
    }

    final vehicle = _selectedVehicle.value!;
    return '${vehicle.marca} ${vehicle.modelo} ${vehicle.ano}';
  }

  // Get current month name for collapsed header
  String getCurrentMonthName() {
    if (selectedMonth.value != null) {
      return formatMonth(selectedMonth.value!);
    }

    // Se não há mês selecionado, usar o mês atual
    final now = DateTime.now();
    return formatMonth(now);
  }

  // Set header collapsed state
  void setHeaderCollapsed(bool collapsed) {
    isHeaderCollapsed.value = collapsed;
  }

  void updateScrollProgress(double scrollOffset) {
    // Calcula o progresso baseado no offset do scroll
    // 0.0 quando scroll = 0, 1.0 quando scroll >= 100
    const maxScrollForCollapse = 100.0;
    scrollProgress.value =
        (scrollOffset / maxScrollForCollapse).clamp(0.0, 1.0);

    // Atualiza o estado collapsed baseado no progresso
    final shouldCollapse = scrollProgress.value > 0.2; // 20% do progresso
    if (isHeaderCollapsed.value != shouldCollapse) {
      setHeaderCollapsed(shouldCollapse);
    }
  }

  // Header toggle
  void toggleHeader() {
    _model.toggleHeader();
  }

  // Navigation methods - delegating to navigation service
  void animateToPage(int index) {
    _navigationService.animateToPage(index, _model);
  }

  void setCarouselIndex(int index) {
    _navigationService.setCarouselIndex(index, _model);

    // Emit month selection event instead of direct controller call
    if (index < monthsList.length) {
      emitEvent(OdometroEventType.monthSelected, data: monthsList[index]);
    }
  }

  // Data queries - delegating to service layer
  List<OdometroCar> getOdometrosForMonth(DateTime month) {
    return _pageService.getOdometrosForMonth(month, _model.odometros);
  }

  bool hasDataForMonth(DateTime month) {
    return _pageService.hasDataForMonth(month, _model.odometros);
  }

  double calculateDifference(List<OdometroCar> odometros, int index) {
    return _pageService.calculateDifference(odometros, index);
  }

  // Statistics - delegating to service layer
  Map<String, dynamic> getStatisticsForMonth(DateTime month) {
    return _pageService.getStatisticsForMonth(month, _model.odometros);
  }

  Map<String, dynamic> getOverallStatistics() {
    return _pageService.getOverallStatistics(_model.odometros);
  }

  // Search functionality - delegating to service layer
  List<OdometroCar> searchOdometros(String query) {
    return _pageService.searchOdometros(query, _model.odometros);
  }

  // Formatting methods - delegating to format service
  String formatMonth(DateTime date) {
    return _formatService.formatMonth(date);
  }

  String formatCurrentMonth() {
    return _formatService.formatCurrentMonth();
  }

  String formatDateHeader(DateTime date) {
    return _formatService.formatDateHeader(date);
  }

  // Theme helpers - updated to use ThemeManager
  Color getBackgroundColor(BuildContext context) {
    return ThemeManager().isDark.value
        ? const Color(0xFF1A1A2E)
        : Colors.grey.shade50;
  }

  Color getBorderColor(BuildContext context) {
    return ThemeManager().isDark.value
        ? Colors.grey.shade800
        : Colors.grey.shade200;
  }

  Color getSelectedMonthColor(BuildContext context) {
    return ThemeManager().isDark.value
        ? Colors.grey.shade700
        : Colors.grey.shade200;
  }

  Color getUnselectedMonthColor(BuildContext context) {
    return ThemeManager().isDark.value
        ? Colors.grey.shade800.withValues(alpha: 0.5)
        : Colors.grey.shade100;
  }

  Color getFabBackgroundColor(BuildContext context) {
    if (!hasSelectedVehicle.value) {
      return Colors.grey[400]!;
    }
    return Theme.of(context).floatingActionButtonTheme.backgroundColor ??
        Theme.of(context).primaryColor;
  }

  // UI state helpers
  bool shouldShowAnalyticsButton() {
    return hasData;
  }

  Widget getAnalyticsIcon() {
    return const Icon(
      Icons.analytics,
      size: 20,
    );
  }

  // Responsive helpers
  bool isTablet(BuildContext context) {
    return OdometroPageConstants.isTablet(MediaQuery.of(context).size.width);
  }

  Size getPreferredSize(BuildContext context) {
    return const Size.fromHeight(OdometroPageConstants.headerHeight);
  }

  double getCarouselHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
        OdometroPageConstants.carouselHeight;
  }

  double getNoDataHeight(BuildContext context) {
    return OdometroPageConstants.getNoDataHeight(
        MediaQuery.of(context).size.height);
  }

  // Navigation and interaction
  Future<void> handleOdometroTap(OdometroCar odometro,
      {required Future<bool?> Function() onEdit}) async {
    final result = await onEdit();
    if (result == true) {
      await refreshData();
    }
  }

  Future<void> handleAddOdometro(
      {required Future<bool?> Function() onCreate}) async {
    if (!hasSelectedVehicle.value) return;

    final result = await onCreate();
    if (result == true) {
      await refreshData();
    }
  }

  // Enhanced error handling methods
  void handleError(String error) {
    _errorHandler.handleError(error, context: 'manual error handling');
    _model.setError(error);
  }

  void clearError() {
    _errorHandler.clearError();
    _model.clearError();
  }

  /// Get detailed error information for user display
  String getErrorDetailsForUser() {
    final error = _errorHandler.currentError;
    if (error == null) return '';

    final suggestions = error.suggestions.isNotEmpty
        ? '\n\nSugestões:\n${error.suggestions.map((s) => '• $s').join('\n')}'
        : '';

    return '${error.userMessage}$suggestions';
  }

  /// Check if current error can be retried
  bool canRetryCurrentError() {
    return _errorHandler.currentError?.canRetry ?? false;
  }

  /// Retry the last failed operation
  Future<void> retryLastOperation() async {
    if (canRetryCurrentError()) {
      _errorHandler.clearError();
      await loadData();
    }
  }

  // Private helper methods - removed, moved to format service

  // Lifecycle methods
  void resetData() {
    _model.reset();
  }

  @override
  void onClose() {
    // Dispose reactive variables to prevent memory leaks
    _selectedVehicleId.close();
    _hasSelectedVehicle.close();

    // Reset model state
    resetData();
    super.onClose();
  }
}
