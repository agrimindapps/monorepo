// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/lembrete_form_controller.dart';
import '../styles/form_colors.dart';

class LembreteFormFields extends StatelessWidget {
  final LembreteFormController controller;

  const LembreteFormFields({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloField(),
        const SizedBox(height: 16),
        _buildDescricaoField(),
        const SizedBox(height: 16),
        _buildDataField(),
        const SizedBox(height: 16),
        _buildHoraField(),
        const SizedBox(height: 16),
        _buildTipoField(),
        const SizedBox(height: 16),
        _buildRepetirField(),
        const SizedBox(height: 16),
        _buildConcluidoField(),
      ],
    );
  }

  Widget _buildTituloField() {
    return Obx(() => _buildTextField(
          label: 'Título',
          hint: 'Digite o título do lembrete',
          initialValue: controller.formModel.value.titulo,
          maxLength: 50,
          textCapitalization: TextCapitalization.words,
          validator: controller.validateTitulo,
          onSaved: (value) => controller.updateTitulo(value ?? ''),
          onChanged: (value) => controller.updateTitulo(value),
          errorText: controller.fieldErrors['titulo'],
        ));
  }

  Widget _buildDescricaoField() {
    return Obx(() => _buildTextField(
          label: 'Descrição',
          hint: 'Digite a descrição do lembrete',
          initialValue: controller.formModel.value.descricao,
          maxLength: 80,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: controller.validateDescricao,
          onSaved: (value) => controller.updateDescricao(value ?? ''),
          onChanged: (value) => controller.updateDescricao(value),
          errorText: controller.fieldErrors['descricao'],
        ));
  }

  Widget _buildDataField() {
    return Obx(() => _buildDateField(
          label: 'Data',
          initialDate: controller.formModel.value.dataLembrete,
          firstDate: DateTime.now(),
          onDateSelected: (date) => controller.updateDataLembrete(date),
          errorText: controller.fieldErrors['dataHora'],
        ));
  }

  Widget _buildHoraField() {
    return Obx(() => _buildTimeField(
          label: 'Hora',
          initialTime: controller.formModel.value.horaLembrete,
          onTimeSelected: (time) => controller.updateHoraLembrete(time),
          errorText: controller.fieldErrors['dataHora'],
        ));
  }

  Widget _buildTipoField() {
    return Obx(() => _buildDropdownField<String>(
          label: 'Tipo',
          initialValue: controller.formModel.value.tipo,
          items: controller.tiposOptions,
          itemLabelBuilder: (item) => item,
          onChanged: (value) => controller.updateTipo(value!),
          onSaved: (value) => controller.updateTipo(value!),
        ));
  }

  Widget _buildRepetirField() {
    return Obx(() => _buildDropdownField<String>(
          label: 'Repetir',
          initialValue: controller.formModel.value.repetir,
          items: controller.repeticoesOptions,
          itemLabelBuilder: (item) => item,
          onChanged: (value) => controller.updateRepetir(value!),
          onSaved: (value) => controller.updateRepetir(value!),
        ));
  }

  Widget _buildConcluidoField() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: LembreteFormColors.fieldBackground,
            border: Border.all(color: LembreteFormColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Concluído',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: LembreteFormColors.textPrimary,
                ),
              ),
              Switch(
                value: controller.formModel.value.concluido,
                onChanged: (bool value) => controller.updateConcluido(value),
                activeColor: LembreteFormColors.primaryColor,
                activeTrackColor: LembreteFormColors.primaryWithOpacity,
              ),
            ],
          ),
        ));
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LembreteFormColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLength: maxLength,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: LembreteFormColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderFocus),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderError),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime initialDate,
    required DateTime firstDate,
    required void Function(DateTime) onDateSelected,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LembreteFormColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: LembreteFormColors.fieldBackground,
              border: Border.all(
                color: errorText != null
                    ? LembreteFormColors.borderError
                    : LembreteFormColors.borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: LembreteFormColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.formModel.value.formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: LembreteFormColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              color: LembreteFormColors.errorColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay initialTime,
    required void Function(TimeOfDay) onTimeSelected,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LembreteFormColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: Get.context!,
              initialTime: initialTime,
            );
            if (time != null) {
              onTimeSelected(time);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: LembreteFormColors.fieldBackground,
              border: Border.all(
                color: errorText != null
                    ? LembreteFormColors.borderError
                    : LembreteFormColors.borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: LembreteFormColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.formModel.value.formattedTime,
                  style: const TextStyle(
                    fontSize: 14,
                    color: LembreteFormColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              color: LembreteFormColors.errorColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T initialValue,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    required void Function(T?) onChanged,
    required void Function(T?) onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LembreteFormColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: initialValue,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: const TextStyle(
                  fontSize: 14,
                  color: LembreteFormColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          onSaved: onSaved,
          decoration: InputDecoration(
            filled: true,
            fillColor: LembreteFormColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: LembreteFormColors.borderFocus),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }
}
