// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/14_lembrete_model.dart';
import '../../../../repository/lembrete_repository.dart';
import '../../../../services/pet_notification_manager.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/lembretes_page_model.dart';

class LembretesPageController extends GetxController {
  final _animalController = Get.find<AnimalPageController>();
  final _model = LembretesPageModel().obs;
  final LembreteRepository _repository;
  final PetNotificationManager _notificationManager;

  LembretesPageModel get model => _model.value;
  List<LembreteVet> get lembretes => model.lembretes;
  List<LembreteVet> get filteredLembretes => model.filteredLembretes;
  bool get isLoading => model.isLoading;
  String? get errorMessage => model.errorMessage;
  bool get isInitialized => model.isInitialized;
  bool get hasLembretes => model.hasLembretes;
  int get lembreteCount => model.lembreteCount;
  String? get selectedAnimalId => model.selectedAnimalId;
  Animal? get selectedAnimal => model.selectedAnimal;
  bool get hasSelectedAnimal => model.hasSelectedAnimal;
  DateTime? get dataInicial => model.dataInicial;
  DateTime? get dataFinal => model.dataFinal;
  bool get hasDateRange => model.hasDateRange;

  List<LembreteVet> get lembretesAtrasados => model.lembretesAtrasados;
  List<LembreteVet> get lembretesPendentes => model.lembretesPendentes;
  List<LembreteVet> get lembretesCompletos => model.lembretesCompletos;
  List<LembreteVet> get lembretesHoje => model.lembretesHoje;

  LembretesPageController({
    LembreteRepository? repository,
    PetNotificationManager? notificationManager,
  })  : _repository = repository ?? LembreteRepository(),
        _notificationManager = notificationManager ?? PetNotificationManager();

