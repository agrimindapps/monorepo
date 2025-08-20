// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../constants/lembrete_form_constants.dart';
import '../../controllers/lembrete_form_controller.dart';
import 'form_section_widget.dart';

/// Widget aprimorado dos campos do formulário com estrutura em seções
class EnhancedLembreteFormFields extends StatelessWidget {
  final LembreteFormController controller;

  const EnhancedLembreteFormFields({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seção 1: Informações Básicas
        LembreteFormSectionWidget(
          title: LembreteFormConstants.basicInfoTitle,
          icon: LembreteFormConstants.basicInfoIcon,
          color: LembreteFormConstants.basicInfoColor,
          children: [
            _buildTituloField(),
            const SizedBox(height: LembreteFormConstants.fieldSpacing),
            _buildDescricaoField(),
            const SizedBox(height: LembreteFormConstants.fieldSpacing),
            _buildTipoField(),
          ],
        ),
        
        const SizedBox(height: LembreteFormConstants.sectionSpacing),
        
        // Seção 2: Agendamento
        LembreteFormSectionWidget(
          title: LembreteFormConstants.schedulingTitle,
          icon: LembreteFormConstants.schedulingIcon,
          color: LembreteFormConstants.schedulingColor,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDataField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHoraField(),
                ),
              ],
            ),
            const SizedBox(height: LembreteFormConstants.fieldSpacing),
            _buildRepetirField(),
          ],
        ),
        
        const SizedBox(height: LembreteFormConstants.sectionSpacing),
        
        // Seção 3: Status
        LembreteFormSectionWidget(
          title: LembreteFormConstants.statusTitle,
          icon: LembreteFormConstants.statusIcon,
          color: LembreteFormConstants.statusColor,
          children: [
            _buildConcluidoField(),
          ],
        ),
      ],
    );
  }

  Widget _buildTituloField() {
    return Obx(() => _buildTextField(
          label: LembreteFormConstants.tituloLabel,
          hint: LembreteFormConstants.tituloHint,
          initialValue: controller.formModel.value.titulo,
          maxLength: LembreteFormConstants.tituloMaxLength,
          textCapitalization: TextCapitalization.words,
          validator: controller.validateTitulo,
          onSaved: (value) => controller.updateTitulo(value ?? ''),
          onChanged: (value) => controller.updateTitulo(value),
          errorText: controller.fieldErrors['titulo'],
          prefixIcon: Icons.title,
        ));
  }

  Widget _buildDescricaoField() {
    return Obx(() => _buildTextField(
          label: LembreteFormConstants.descricaoLabel,
          hint: LembreteFormConstants.descricaoHint,
          initialValue: controller.formModel.value.descricao,
          maxLength: LembreteFormConstants.descricaoMaxLength,
          maxLines: LembreteFormConstants.descricaoMaxLines,
          textCapitalization: TextCapitalization.sentences,
          validator: controller.validateDescricao,
          onSaved: (value) => controller.updateDescricao(value ?? ''),
          onChanged: (value) => controller.updateDescricao(value),
          errorText: controller.fieldErrors['descricao'],
          prefixIcon: Icons.description,
        ));
  }

  Widget _buildDataField() {
    return Obx(() => _buildDateField(
          label: LembreteFormConstants.dataLabel,
          initialValue: controller.formModel.value.dataLembrete,
          onDateSelected: controller.updateDataLembrete,
          errorText: controller.fieldErrors['dataLembrete'],
        ));
  }

  Widget _buildHoraField() {
    return Obx(() => _buildTimeField(
          label: LembreteFormConstants.horaLabel,
          initialValue: controller.formModel.value.horaLembrete,
          onTimeSelected: controller.updateHoraLembrete,
          errorText: controller.fieldErrors['horaLembrete'],
        ));
  }

  Widget _buildTipoField() {
    return Obx(() => _buildDropdownField(
          label: LembreteFormConstants.tipoLabel,
          value: controller.formModel.value.tipo,
          items: controller.tiposOptions,
          onChanged: (value) => controller.updateTipo(value ?? ''),
          errorText: controller.fieldErrors['tipo'],
          prefixIcon: Icons.category,
        ));
  }

  Widget _buildRepetirField() {
    return Obx(() => _buildDropdownField(
          label: LembreteFormConstants.repetirLabel,
          value: controller.formModel.value.repetir,
          items: controller.repeticoesOptions,
          onChanged: (value) => controller.updateRepetir(value ?? ''),
          errorText: controller.fieldErrors['repetir'],
          prefixIcon: Icons.repeat,
        ));
  }

  Widget _buildConcluidoField() {
    return Obx(() => _buildSwitchField(
          label: LembreteFormConstants.concluidoLabel,
          value: controller.formModel.value.concluido,
          onChanged: controller.updateConcluido,
        ));
  }

  // Métodos auxiliares para construir os campos
  Widget _buildTextField({
    required String label,
    required String hint,
    required String? initialValue,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    required void Function(String) onChanged,
    required String? errorText,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorText: errorText,
        counterText: maxLength != null ? null : '',
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? initialValue,
    required void Function(DateTime) onDateSelected,
    required String? errorText,
  }) {
    return InkWell(
      onTap: () => _selectDate(onDateSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorText: errorText,
        ),
        child: Text(
          initialValue != null
              ? DateFormat('dd/MM/yyyy').format(initialValue)
              : 'Selecione uma data',
          style: TextStyle(
            color: initialValue != null ? null : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? initialValue,
    required void Function(TimeOfDay) onTimeSelected,
    required String? errorText,
  }) {
    return InkWell(
      onTap: () => _selectTime(onTimeSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorText: errorText,
        ),
        child: Text(
          initialValue != null
              ? '${initialValue.hour.toString().padLeft(2, '0')}:${initialValue.minute.toString().padLeft(2, '0')}'
              : 'Selecione um horário',
          style: TextStyle(
            color: initialValue != null ? null : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? errorText,
    IconData? prefixIcon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorText: errorText,
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: LembreteFormConstants.statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: LembreteFormConstants.statusColor,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(void Function(DateTime) onDateSelected) async {
    final context = Get.context!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(void Function(TimeOfDay) onTimeSelected) async {
    final context = Get.context!;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
