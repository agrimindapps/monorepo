// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../controllers/medicoes_controller.dart';
import '../../../../controllers/pluviometros_controller.dart';
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../model/medicoes_page_model.dart';
import '../services/pluviometro_state_service.dart';
import '../utils/string_extensions.dart';

class MedicoesPageController {
  final _medicoesController = MedicoesController();
  final _pluviometrosController = PluviometrosController();
  late final PluviometroStateService _pluviometroStateService;

  MedicoesPageController() {
    _pluviometroStateService = PluviometroStateService(
      controller: _pluviometrosController,
    );
  }

  List<DateTime> getMonthsList(List<Medicoes> medicoes) {
    return _medicoesController.getMonthsList(medicoes);
  }

  List<Medicoes> getMonthMeasurements(List<Medicoes> medicoes, DateTime date) {
    return _medicoesController.getMedicoesDoMes(medicoes, date);
  }

  Future<List<Pluviometro>> getPluviometros() async {
    return await _pluviometrosController.getPluviometros();
  }

  Future<List<Medicoes>> getMeasurements(String pluviometroId) async {
    // Validação antes de fazer a chamada
    if (!_pluviometroStateService.isValidPluviometroId(pluviometroId)) {
      throw ArgumentError('ID de pluviômetro inválido: $pluviometroId');
    }

    try {
      return await _medicoesController.getMedicoes(pluviometroId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar medições para pluviômetro $pluviometroId: $e');
      }
      rethrow;
    }
  }

  /// Acesso seguro ao ID do pluviômetro selecionado
  String get selectedPluviometroId {
    return _pluviometroStateService.getSelectedPluviometroIdWithFallback();
  }

  /// Verifica se há pluviômetro selecionado válido
  bool get hasValidSelectedPluviometro {
    return _pluviometroStateService.hasValidSelectedPluviometro();
  }

  List<String> generateDaysOfMonthList() {
    // Usando formatação via service para consistência
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final List<String> daysOfMonth = [];
    for (var i = 0; i < lastDayOfMonth.day; i++) {
      final DateTime date = firstDayOfMonth.add(Duration(days: i));
      daysOfMonth.add(dateFormat.format(date));
    }
    return daysOfMonth;
  }

  MonthStatistics calculateMonthStatistics(
      DateTime date, List<Medicoes> monthMeasurements) {
    double total = 0;
    double average = 0;
    double maximum = 0;
    int rainyDays = 0;

    if (monthMeasurements.isNotEmpty) {
      total = monthMeasurements.fold(0.0, (sum, item) => sum + item.quantidade);
      average = total / DateTime(date.year, date.month + 1, 0).day;
      maximum = monthMeasurements
          .map((e) => e.quantidade)
          .reduce((a, b) => a > b ? a : b);
      rainyDays = monthMeasurements.where((m) => m.quantidade > 0).length;
    }

    return MonthStatistics(
      total: total,
      media: average,
      maximo: maximum,
      diasComChuva: rainyDays,
    );
  }

  Medicoes createEmptyMeasurement(DateTime currentDate) {
    return Medicoes(
      quantidade: 0,
      dtMedicao: currentDate.millisecondsSinceEpoch,
      id: '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      fkPluviometro: '',
    );
  }

  Medicoes findMeasurementForDate(
      List<Medicoes> monthMeasurements, DateTime currentDate) {
    return monthMeasurements.firstWhere(
      (m) {
        final measurementDate =
            DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
        return measurementDate.year == currentDate.year &&
            measurementDate.month == currentDate.month &&
            measurementDate.day == currentDate.day;
      },
      orElse: () => createEmptyMeasurement(currentDate),
    );
  }

  String formatWeekDay(DateTime date) {
    return DateFormat('EEEE', 'pt_BR')
        .format(date)
        .capitalize()
        .replaceAll('-feira', '');
  }
}