  static Future<LembretesPageController> initialize() async {
    await LembreteRepository.initialize();
    final controller = LembretesPageController();
    Get.put(controller, tag: 'lembretes_page');
    return controller;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      setLoading(true);
      setInitialized(true);
      setError(null);
      await loadLembretes();
    } catch (e) {
      setError('Erro ao inicializar o controlador: $e');
      debugPrint('Erro ao inicializar LembretesPageController: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadLembretes([String? animalId]) async {
    try {
      setLoading(true);
      setError(null);

      final targetAnimalId = animalId ?? _animalController.selectedAnimalId;

      if (targetAnimalId.isNotEmpty) {
        final dataInicialMs = dataInicial?.millisecondsSinceEpoch ??
            DateTime.now()
                .subtract(const Duration(days: 30))
                .millisecondsSinceEpoch;
        final dataFinalMs = dataFinal?.millisecondsSinceEpoch ??
            DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;

        final result = await _repository.getLembretes(
          targetAnimalId,
          dataInicial: dataInicialMs,
          dataFinal: dataFinalMs,
        );
        setLembretes(result);
      } else {
        clearLembretes();
      }
    } catch (e) {
      setError('Erro ao carregar lembretes: $e');
      debugPrint('Erro ao carregar lembretes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteLembrete(LembreteVet lembrete) async {
    try {
      final result = await _repository.deleteLembrete(lembrete);
      if (result) {
        await _cancelarNotificacaoLembrete(lembrete.id);
        removeLembrete(lembrete);
      }
    } catch (e) {
      setError('Erro ao excluir lembrete: $e');
      debugPrint('Erro ao excluir lembrete: $e');
      rethrow;
    }
  }

  Future<void> toggleLembreteConcluido(LembreteVet lembrete) async {
    try {
      lembrete.concluido = !lembrete.concluido;
      final result = await _repository.updateLembrete(lembrete);

      if (result) {
        final updatedLembrete = LembreteVet(
          id: lembrete.id,
          createdAt: lembrete.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          isDeleted: lembrete.isDeleted,
          needsSync: true,
          version: lembrete.version + 1,
          lastSyncAt: lembrete.lastSyncAt,
          animalId: lembrete.animalId,
          titulo: lembrete.titulo,
          descricao: lembrete.descricao,
          dataHora: lembrete.dataHora,
          tipo: lembrete.tipo,
          repetir: lembrete.repetir,
          concluido: lembrete.concluido,
        );

        updateLembrete(updatedLembrete);
      }
    } catch (e) {
      setError('Erro ao alterar status do lembrete: $e');
      debugPrint('Erro ao alterar status do lembrete: $e');
      rethrow;
    }
  }

  Future<void> refreshLembretes() async {
    await loadLembretes();
  }

  void onAnimalSelected(String? animalId, Animal? animal) {
    setSelectedAnimal(animalId, animal);
    if (animalId != null && animalId.isNotEmpty) {
      loadLembretes(animalId);
    } else {
      clearLembretes();
    }
  }

  void onDateRangeChanged(int? dataInicial, int? dataFinal) {
    setDateRange(
      dataInicial != null
          ? DateTime.fromMillisecondsSinceEpoch(dataInicial)
          : null,
      dataFinal != null ? DateTime.fromMillisecondsSinceEpoch(dataFinal) : null,
    );
    loadLembretes();
  }

  void setLoading(bool loading) {
    _model.update((model) {
      model?.setLoading(loading);
    });
  }

  void setError(String? error) {
    _model.update((model) {
      model?.setError(error);
    });
  }

  void setInitialized(bool initialized) {
    _model.update((model) {
      model?.setInitialized(initialized);
    });
  }

  void setLembretes(List<LembreteVet> lembretes) {
    _model.update((model) {
      model?.setLembretes(lembretes);
    });
  }

  void addLembrete(LembreteVet lembrete) {
    _model.update((model) {
      model?.addLembrete(lembrete);
    });
  }

  void updateLembrete(LembreteVet lembrete) {
    _model.update((model) {
      model?.updateLembrete(lembrete);
    });
  }

  void removeLembrete(LembreteVet lembrete) {
    _model.update((model) {
      model?.removeLembrete(lembrete);
    });
  }

  void clearLembretes() {
    _model.update((model) {
      model?.clearLembretes();
    });
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    _model.update((model) {
      model?.setSelectedAnimal(animalId, animal);
    });
  }

  void setDateRange(DateTime? dataInicial, DateTime? dataFinal) {
    _model.update((model) {
      model?.setDateRange(dataInicial, dataFinal);
    });
  }

  void clearSelectedAnimal() {
    _model.update((model) {
      model?.clearSelectedAnimal();
    });
  }

  void clearDateRange() {
    _model.update((model) {
      model?.clearDateRange();
    });
  }

  String getSubtitle() {
    if (!isInitialized) {
      return 'Carregando...';
    }
    return '$lembreteCount registros';
  }

  String formatDateToString(int timestamp) {
    return model.formatDateToString(timestamp);
  }

  String formatTimeToString(int timestamp) {
    return model.formatTimeToString(timestamp);
  }

  String formatDateTimeToString(int timestamp) {
    return model.formatDateTimeToString(timestamp);
  }

  String getFormattedMonth() {
    return model.getFormattedMonth();
  }

  String getFormattedCurrentMonth() {
    final now = DateTime.now();
    return capitalize(DateFormat('MMM yy', 'pt_BR').format(now));
  }

  List<String> getAvailableMonths() {
    return _getAvailableMonthsFromUtils();
  }

  String getFormattedPeriod() {
    return _getFormattedPeriodFromUtils();
  }

  List<String> _getAvailableMonthsFromUtils() {
    // Import dinamico do utils para evitar dependência circular
    return lembretes.isEmpty 
        ? [getFormattedCurrentMonth()]
        : _generateMonthsFromLembretes();
  }

  String _getFormattedPeriodFromUtils() {
    return lembretes.isEmpty 
        ? getFormattedCurrentMonth()
        : _generatePeriodFromLembretes();
  }

  List<String> _generateMonthsFromLembretes() {
    if (lembretes.isEmpty) return [getFormattedCurrentMonth()];

    final sortedLembretes = List<LembreteVet>.from(lembretes)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.first.dataHora);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.last.dataHora);

    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = capitalize(DateFormat('MMM yy', 'pt_BR').format(currentDate));
      meses.add(mesFormatado);
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    final mesAtual = getFormattedCurrentMonth();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList();
  }

  String _generatePeriodFromLembretes() {
    if (lembretes.isEmpty) return getFormattedCurrentMonth();

    final sortedLembretes = List<LembreteVet>.from(lembretes)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.first.dataHora);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.last.dataHora);

