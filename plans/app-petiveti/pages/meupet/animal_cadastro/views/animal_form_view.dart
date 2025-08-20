// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../widgets/form/form_section_widget.dart';
import '../constants/animal_form_constants.dart';
import '../controllers/animal_form_controller.dart';
import '../widgets/web_compatible_photo_picker.dart';

class AnimalFormView extends StatefulWidget {
  final Animal? animal;

  const AnimalFormView({super.key, this.animal});

  @override
  AnimalFormViewState createState() => AnimalFormViewState();
}

class AnimalFormViewState extends State<AnimalFormView> {
  late AnimalFormController controller;
  late String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'animal_form_${DateTime.now().millisecondsSinceEpoch}';

    if (!Get.isRegistered<AnimalFormController>(tag: _controllerTag)) {
      Get.lazyPut<AnimalFormController>(
        () => AnimalFormController(),
        tag: _controllerTag,
        fenix: true,
      );
    }

    controller = Get.find<AnimalFormController>(tag: _controllerTag);
    controller.initializeForm(widget.animal);
  }

  Future<bool> submitForm() async {
    return await controller.submitForm();
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = controller.formModel.value.dataNascimento > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            controller.formModel.value.dataNascimento)
        : DateTime.now().subtract(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (selectedDate != null) {
      controller.updateDataNascimento(selectedDate.millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seção Identificação
                  _buildIdentificationSection(),
                  const SizedBox(height: AnimalFormConstants.sectionSpacing),

                  // Seção Informações Físicas
                  _buildPhysicalInfoSection(),
                  const SizedBox(height: AnimalFormConstants.sectionSpacing),

                  // Seção Informações Adicionais
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: 8),

                  // Mensagem de erro e sucesso
                  _buildStatusMessages(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildIdentificationSection() {
    return FormSectionWidget(
      title: AnimalFormConstants.titulosSecoes['identificacao']!,
      icon: AnimalFormConstants.iconesSecoes['identificacao']!,
      children: [
        TextFormField(
          initialValue: controller.formModel.value.nome,
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['nome']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['nome'],
          ),
          validator: controller.validateNome,
          onSaved: (value) => controller.updateNome(value ?? ''),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        DropdownButtonFormField<String>(
          value: controller.formModel.value.especie.isEmpty
              ? null
              : controller.formModel.value.especie,
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['especie']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['especie'],
          ),
          items: controller.especiesOptions.keys.map((String especie) {
            return DropdownMenuItem<String>(
              value: especie,
              child: Row(
                children: [
                  Text(controller.getEspeciesWithIcons()[especie] ?? ''),
                  const SizedBox(width: 8),
                  Text(especie),
                ],
              ),
            );
          }).toList(),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Selecione uma espécie' : null,
          onChanged: (value) {
            if (value != null) {
              controller.updateEspecie(value);
            }
          },
          onSaved: (value) => controller.updateEspecie(value ?? ''),
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        TextFormField(
          initialValue: controller.formModel.value.raca,
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['raca']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['raca'],
          ),
          validator: controller.validateRaca,
          onSaved: (value) => controller.updateRaca(value ?? ''),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        TextFormField(
          initialValue: controller.formModel.value.cor,
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['cor']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['cor'],
          ),
          validator: controller.validateCor,
          onSaved: (value) => controller.updateCor(value ?? ''),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return FormSectionWidget(
      title: AnimalFormConstants.titulosSecoes['informacoes_fisicas']!,
      icon: AnimalFormConstants.iconesSecoes['informacoes_fisicas']!,
      children: [
        DropdownButtonFormField<String>(
          value: controller.formModel.value.sexo.isEmpty
              ? null
              : controller.formModel.value.sexo,
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['sexo']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['sexo'],
          ),
          items: controller.sexoOptions.map((String sexo) {
            return DropdownMenuItem<String>(
              value: sexo,
              child: Row(
                children: [
                  Icon(
                    sexo == 'Macho' ? Icons.male : Icons.female,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(sexo),
                ],
              ),
            );
          }).toList(),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Selecione o sexo' : null,
          onChanged: (value) {
            if (value != null) {
              controller.updateSexo(value);
            }
          },
          onSaved: (value) => controller.updateSexo(value ?? ''),
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        TextFormField(
          initialValue: controller.formModel.value.dataNascimento > 0
              ? _formatDate(controller.formModel.value.dataNascimento)
              : '',
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['data_nascimento']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['data_nascimento'],
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) => value?.isEmpty ?? true
              ? 'Selecione a data de nascimento'
              : null,
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        TextFormField(
          initialValue: controller.formModel.value.pesoAtual > 0
              ? controller.formModel.value.pesoAtual.toString()
              : '',
          decoration: InputDecoration(
            labelText: '${AnimalFormConstants.rotulosCampos['peso_atual']} *',
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['peso_atual'],
            suffixText: 'kg',
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          validator: controller.validatePesoAtual,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              controller
                  .updatePesoAtual(controller.parseWeight(value!));
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: AnimalFormConstants.titulosSecoes['informacoes_adicionais']!,
      icon: AnimalFormConstants.iconesSecoes['informacoes_adicionais']!,
      children: [
        WebCompatiblePhotoPicker(
          initialPhotoPath: controller.formModel.value.foto,
          onPhotoChanged: (photoPath) => controller.updateFoto(photoPath),
          isRequired: false,
        ),
        const SizedBox(height: AnimalFormConstants.fieldSpacing),
        TextFormField(
          initialValue: controller.formModel.value.observacoes,
          decoration: InputDecoration(
            labelText: AnimalFormConstants.rotulosCampos['observacoes'],
            border: const OutlineInputBorder(),
            hintText: AnimalFormConstants.dicasCampos['observacoes'],
            alignLabelWithHint: true,
          ),
          maxLines: AnimalFormConstants.maxLinhasObservacoes,
          maxLength: AnimalFormConstants.maxObservacoesLength,
          onSaved: (value) => controller.updateObservacoes(value),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildStatusMessages() {
    return Obx(() {
      final formState = controller.formState.value;
      
      if (formState.hasError && formState.errorMessage != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formState.errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        );
      }
      
      if (formState.hasSuccess && formState.successMessage != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formState.successMessage!,
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ),
            ],
          ),
        );
      }
      
      return const SizedBox.shrink();
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<AnimalFormController>(tag: _controllerTag)) {
      Get.delete<AnimalFormController>(tag: _controllerTag);
    }
    super.dispose();
  }
}
