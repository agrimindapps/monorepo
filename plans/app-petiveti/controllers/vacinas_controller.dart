// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/16_vacina_model.dart';
import '../repository/vacina_repository.dart';

class VacinasController extends GetxController {
  final VacinaRepository _repository;
  final _vacinas = <VacinaVet>[].obs;
  final _isLoading = false.obs;
  final _dataInicial = DateTime.now()
      .subtract(const Duration(days: 365))
      .millisecondsSinceEpoch
      .obs;
  final _dataFinal =
      DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch.obs;

  List<VacinaVet> get vacinas => _vacinas;
  bool get isLoading => _isLoading.value;
  int get dataInicial => _dataInicial.value;
  int get dataFinal => _dataFinal.value;

  List<VacinaVet> get vacinasAtrasadas {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    return _vacinas.where((vacina) => vacina.proximaDose < hoje).toList();
  }

  List<VacinaVet> get proximasVacinas {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    final emTrintaDias = hoje + const Duration(days: 30).inMilliseconds;
    return _vacinas
        .where((vacina) =>
            vacina.proximaDose >= hoje && vacina.proximaDose <= emTrintaDias)
        .toList();
  }

  VacinasController({VacinaRepository? repository})
      : _repository = repository ?? VacinaRepository();

  static Future<VacinasController> initialize() async {
    await VacinaRepository.initialize();
    final controller = VacinasController();
    Get.put(controller);
    return controller;
  }

  Future<void> loadVacinas(String animalId) async {
    _isLoading.value = true;
    try {
      final result = await _repository.getVacinas(
        animalId,
        dataInicial: _dataInicial.value,
        dataFinal: _dataFinal.value,
      );
      _vacinas.assignAll(result);
    } catch (e) {
      debugPrint('Error loading vacinas: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void setDateRange(int dataInicial, int dataFinal) {
    _dataInicial.value = dataInicial;
    _dataFinal.value = dataFinal;
  }

  List<VacinaVet> searchVacinas(String query) {
    if (query.isEmpty) return _vacinas;
    final lowercaseQuery = query.toLowerCase();
    return _vacinas.where((vacina) {
      return vacina.nomeVacina.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<VacinaVet?> getVacinaById(String id) async {
    return await _repository.getVacinaById(id);
  }

  Future<bool> addVacina(VacinaVet vacina) async {
    final result = await _repository.addVacina(vacina);
    if (result) {
      await loadVacinas(vacina.animalId);
    }
    return result;
  }

  Future<bool> updateVacina(VacinaVet vacina) async {
    final result = await _repository.updateVacina(vacina);
    if (result) {
      await loadVacinas(vacina.animalId);
    }
    return result;
  }

  Future<bool> deleteVacina(VacinaVet vacina) async {
    final result = await _repository.deleteVacina(vacina);
    if (result) {
      await loadVacinas(vacina.animalId);
    }
    return result;
  }

  bool isVacinaAtrasada(VacinaVet vacina) {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    return vacina.proximaDose < hoje;
  }

  bool isProximaVacina(VacinaVet vacina) {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    final emTrintaDias = hoje + const Duration(days: 30).inMilliseconds;
    return vacina.proximaDose >= hoje && vacina.proximaDose <= emTrintaDias;
  }

  int diasParaProximaDose(VacinaVet vacina) {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    if (hoje > vacina.proximaDose) return -1;
    final diasRestantes = (vacina.proximaDose - hoje) ~/ (24 * 60 * 60 * 1000);
    return diasRestantes;
  }

  String formatDateToString(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<bool> confirmarExclusaoVacina(
      BuildContext context, VacinaVet vacina) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja excluir esta vacina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final result = await deleteVacina(vacina);
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacina excluída com sucesso')),
        );
      }
      return result;
    }
    return false;
  }

  Future<String> exportVacinasToCsv(String animalId) async {
    try {
      final csvData = await _repository.exportToCsv(animalId);
      return csvData;
    } catch (e) {
      debugPrint('Error exporting vacinas to CSV: $e');
      return '';
    }
  }

  String escapeFieldForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