    final mesInicial = capitalize(DateFormat('MMM yy', 'pt_BR').format(dataInicial));
    final mesFinal = capitalize(DateFormat('MMM yy', 'pt_BR').format(dataFinal));

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  String capitalize(String text) {
    return model.capitalize(text);
  }

  bool isLembreteAtrasado(LembreteVet lembrete) {
    return model.isLembreteAtrasado(lembrete);
  }

  String getLembreteStatusText(LembreteVet lembrete) {
    return model.getLembreteStatusText(lembrete);
  }

  Color getLembreteStatusColor(LembreteVet lembrete) {
    return model.getLembreteStatusColor(lembrete);
  }

  IconData getLembreteStatusIcon(LembreteVet lembrete) {
    return model.getLembreteStatusIcon(lembrete);
  }

  IconData getLembreteActionIcon(LembreteVet lembrete) {
    return lembrete.concluido ? Icons.refresh : Icons.check;
  }

  Color getLembreteActionColor(LembreteVet lembrete) {
    return lembrete.concluido ? Colors.orange : Colors.green;
  }

  bool shouldShowLoading() {
    return isLoading;
  }

  bool shouldShowError() {
    return errorMessage != null;
  }

  bool shouldShowNoAnimalSelected() {
    return !hasSelectedAnimal;
  }

  bool shouldShowNoData() {
    return hasSelectedAnimal &&
        !isLoading &&
        lembretes.isEmpty &&
        errorMessage == null;
  }

  bool shouldShowLembretes() {
    return hasSelectedAnimal &&
        !isLoading &&
        lembretes.isNotEmpty &&
        errorMessage == null;
  }

  bool canAddLembrete() {
    return hasSelectedAnimal;
  }

  List<LembreteVet> searchLembretes(String query) {
    if (query.isEmpty) return lembretes;
    final lowercaseQuery = query.toLowerCase();
    return lembretes.where((lembrete) {
      return lembrete.titulo.toLowerCase().contains(lowercaseQuery) ||
          lembrete.descricao.toLowerCase().contains(lowercaseQuery) ||
          lembrete.tipo.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<LembreteVet?> getLembreteById(String id) async {
    return await _repository.getLembreteById(id);
  }

  Future<String> exportToCsv(String animalId) async {
    try {
      final lembretes = await _repository.getLembretes(animalId);
      if (lembretes.isEmpty) return '';
      const csvHeader = 'Título,Data/Hora,Descrição,Tipo,Repetir,Concluído\n';
      final csvRows = lembretes.map((lembrete) {
        final titulo = _escapeField(lembrete.titulo);
        final dataHora = _escapeField('${formatDateToString(lembrete.dataHora)} ${formatTimeToString(lembrete.dataHora)}');
        final descricao = _escapeField(lembrete.descricao);
        final tipo = _escapeField(lembrete.tipo);
        final repetir = _escapeField(lembrete.repetir);
        final concluido = lembrete.concluido ? 'Sim' : 'Não';
        return '$titulo,$dataHora,$descricao,$tipo,$repetir,$concluido';
      }).join('\n');
      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting lembretes to CSV: $e');
      return '';
    }
  }

  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Monthly navigation methods
  final RxInt _currentMonthIndex = 0.obs;

  List<DateTime> getMonthsList() {
    if (lembretes.isEmpty) {
      return [DateTime.now()];
    }

    final dates = lembretes.map((lembrete) => DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora)).toList();
    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    return _generateMonthsBetween(oldestDate, newestDate);
  }

  List<DateTime> _generateMonthsBetween(DateTime start, DateTime end) {
    List<DateTime> months = [];
    DateTime currentDate = DateTime(start.year, start.month);
    final lastDate = DateTime(end.year, end.month);

    while (!currentDate.isAfter(lastDate)) {
      months.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return months.reversed.toList();
  }

  int getCurrentMonthIndex() => _currentMonthIndex.value;

  void setCurrentMonthIndex(int index) {
    _currentMonthIndex.value = index;
    update();
  }

  Future<void> _cancelarNotificacaoLembrete(String id) async {}
}
