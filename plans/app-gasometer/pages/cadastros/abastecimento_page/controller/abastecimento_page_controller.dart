// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/23_abastecimento_model.dart';
import '../../../../repository/abastecimentos_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../../../../services/logging_service.dart';

class AbastecimentoPageController extends GetxController {
  final _repository = AbastecimentosRepository();
  final _veiculosRepository = VeiculosRepository();
  final _logger = LoggingService.instance;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<DateTime, List<AbastecimentoCar>> abastecimentosAgrupados =
      RxMap<DateTime, List<AbastecimentoCar>>();
  final Rx<DateTime?> selectedMonth = Rx<DateTime?>(null);
  final Rx<VeiculoCar?> selectedVehicle = Rx<VeiculoCar?>(null);

  // UI Controls for carousel and header
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final RxBool showHeader = true.obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isHeaderCollapsed = false.obs;
  final RxDouble scrollProgress = 0.0.obs; // Progresso do scroll de 0.0 a 1.0

  String get selectedVeiculoId => _veiculosRepository.selectedVeiculoId;
  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _logger.controller('AbastecimentoPageController', 'onInit');
    _initializeSelectedVehicle();
  }

  Future<void> _initializeSelectedVehicle() async {
    _logger.controller('AbastecimentoPageController', '_initializeSelectedVehicle');
    await _veiculosRepository.getSelectedVeiculoId();
    _logger.debug('Vehicle loaded: ${_veiculosRepository.selectedVeiculoId}', tag: 'ABAST');
    _logger.debug('HasSelectedVehicle: $hasSelectedVehicle', tag: 'ABAST');

    // Carregar dados do veículo selecionado
    await _loadSelectedVehicleData();
    carregarAbastecimentos();
  }

  Future<void> _loadSelectedVehicleData() async {
    if (hasSelectedVehicle) {
      try {
        final vehicle =
            await _veiculosRepository.getVeiculoById(selectedVeiculoId);
        selectedVehicle.value = vehicle;
        _logger.debug('Vehicle data loaded: ${vehicle?.marca} ${vehicle?.modelo}', tag: 'ABAST');
      } catch (e) {
        _logger.error('Failed to load vehicle data', tag: 'ABAST', error: e);
        selectedVehicle.value = null;
      }
    } else {
      selectedVehicle.value = null;
    }
  }

  void onVeiculoSelected() async {
    _logger.controller('AbastecimentoPageController', 'onVeiculoSelected');
    await _veiculosRepository.getSelectedVeiculoId();
    _logger.debug('New vehicle ID: $selectedVeiculoId', tag: 'ABAST');
    _logger.debug('HasSelectedVehicle: $hasSelectedVehicle', tag: 'ABAST');

    // Carregar dados do novo veículo selecionado
    await _loadSelectedVehicleData();
    carregarAbastecimentos();
  }

  Future<void> carregarAbastecimentos() async {
    try {
      isLoading.value = true;
      error.value = '';

      _logger.controller('AbastecimentoPageController', 'carregarAbastecimentos');
      _logger.debug('Selected vehicle ID: $selectedVeiculoId', tag: 'ABAST');
      _logger.debug('Has selected vehicle: $hasSelectedVehicle', tag: 'ABAST');

      // Small delay for skeleton loading UX
      await Future.delayed(const Duration(milliseconds: 500));

      final grouped =
          await _repository.getAbastecimentosAgrupados(selectedVeiculoId);

      _logger.debug('Grouped data received: ${grouped.length} groups', tag: 'ABAST');
      for (var entry in grouped.entries) {
        _logger.debug('Month: ${entry.key} - ${entry.value.length} records', tag: 'ABAST');
      }

      abastecimentosAgrupados.value = grouped;
      _logger.debug('abastecimentosAgrupados.isEmpty: ${abastecimentosAgrupados.isEmpty}', tag: 'ABAST');
    } catch (e) {
      error.value = 'Erro ao carregar abastecimentos: $e';
      _logger.error('Failed to load abastecimentos', tag: 'ABAST', error: e, stackTrace: StackTrace.current);
    } finally {
      isLoading.value = false;
      _logger.debug('Loading finished. isLoading: ${isLoading.value}', tag: 'ABAST');
    }
  }

  Future<Map<String, Map<String, double>>>
      getAbastecimentosEstatisticas() async {
    try {
      return await _repository.getAbastecimentosEstatisticas(selectedVeiculoId);
    } catch (e) {
      _logger.error('Failed to get statistics', tag: 'ABAST', error: e);
      return {};
    }
  }

  List<DateTime> generateMonthsList(
      Map<DateTime, List<AbastecimentoCar>> groupedAbastecimentos) {
    try {
      final dates = groupedAbastecimentos.keys.toList();
      if (dates.isEmpty) return [];

      dates.sort((a, b) => b.compareTo(a));
      return dates;
    } catch (e) {
      _logger.error('Failed to generate months list', tag: 'ABAST', error: e);
      return [];
    }
  }

  Map<String, dynamic> calcularMetricasMensais(
      DateTime date, List<AbastecimentoCar> abastecimentosDoMes) {
    try {
      if (abastecimentosDoMes.isEmpty) {
        return {
          'totalGastoMes': 0.0,
          'totalLitrosMes': 0.0,
          'precoMedioLitro': 0.0,
          'mediaConsumoMes': 0.0,
        };
      }

      final totalGastoMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.valorTotal);
      final totalLitrosMes =
          abastecimentosDoMes.fold(0.0, (sum, item) => sum + item.litros);
      final precoMedioLitro =
          totalLitrosMes > 0 ? totalGastoMes / totalLitrosMes : 0.0;

      double mediaConsumoMes = 0.0;
      if (abastecimentosDoMes.length > 1) {
        final kmInicial = abastecimentosDoMes.last.odometro;
        final kmFinal = abastecimentosDoMes.first.odometro;
        final distanciaPercorrida = kmFinal - kmInicial;
        mediaConsumoMes =
            totalLitrosMes > 0 ? distanciaPercorrida / totalLitrosMes : 0.0;
      }

      return {
        'totalGastoMes': totalGastoMes,
        'totalLitrosMes': totalLitrosMes,
        'precoMedioLitro': precoMedioLitro,
        'mediaConsumoMes': mediaConsumoMes,
      };
    } catch (e) {
      _logger.error('Failed to calculate monthly metrics', tag: 'ABAST', error: e);
      return {
        'totalGastoMes': 0.0,
        'totalLitrosMes': 0.0,
        'precoMedioLitro': 0.0,
        'mediaConsumoMes': 0.0,
      };
    }
  }

  // ===================================
  // UI CONTROL METHODS
  // ===================================

  void toggleHeader() {
    showHeader.value = !showHeader.value;
  }

  void animateToPage(int index) {
    carouselController.animateToPage(index);
    setCurrentCarouselIndex(index);
  }

  void setCurrentCarouselIndex(int index) {
    currentCarouselIndex.value = index;
    if (index < abastecimentosAgrupados.length) {
      final months = abastecimentosAgrupados.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      selectedMonth.value = months[index];
    }
  }

  bool hasDataForDate(DateTime date) {
    return abastecimentosAgrupados[date]?.isNotEmpty ?? false;
  }

  List<AbastecimentoCar> getAbastecimentosForDate(DateTime date) {
    return abastecimentosAgrupados[date] ?? [];
  }

  // ===================================
  // FORMATTING METHODS
  // ===================================

  String formatDateHeader(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String formatMonthYear(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    final yearTwoDigits = (date.year % 100).toString().padLeft(2, '0');
    return '${months[date.month - 1]} $yearTwoDigits';
  }

  String formatDay(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }

  String formatWeekday(DateTime date) {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return weekdays[date.weekday % 7];
  }

  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // ===================================
  // MÉTODOS PARA COLLAPSING HEADER
  // ===================================

  String getSelectedVehicleName() {
    if (!hasSelectedVehicle || selectedVehicle.value == null) {
      return 'Nenhum veículo';
    }

    final vehicle = selectedVehicle.value!;
    return '${vehicle.marca} ${vehicle.modelo} ${vehicle.ano}';
  }

  String getCurrentMonthName() {
    if (selectedMonth.value != null) {
      return formatMonthYear(selectedMonth.value!);
    }

    // Se não há mês selecionado, usar o mês atual
    final now = DateTime.now();
    return formatMonthYear(now);
  }

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

  // Método para recarregar dados com loading state
  Future<void> refreshData() async {
    await carregarAbastecimentos();
  }
}
