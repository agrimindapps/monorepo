import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/vaccine.dart';
import 'vaccine_form_state.dart';
import 'vaccines_providers.dart';

part 'vaccine_form_notifier.g.dart';

/// Notifier para gerenciar o estado do formulário de vacina
@riverpod
class VaccineFormNotifier extends _$VaccineFormNotifier {
  @override
  VaccineFormState build(String animalId) {
    return VaccineFormState.initial();
  }
  
  /// Inicializa o formulário
  Future<void> initialize({
    required String animalId,
    Vaccine? vaccine,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Carrega o animal
      final animalsState = ref.read(animalsProvider);
      final animal = animalsState.animals.firstWhere(
        (a) => a.id == animalId,
        orElse: () => throw Exception('Animal não encontrado'),
      );
      
      state = state.copyWith(
        animal: animal,
        vaccine: vaccine,
        isInitialized: true,
        isLoading: false,
      );
      
      // Se está editando, carrega os dados
      if (vaccine != null) {
        await loadFromVaccine(vaccine);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: false,
      );
      rethrow;
    }
  }
  
  /// Carrega dados de uma vacina existente
  Future<void> loadFromVaccine(Vaccine vaccine) async {
    state = state.copyWith(
      name: vaccine.name,
      veterinarian: vaccine.veterinarian,
      batch: vaccine.batch,
      manufacturer: vaccine.manufacturer,
      dosage: vaccine.dosage,
      notes: vaccine.notes,
      date: vaccine.date,
      nextDueDate: vaccine.nextDueDate,
      reminderDate: vaccine.reminderDate,
      status: vaccine.status,
      isRequired: vaccine.isRequired,
    );
  }
  
  /// Limpa o formulário
  void clearForm() {
    state = VaccineFormState.initial();
  }
  
  /// Atualiza campo de texto
  void updateField(String field, String value) {
    switch (field) {
      case 'name':
        state = state.copyWith(name: value, nameError: null);
        break;
      case 'veterinarian':
        state = state.copyWith(veterinarian: value, veterinarianError: null);
        break;
      case 'batch':
        state = state.copyWith(batch: value.isEmpty ? null : value);
        break;
      case 'manufacturer':
        state = state.copyWith(manufacturer: value.isEmpty ? null : value);
        break;
      case 'dosage':
        state = state.copyWith(dosage: value.isEmpty ? null : value);
        break;
      case 'notes':
        state = state.copyWith(notes: value.isEmpty ? null : value);
        break;
    }
  }
  
  /// Atualiza data
  void updateDate(DateTime date) {
    state = state.copyWith(date: date, dateError: null);
  }
  
  /// Atualiza próxima data
  void updateNextDueDate(DateTime? date) {
    state = state.copyWith(nextDueDate: date);
  }
  
  /// Atualiza data de lembrete
  void updateReminderDate(DateTime? date) {
    state = state.copyWith(reminderDate: date);
  }
  
  /// Atualiza status
  void updateStatus(VaccineStatus status) {
    state = state.copyWith(status: status);
  }
  
  /// Atualiza se é obrigatória
  void updateIsRequired(bool isRequired) {
    state = state.copyWith(isRequired: isRequired);
  }
  
  /// Valida o formulário
  bool validate() {
    String? nameError;
    String? veterinarianError;
    String? dateError;
    
    if (state.name.isEmpty) {
      nameError = 'Nome da vacina é obrigatório';
    }
    
    if (state.veterinarian.isEmpty) {
      veterinarianError = 'Veterinário é obrigatório';
    }
    
    if (state.date.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      dateError = 'Data não pode ser mais de 1 ano no futuro';
    }
    
    state = state.copyWith(
      nameError: nameError,
      veterinarianError: veterinarianError,
      dateError: dateError,
    );
    
    return nameError == null && 
           veterinarianError == null && 
           dateError == null;
  }
  
  /// Salva a vacina
  Future<bool> submit() async {
    if (!validate()) return false;
    
    state = state.copyWith(isSaving: true);
    
    try {
      final notifier = ref.read(vaccinesProvider.notifier);
      
      if (state.vaccine != null) {
        // Editando vacina existente
        final updatedVaccine = state.vaccine!.copyWith(
          name: state.name,
          veterinarian: state.veterinarian,
          batch: state.batch,
          manufacturer: state.manufacturer,
          dosage: state.dosage,
          notes: state.notes,
          date: state.date,
          nextDueDate: state.nextDueDate,
          reminderDate: state.reminderDate,
          status: state.status,
          isRequired: state.isRequired,
        );
        
        await notifier.updateVaccine(updatedVaccine);
      } else {
        // Criando nova vacina
        final newVaccine = Vaccine(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          animalId: state.animal!.id,
          name: state.name,
          date: state.date,
          veterinarian: state.veterinarian,
          batch: state.batch,
          manufacturer: state.manufacturer,
          dosage: state.dosage,
          notes: state.notes,
          nextDueDate: state.nextDueDate,
          reminderDate: state.reminderDate,
          isRequired: state.isRequired,
          status: state.status,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await notifier.addVaccine(newVaccine);
      }
      
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
  
  /// Exclui a vacina
  Future<bool> delete() async {
    if (state.vaccine == null) return false;
    
    state = state.copyWith(isSaving: true);
    
    try {
      final notifier = ref.read(vaccinesProvider.notifier);
      await notifier.deleteVaccine(state.vaccine!.id);
      
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
