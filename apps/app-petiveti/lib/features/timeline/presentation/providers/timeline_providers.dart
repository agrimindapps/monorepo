import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../../appointments/presentation/providers/appointments_providers.dart';
import '../../../expenses/presentation/notifiers/expenses_notifier.dart';
import '../../../medications/presentation/providers/medications_providers.dart';
import '../../../vaccines/presentation/providers/vaccines_providers.dart';
import '../../../weight/presentation/providers/weight_providers.dart';
import '../../domain/entities/timeline_item.dart';

part 'timeline_providers.g.dart';

/// Estado da timeline
class TimelineState {
  final List<TimelineItem> items;
  final bool isLoading;
  final String? error;
  final String? selectedAnimalId;

  const TimelineState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedAnimalId,
  });

  TimelineState copyWith({
    List<TimelineItem>? items,
    bool? isLoading,
    String? error,
    String? selectedAnimalId,
  }) {
    return TimelineState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
    );
  }
}

/// Provider para a timeline unificada
@riverpod
class Timeline extends _$Timeline {
  @override
  TimelineState build() {
    return const TimelineState();
  }

  /// Carrega todos os eventos na timeline
  Future<void> loadTimeline({String? animalId}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null, selectedAnimalId: animalId);

    try {
      final items = <TimelineItem>[];
      
      // Obtém o mapa de animais para pegar os nomes
      final animalsState = ref.read(animalsProvider);
      final animalsMap = <String, Animal>{};
      for (final animal in animalsState.animals) {
        animalsMap[animal.id] = animal;
      }

      // Vacinas
      final vaccinesState = ref.read(vaccinesProvider);
      var vaccines = vaccinesState.vaccines;
      if (animalId != null) {
        vaccines = vaccines.where((v) => v.animalId == animalId).toList();
      }
      for (final vaccine in vaccines) {
        final animal = animalsMap[vaccine.animalId];
        items.add(TimelineItem(
          id: 'vaccine_${vaccine.id}',
          type: TimelineEventType.vaccine,
          title: vaccine.name,
          date: vaccine.date,
          animalId: vaccine.animalId,
          animalName: animal?.name,
          icon: Icons.vaccines,
          veterinarian: vaccine.veterinarian,
          nextDueDate: vaccine.nextDueDate,
          batch: vaccine.batch,
          dosage: vaccine.dosage,
          notes: vaccine.notes,
        ));
      }

      // Medicamentos
      final medicationsState = ref.read(medicationsProvider);
      var medications = medicationsState.medications;
      if (animalId != null) {
        medications = medications.where((m) => m.animalId == animalId).toList();
      }
      for (final medication in medications) {
        final animal = animalsMap[medication.animalId];
        items.add(TimelineItem(
          id: 'medication_${medication.id}',
          type: TimelineEventType.medication,
          title: medication.name,
          date: medication.startDate,
          animalId: medication.animalId,
          animalName: animal?.name,
          icon: Icons.medication,
          dosage: medication.dosage,
          frequency: medication.frequency,
          duration: medication.duration,
          startDate: medication.startDate,
          endDate: medication.endDate,
          medicationType: medication.type.displayName,
          isActive: medication.isActive,
          veterinarian: medication.prescribedBy,
          notes: medication.notes,
        ));
      }

      // Consultas
      final appointmentsState = ref.read(appointmentsProvider);
      var appointments = appointmentsState.appointments;
      if (animalId != null) {
        appointments = appointments.where((a) => a.animalId == animalId).toList();
      }
      for (final appointment in appointments) {
        final animal = animalsMap[appointment.animalId];
        items.add(TimelineItem(
          id: 'appointment_${appointment.id}',
          type: TimelineEventType.appointment,
          title: appointment.veterinarianName,
          date: appointment.date,
          animalId: appointment.animalId,
          animalName: animal?.name,
          icon: Icons.calendar_today,
          veterinarian: appointment.veterinarianName,
          status: appointment.status.name,
          description: appointment.reason,
          cost: appointment.cost,
          notes: appointment.diagnosis,
        ));
      }

      // Peso
      final weightsState = ref.read(weightsProvider);
      var weights = weightsState.weights;
      if (animalId != null) {
        weights = weights.where((w) => w.animalId == animalId).toList();
      }
      for (final weightRecord in weights) {
        final animal = animalsMap[weightRecord.animalId];
        items.add(TimelineItem(
          id: 'weight_${weightRecord.id}',
          type: TimelineEventType.weight,
          title: '${weightRecord.weight.toStringAsFixed(1)} kg',
          date: weightRecord.date,
          animalId: weightRecord.animalId,
          animalName: animal?.name,
          icon: Icons.monitor_weight,
          weight: weightRecord.weight,
          weightUnit: 'kg',
          bodyConditionScore: weightRecord.bodyConditionScore,
          notes: weightRecord.notes,
        ));
      }

      // Despesas
      final expensesState = ref.read(expensesProvider);
      var expenses = expensesState.expenses;
      if (animalId != null) {
        expenses = expenses.where((e) => e.animalId == animalId).toList();
      }
      for (final expense in expenses) {
        final animal = animalsMap[expense.animalId];
        items.add(TimelineItem(
          id: 'expense_${expense.id}',
          type: TimelineEventType.expense,
          title: expense.title,
          date: expense.expenseDate,
          animalId: expense.animalId,
          animalName: animal?.name,
          icon: Icons.attach_money,
          amount: expense.amount,
          category: expense.category.name,
          paymentMethod: expense.paymentMethod.name,
          isPaid: expense.isPaid,
          veterinarian: expense.veterinarianName,
          description: expense.description,
          notes: expense.notes,
        ));
      }

      // Ordena por data (mais recente primeiro)
      items.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filtra a timeline por animal
  void filterByAnimal(String? animalId) {
    loadTimeline(animalId: animalId);
  }

  /// Agrupa itens por data (para exibição por dia)
  Map<DateTime, List<TimelineItem>> getGroupedByDate() {
    final grouped = <DateTime, List<TimelineItem>>{};
    for (final item in state.items) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(item);
      } else {
        grouped[dateKey] = [item];
      }
    }
    return grouped;
  }
}

/// Provider para eventos de hoje
@riverpod
List<TimelineItem> todayEvents(Ref ref) {
  final timelineState = ref.watch(timelineProvider);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  
  return timelineState.items.where((item) {
    return item.date.isAfter(todayStart) && item.date.isBefore(todayEnd);
  }).toList();
}

/// Provider para próximos eventos (próximos 7 dias)
@riverpod
List<TimelineItem> upcomingEvents(Ref ref) {
  final timelineState = ref.watch(timelineProvider);
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  
  return timelineState.items.where((item) {
    return item.date.isAfter(now) && item.date.isBefore(nextWeek);
  }).toList();
}

/// Provider para eventos passados (últimos 30 dias)
@riverpod
List<TimelineItem> recentEvents(Ref ref) {
  final timelineState = ref.watch(timelineProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  
  return timelineState.items.where((item) {
    return item.date.isBefore(now) && item.date.isAfter(thirtyDaysAgo);
  }).toList();
}
