// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../database/22_despesas_model.dart';
import '../../../../repository/despesas_repository.dart';
import '../../../../repository/veiculos_repository.dart';

class DespesasPageController extends GetxController {
  final DespesasRepository _despesasRepository = Get.find<DespesasRepository>();
  final VeiculosRepository _veiculosRepository = Get.find<VeiculosRepository>();

  final CarouselSliderController carouselController =
      CarouselSliderController();

  // Estados reativos
  final RxMap<DateTime, List<DespesaCar>> despesasPorMes =
      <DateTime, List<DespesaCar>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool showHeader = true.obs;
  final RxInt currentCarouselIndex = 0.obs;

  // Getters
  String get selectedVeiculoId => _veiculosRepository.selectedVeiculoId;
  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;
  bool get hasDespesas => despesasPorMes.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // Registrar repositórios se necessário
    _ensureRepositoriesRegistered();
    await carregarDespesas();
  }

  void _ensureRepositoriesRegistered() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.put<VeiculosRepository>(VeiculosRepository(), permanent: true);
    }

    if (!Get.isRegistered<DespesasRepository>()) {
      Get.put<DespesasRepository>(DespesasRepository(), permanent: true);
    }
  }

  Future<void> carregarDespesas() async {
    isLoading.value = true;
    try {
      final result = await carregarDespesasDoVeiculoSelecionado();
      despesasPorMes.value = result;
    } catch (e) {
      debugPrint('Erro ao carregar despesas: $e');
      Get.snackbar(
        'Erro',
        'Erro ao carregar despesas.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleHeader() {
    showHeader.value = !showHeader.value;
  }

  void setCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  void animateToPage(int index) {
    carouselController.animateToPage(index);
  }

  // Geração de lista de meses
  List<DateTime> generateMonthsList() {
    if (despesasPorMes.isEmpty) return [];

    final dates = despesasPorMes.keys.map((monthYear) {
      final formattedMonthYear =
          DateFormat('MMMM yyyy', 'pt_BR').format(monthYear);
      final parts = formattedMonthYear.split(' ');
      return DateTime(
        int.parse(parts[1]),
        DateFormat('MMMM', 'pt_BR').parse(parts[0]).month,
      );
    }).toList();

    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    List<DateTime> allMonths = [];
    DateTime currentDate = DateTime(oldestDate.year, oldestDate.month);
    final lastDate = DateTime(newestDate.year, newestDate.month);

    while (!currentDate.isAfter(lastDate)) {
      allMonths.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return allMonths.reversed.toList();
  }

  // Formatação
  String formatDateHeader(DateTime date) {
    return DateFormat('MMM yy', 'pt_BR').format(date).customCapitalize();
  }

  String formatDay(DateTime date) {
    return DateFormat('dd').format(date);
  }

  String formatWeekday(DateTime date) {
    return DateFormat('EEE', 'pt_BR').format(date).toUpperCase();
  }

  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  // Estatísticas
  Map<String, dynamic> calcularEstatisticasMensais(List<DespesaCar> despesas) {
    try {
      final totalMes = despesas.fold(0.0, (sum, item) => sum + item.valor);
      final mediaPorDespesa =
          despesas.isEmpty ? 0.0 : totalMes / despesas.length;

      return {
        'totalMes': totalMes,
        'quantidade': despesas.length,
        'mediaPorDespesa': mediaPorDespesa
      };
    } catch (e) {
      debugPrint('Controller Error: calcularEstatisticasMensais - $e');
      return {'totalMes': 0.0, 'quantidade': 0, 'mediaPorDespesa': 0.0};
    }
  }

  // Ícones por tipo
  IconData getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'manutenção':
        return Icons.build;
      case 'combustível':
        return Icons.local_gas_station;
      case 'seguro':
        return Icons.security;
      case 'multa':
        return Icons.warning;
      case 'licenciamento':
        return Icons.description;
      case 'limpeza':
        return Icons.cleaning_services;
      case 'estacionamento':
        return Icons.local_parking;
      case 'lavagem':
        return Icons.local_car_wash;
      case 'pedágio':
        return Icons.toll;
      case 'ipva':
        return Icons.description;
      case 'acessórios':
        return Icons.shopping_bag;
      case 'documentação':
        return Icons.folder;
      default:
        return Icons.attach_money;
    }
  }

  // Dados por mês
  List<DespesaCar> getDespesasForMonth(DateTime month) {
    return despesasPorMes[month] ?? [];
  }

  bool hasDataForMonth(DateTime month) {
    return getDespesasForMonth(month).isNotEmpty;
  }

  // Métodos migrados do DespesasListaController
  Future<void> initialize() => _despesasRepository.initialize();

  Future<Map<DateTime, List<DespesaCar>>> getDespesasAgrupadas(
      String veiculoId) async {
    try {
      return await _despesasRepository.getDespesasAgrupadas(veiculoId);
    } catch (e) {
      debugPrint('Controller Error: getDespesasAgrupadas - $e');
      return {};
    }
  }

  Future<Map<DateTime, List<DespesaCar>>>
      carregarDespesasDoVeiculoSelecionado() async {
    try {
      String veiculoId = _veiculosRepository.selectedVeiculoId;
      return await getDespesasAgrupadas(veiculoId);
    } catch (e) {
      debugPrint('Controller Error: carregarDespesasDoVeiculoSelecionado - $e');
      return {};
    }
  }

  Future<Map<String, double>> getDespesasEstatisticas(String veiculoId) async {
    try {
      final now = DateTime.now();

      final inicioEsteMes = DateTime(now.year, now.month, 1);
      final fimEsteMes = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final inicioMesAnterior = DateTime(now.year, now.month - 1, 1);
      final fimMesAnterior = DateTime(now.year, now.month, 0, 23, 59, 59);

      final inicioEsteAno = DateTime(now.year, 1, 1);
      final fimEsteAno = DateTime(now.year, 12, 31, 23, 59, 59);

      final inicioAnoAnterior = DateTime(now.year - 1, 1, 1);
      final fimAnoAnterior = DateTime(now.year - 1, 12, 31, 23, 59, 59);

      final despesasEsteMes = await _despesasRepository.getDespesasByPeriodo(
          veiculoId, inicioEsteMes, fimEsteMes);

      final despesasMesAnterior = await _despesasRepository
          .getDespesasByPeriodo(veiculoId, inicioMesAnterior, fimMesAnterior);

      final despesasEsteAno = await _despesasRepository.getDespesasByPeriodo(
          veiculoId, inicioEsteAno, fimEsteAno);

      final despesasAnoAnterior = await _despesasRepository
          .getDespesasByPeriodo(veiculoId, inicioAnoAnterior, fimAnoAnterior);

      final totalEsteMes = _calcularTotalDespesas(despesasEsteMes);
      final totalMesAnterior = _calcularTotalDespesas(despesasMesAnterior);
      final totalEsteAno = _calcularTotalDespesas(despesasEsteAno);
      final totalAnoAnterior = _calcularTotalDespesas(despesasAnoAnterior);

      return {
        'esteMes': totalEsteMes,
        'mesAnterior': totalMesAnterior,
        'esteAno': totalEsteAno,
        'anoAnterior': totalAnoAnterior,
      };
    } catch (e) {
      debugPrint('Controller Error: getDespesasEstatisticas - $e');
      return {
        'esteMes': 0.0,
        'mesAnterior': 0.0,
        'esteAno': 0.0,
        'anoAnterior': 0.0,
      };
    }
  }

  double _calcularTotalDespesas(List<DespesaCar> despesas) {
    return despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  Future<String> exportarDespesasParaCsv(String veiculoId) async {
    try {
      return await _despesasRepository.exportToCsv(veiculoId);
    } catch (e) {
      debugPrint('Controller Error: exportarDespesasParaCsv - $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> getEstatisticasPorTipo(
      String veiculoId, DateTime inicio, DateTime fim) async {
    try {
      final despesas = await _despesasRepository.getDespesasByPeriodo(
          veiculoId, inicio, fim);

      final despesasPorTipo = <String, List<DespesaCar>>{};
      for (var despesa in despesas) {
        final tipo = despesa.tipo;
        if (!despesasPorTipo.containsKey(tipo)) {
          despesasPorTipo[tipo] = [];
        }
        despesasPorTipo[tipo]!.add(despesa);
      }

      final estatisticas = <String, Map<String, dynamic>>{};
      despesasPorTipo.forEach((tipo, lista) {
        final total = _calcularTotalDespesas(lista);
        final mediaPorDespesa = lista.isEmpty ? 0.0 : total / lista.length;

        estatisticas[tipo] = {
          'total': total,
          'quantidade': lista.length,
          'mediaPorDespesa': mediaPorDespesa,
          'percentual': despesas.isEmpty
              ? 0.0
              : (total / _calcularTotalDespesas(despesas)) * 100,
        };
      });

      return {
        'totalGeral': _calcularTotalDespesas(despesas),
        'quantidadeGeral': despesas.length,
        'porTipo': estatisticas,
      };
    } catch (e) {
      debugPrint('Controller Error: getEstatisticasPorTipo - $e');
      return {
        'totalGeral': 0.0,
        'quantidadeGeral': 0,
        'porTipo': {},
      };
    }
  }

  // Callback para recarregar após operações
  Future<void> onDespesaChanged() async {
    await carregarDespesas();
  }
}

// Extensão para capitalizar strings
extension CustomStringExtension on String {
  String customCapitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
