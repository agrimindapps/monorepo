// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../database/25_manutencao_model.dart';
import '../../../../repository/manutecoes_repository.dart';
import '../../../../repository/veiculos_repository.dart';

class ManutencoesPageController extends GetxController {
  final ManutencoesRepository _manutencoesRepository = ManutencoesRepository();
  final VeiculosRepository _veiculosRepository = VeiculosRepository();

  final CarouselSliderController carouselController =
      CarouselSliderController();
  final TextEditingController searchController = TextEditingController();

  // Estados reativos
  final RxList<ManutencaoCar> manutencoes = <ManutencaoCar>[].obs;
  final RxList<DateTime> monthsList = <DateTime>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showHeader = true.obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxDouble scrollOffset = 0.0.obs;
  final RxList<ManutencaoCar> abastecimentosAgrupados = <ManutencaoCar>[].obs;

  // Getters
  String get selectedVeiculoId => _veiculosRepository.selectedVeiculoId;
  bool get hasSelectedVehicle => selectedVeiculoId.isNotEmpty;
  bool get hasManutencoes => manutencoes.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final veiculoId = selectedVeiculoId;
      final loadedManutencoes = await getManutencoes(veiculoId);

      manutencoes.value = loadedManutencoes;
      monthsList.value = generateMonthsList(loadedManutencoes);
    } catch (e) {
      debugPrint('Erro ao carregar manutenções: $e');
      Get.snackbar(
        'Erro',
        'Erro ao carregar manutenções.',
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

  // Formatação
  String formatDateHeader(DateTime date) {
    final formatted = DateFormat('MMM yy', 'pt_BR').format(date);
    return _capitalizeString(formatted);
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

  // Filtros e dados por mês
  List<ManutencaoCar> filterManutencoesByMonth(DateTime month) {
    return filterManutencoesByMonthInternal(manutencoes, month);
  }

  bool hasDataForMonth(DateTime month) {
    return filterManutencoesByMonth(month).isNotEmpty;
  }

  // Atualizar offset de scroll
  void updateScrollOffset(double offset) {
    scrollOffset.value = offset;
  }

  // Obter manutenções do mês atual baseado no índice do carousel
  List<ManutencaoCar> get currentMonthManutencoes {
    if (monthsList.isEmpty || currentCarouselIndex.value >= monthsList.length) {
      return [];
    }
    return filterManutencoesByMonth(monthsList[currentCarouselIndex.value]);
  }

  // Estatísticas mensais
  Map<String, dynamic> calcularEstatisticasMensais(
      List<ManutencaoCar> manutencoesMes) {
    final totalGasto =
        manutencoesMes.fold(0.0, (sum, item) => sum + item.valor);
    final countPendentes = manutencoesMes.where((m) => !m.concluida).length;
    final countConcluidas = manutencoesMes.where((m) => m.concluida).length;
    final total = manutencoesMes.length;

    return {
      'totalGasto': totalGasto,
      'pendentes': countPendentes,
      'concluidas': countConcluidas,
      'total': total,
    };
  }

  // Ícones por tipo de manutenção
  IconData getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'preventiva':
        return Icons.build_circle;
      case 'corretiva':
        return Icons.build;
      case 'revisão':
        return Icons.fact_check;
      default:
        return Icons.build;
    }
  }

  // Cores por status
  Color getStatusColor(bool concluida) {
    return concluida ? Colors.green : Colors.orange;
  }

  IconData getStatusIcon(bool concluida) {
    return concluida ? Icons.check_circle : Icons.pending_actions;
  }

  // Callback para recarregar após operações
  Future<void> onManutencaoChanged() async {
    await loadData();
  }

  // Busca
  void search(String query) {
    // Implementar busca se necessário
    // Por enquanto, recarrega os dados
    loadData();
  }

  // Métodos auxiliares para estatísticas
  double get totalGeralGasto {
    return manutencoes.fold(0.0, (sum, item) => sum + item.valor);
  }

  int get totalPendentes {
    return manutencoes.where((m) => !m.concluida).length;
  }

  int get totalConcluidas {
    return manutencoes.where((m) => m.concluida).length;
  }

  // Filtros por status
  List<ManutencaoCar> get manutencoesPendentes {
    return manutencoes.where((m) => !m.concluida).toList();
  }

  List<ManutencaoCar> get manutencoesConcluidas {
    return manutencoes.where((m) => m.concluida).toList();
  }

  // Manutenção mais cara
  ManutencaoCar? get manutencaoMaisCara {
    if (manutencoes.isEmpty) return null;
    return manutencoes.reduce((a, b) => a.valor > b.valor ? a : b);
  }

  // Média de gastos
  double get mediaGastos {
    if (manutencoes.isEmpty) return 0.0;
    return totalGeralGasto / manutencoes.length;
  }

  // Métodos migrados do ManutencoesListaController
  static Future<void> initialize() => ManutencoesRepository.initialize();

  Future<List<ManutencaoCar>> getManutencoes(String veiculoId) async {
    try {
      return await _manutencoesRepository.getManutencoes(veiculoId);
    } catch (e) {
      debugPrint('Controller Error: getManutencoes - $e');
      return [];
    }
  }

  List<DateTime> generateMonthsList(List<ManutencaoCar> manutencoes) {
    if (manutencoes.isEmpty) return [];
    final dates =
        manutencoes.map((m) => DateTime.fromMillisecondsSinceEpoch(m.data));
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

  List<ManutencaoCar> filterManutencoesByMonthInternal(
      List<ManutencaoCar> manutencoes, DateTime date) {
    return manutencoes.where((m) {
      final mDate = DateTime.fromMillisecondsSinceEpoch(m.data);
      return mDate.year == date.year && mDate.month == date.month;
    }).toList();
  }

  // Método auxiliar para capitalizar strings
  String _capitalizeString(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
