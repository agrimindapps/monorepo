// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/14_lembrete_model.dart';

class LembretesPageModel {
  List<LembreteVet> lembretes;
  bool isLoading;
  String? errorMessage;
  bool isInitialized;
  String? selectedAnimalId;
  Animal? selectedAnimal;
  DateTime? dataInicial;
  DateTime? dataFinal;

  LembretesPageModel({
    this.lembretes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.selectedAnimalId,
    this.selectedAnimal,
    this.dataInicial,
    this.dataFinal,
  });

  LembretesPageModel copyWith({
    List<LembreteVet>? lembretes,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    String? selectedAnimalId,
    Animal? selectedAnimal,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) {
    return LembretesPageModel(
      lembretes: lembretes ?? this.lembretes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
    );
  }

  void addLembrete(LembreteVet lembrete) {
    lembretes = [...lembretes, lembrete];
  }

  void updateLembrete(LembreteVet updatedLembrete) {
    lembretes = lembretes.map((lembrete) {
      return lembrete.id == updatedLembrete.id ? updatedLembrete : lembrete;
    }).toList();
  }

  void removeLembrete(LembreteVet lembreteToRemove) {
    lembretes = lembretes.where((lembrete) => lembrete.id != lembreteToRemove.id).toList();
  }

  void setLembretes(List<LembreteVet> newLembretes) {
    lembretes = List.from(newLembretes);
  }

  void clearLembretes() {
    lembretes = [];
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setError(String? error) {
    errorMessage = error;
  }

  void setInitialized(bool initialized) {
    isInitialized = initialized;
  }

  void setSelectedAnimal(String? animalId, Animal? animal) {
    selectedAnimalId = animalId;
    selectedAnimal = animal;
  }

  void setDateRange(DateTime? inicial, DateTime? dataFinalParam) {
    dataInicial = inicial;
    dataFinal = dataFinalParam;
  }

  void clearSelectedAnimal() {
    selectedAnimalId = null;
    selectedAnimal = null;
  }

  void clearDateRange() {
    dataInicial = null;
    dataFinal = null;
  }

  bool get hasLembretes => lembretes.isNotEmpty;
  bool get isEmpty => lembretes.isEmpty;
  int get lembreteCount => lembretes.length;
  bool get hasSelectedAnimal => selectedAnimalId != null && selectedAnimalId!.isNotEmpty;
  bool get hasDateRange => dataInicial != null && dataFinal != null;

  List<LembreteVet> get filteredLembretes {
    List<LembreteVet> filtered = List.from(lembretes);

    if (hasDateRange) {
      filtered = filtered.where((lembrete) {
        final lembreteDate = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
        return lembreteDate.isAfter(dataInicial!.subtract(const Duration(days: 1))) &&
               lembreteDate.isBefore(dataFinal!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  List<LembreteVet> get lembretesAtrasados {
    final now = DateTime.now();
    return lembretes.where((lembrete) {
      final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
      return !lembrete.concluido && dataHora.isBefore(now);
    }).toList();
  }

  List<LembreteVet> get lembretesPendentes {
    return lembretes.where((lembrete) => !lembrete.concluido).toList();
  }

  List<LembreteVet> get lembretesCompletos {
    return lembretes.where((lembrete) => lembrete.concluido).toList();
  }

  List<LembreteVet> get lembretesHoje {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return lembretes.where((lembrete) {
      final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
      return dataHora.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
             dataHora.isBefore(tomorrow);
    }).toList();
  }

  bool isLembreteAtrasado(LembreteVet lembrete) {
    if (lembrete.concluido) return false;
    final now = DateTime.now();
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return dataHora.isBefore(now);
  }

  String formatDateToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTimeToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String formatDateTimeToString(int timestamp) {
    return '${formatDateToString(timestamp)} às ${formatTimeToString(timestamp)}';
  }

  String getFormattedMonth() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String getLembreteStatusText(LembreteVet lembrete) {
    if (lembrete.concluido) return 'Concluído';
    if (isLembreteAtrasado(lembrete)) return 'Atrasado';
    return 'Pendente';
  }

  Color getLembreteStatusColor(LembreteVet lembrete) {
    if (lembrete.concluido) return const Color(0xFF10B981);
    if (isLembreteAtrasado(lembrete)) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  IconData getLembreteStatusIcon(LembreteVet lembrete) {
    if (lembrete.concluido) return Icons.check_circle;
    return Icons.pending;
  }
}
