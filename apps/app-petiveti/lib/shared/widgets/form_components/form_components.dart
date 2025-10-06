/// **PetiVeti Form Components Library**
///
/// Biblioteca completa de componentes de formulário reutilizáveis para o app PetiVeti.
/// Inspirada no sucesso da componentização do app-gasometer.
///
/// ## 🎯 Objetivo
/// Reduzir duplicação de código, aumentar consistência visual e melhorar
/// a manutenibilidade dos formulários através de componentes padronizados.
///
/// ## 📦 Componentes Incluídos
///
/// ### **Campos (Fields)**
/// - `AnimalSelectorField`: Seleção de animais com interface rica
/// - `DateTimePickerField`: Pickers de data/hora unificados
/// - `NotesField`: Campos de observações padronizados
/// - `TypeDropdownField`: Dropdowns com ícones e cores
///
/// ### **Seções (Sections)**
/// - `FormSubmitSection`: Botões de submit/cancel consistentes
///
/// ## 🚀 Uso
///
/// ```dart
/// // Importação única
/// import 'package:app_petiveti/shared/widgets/form_components/form_components.dart';
///
/// // Uso direto dos componentes
/// AnimalSelectorField.required(
///   value: selectedAnimalId,
///   onChanged: (id) => setState(() => selectedAnimalId = id),
/// )
///
/// DateTimePickerField.birthDate(
///   value: birthDate,
///   onChanged: (date) => setState(() => birthDate = date),
/// )
///
/// NotesField.general(
///   controller: notesController,
/// )
///
/// FormSubmitSection.create(
///   onSubmit: _handleSubmit,
///   isLoading: isSubmitting,
///   itemName: 'Pet',
/// )
/// ```
///
/// ## 📈 Benefícios Esperados
/// - **Redução de 40-60% do código**: Baseado no sucesso do gasometer
/// - **Consistência Visual**: Interface unificada entre formulários
/// - **Manutenibilidade**: Mudanças centralizadas
/// - **Produtividade**: Desenvolvimento mais rápido
/// - **Qualidade**: Componentes testados e validados
///
/// @author PetiVeti Development Team
/// @since 1.0.0
library;

import 'package:flutter/material.dart';

import 'fields/animal_selector_field.dart';
import 'fields/date_time_picker_field.dart';
import 'fields/notes_field.dart';
import 'fields/type_dropdown_field.dart';
import 'sections/form_submit_section.dart';

/// Componentes originais do FormComponents
export '../form_components.dart';
/// Seleção de animais com interface rica
export 'fields/animal_selector_field.dart';
/// Pickers de data/hora unificados
export 'fields/date_time_picker_field.dart';
/// Campos de observações padronizados
export 'fields/notes_field.dart';
/// Dropdowns com ícones e cores
export 'fields/type_dropdown_field.dart';
/// Seções de submit/cancel consistentes
export 'sections/form_submit_section.dart';

/// **PetiVeti Form Components**
///
/// Classe principal que agrupa todos os componentes para fácil acesso.
/// Oferece métodos estáticos para criação rápida de componentes comuns.
class PetiVetiFormComponents {
  PetiVetiFormComponents._();

  /// Seletor de animal obrigatório
  static Widget animalRequired({
    String? value,
    ValueChanged<String?>? onChanged,
    String? label,
  }) {
    return AnimalSelectorFieldExtensions.required(
      value: value,
      onChanged: onChanged,
      label: label ?? 'Animal',
    );
  }

  /// Seletor de animal opcional
  static Widget animalOptional({
    String? value,
    ValueChanged<String?>? onChanged,
    String? label,
  }) {
    return AnimalSelectorFieldExtensions.optional(
      value: value,
      onChanged: onChanged,
      label: label ?? 'Animal (Opcional)',
    );
  }

  /// Data de nascimento
  static Widget birthDate({
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
  }) {
    return DateTimePickerFieldExtensions.birthDate(
      value: value,
      onChanged: onChanged,
    );
  }

  /// Agendamento
  static Widget appointment({
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
  }) {
    return DateTimePickerFieldExtensions.appointment(
      value: value,
      onChanged: onChanged,
    );
  }

  /// Período de tratamento
  static Widget treatmentPeriod({
    DateTime? startValue,
    DateTime? endValue,
    void Function(DateTime? start, DateTime? end)? onRangeChanged,
  }) {
    return DateTimePickerFieldExtensions.treatmentPeriod(
      startValue: startValue,
      endValue: endValue,
      onRangeChanged: onRangeChanged,
    );
  }

  /// Observações gerais
  static Widget notesGeneral({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool isRequired = false,
  }) {
    return NotesFieldVariants.general(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  /// Observações médicas
  static Widget notesMedical({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool isRequired = false,
  }) {
    return NotesFieldVariants.medical(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  /// Observações de tratamento
  static Widget notesTreatment({
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool isRequired = false,
  }) {
    return NotesFieldVariants.treatment(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  /// Seção para criar
  static Widget submitCreate({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
    String? itemName,
  }) {
    return FormSubmitSectionVariants.create(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
      itemName: itemName,
    );
  }

  /// Seção para editar
  static Widget submitUpdate({
    required VoidCallback? onSubmit,
    VoidCallback? onCancel,
    bool isLoading = false,
  }) {
    return FormSubmitSectionVariants.update(
      onSubmit: onSubmit,
      onCancel: onCancel,
      isLoading: isLoading,
    );
  }

  /// Seção simples
  static Widget submitSimple({
    required VoidCallback? onSubmit,
    bool isLoading = false,
    String? text,
    IconData? icon,
  }) {
    return FormSubmitSectionVariants.simple(
      onSubmit: onSubmit,
      isLoading: isLoading,
      text: text,
      icon: icon,
    );
  }

  /// Dropdown de prioridade
  static Widget priorityDropdown({
    String? value,
    ValueChanged<String?>? onChanged,
    String? label,
    bool isRequired = false,
  }) {
    return PriorityDropdownField(
      value: value,
      onChanged: onChanged,
      label: label,
      isRequired: isRequired,
    );
  }

  /// Dropdown de tipo de lembrete
  static Widget reminderTypeDropdown({
    String? value,
    ValueChanged<String?>? onChanged,
    String? label,
    bool isRequired = false,
  }) {
    return ReminderTypeDropdownField(
      value: value,
      onChanged: onChanged,
      label: label,
      isRequired: isRequired,
    );
  }

  /// Dropdown de tipo de medicamento
  static Widget medicationTypeDropdown({
    String? value,
    ValueChanged<String?>? onChanged,
    String? label,
    bool isRequired = false,
  }) {
    return MedicationTypeDropdownField(
      value: value,
      onChanged: onChanged,
      label: label,
      isRequired: isRequired,
    );
  }
}

/// Alias para facilitar importação
typedef PVC = PetiVetiFormComponents;
