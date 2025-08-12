// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/odometro_cadastro_form_controller.dart';
import '../helpers/odometro_ui_helper.dart';
import '../models/odometro_constants.dart';

class OdometroCadastroFormView extends GetView<OdometroCadastroFormController> {
  const OdometroCadastroFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OdometroCadastroFormController>(
      builder: (controller) => Stack(
        children: [
          Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInformacoesBasicasSection(),
                SizedBox(height: OdometroConstants.dimensions['fieldSpacing']!),
                _buildAdicionaisSection(),
              ],
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildInformacoesBasicasSection() {
    return Column(
      children: [
        _buildSectionHeader(
          OdometroConstants.sectionTitles['informacoesBasicas']!,
          OdometroConstants.sectionIcons['informacoesBasicas']!,
        ),
        Card(
          elevation: OdometroConstants.dimensions['cardElevation']!,
          margin: EdgeInsets.only(
              bottom: OdometroConstants.dimensions['cardMarginBottom']!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                OdometroConstants.dimensions['cardBorderRadius']!),
            side: BorderSide(color: ShadcnStyle.borderColor),
          ),
          child: Padding(
            padding:
                EdgeInsets.all(OdometroConstants.dimensions['cardPadding']!),
            child: Column(
              children: [
                SizedBox(height: OdometroConstants.dimensions['fieldSpacing']!),
                _buildOdometroField(),
                SizedBox(height: OdometroConstants.dimensions['fieldSpacing']!),
                _buildDataRegistroField(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdicionaisSection() {
    return Column(
      children: [
        SizedBox(height: OdometroConstants.dimensions['sectionPadding']!),
        _buildSectionHeader(
          OdometroConstants.sectionTitles['adicionais']!,
          OdometroConstants.sectionIcons['adicionais']!,
        ),
        Card(
          elevation: OdometroConstants.dimensions['cardElevation']!,
          margin: EdgeInsets.only(
              bottom: OdometroConstants.dimensions['cardMarginBottom']!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                OdometroConstants.dimensions['cardBorderRadius']!),
            side: BorderSide(color: ShadcnStyle.borderColor),
          ),
          child: Padding(
            padding:
                EdgeInsets.all(OdometroConstants.dimensions['cardPadding']!),
            child: _buildDescricaoField(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        OdometroConstants.dimensions['fieldSpacing']!,
        OdometroConstants.dimensions['sectionPadding']!,
        OdometroConstants.dimensions['fieldSpacing']!,
        OdometroConstants.dimensions['sectionPadding']!,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: OdometroConstants.dimensions['iconSize']!,
            color: ShadcnStyle.mutedTextColor,
          ),
          SizedBox(width: OdometroConstants.dimensions['sectionPadding']!),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometroField() {
    return Obx(() {
      // Usar Obx para tornar o campo reativo
      final TextEditingController textController = TextEditingController(
        text: controller.odometer.value > 0 ? controller.formattedOdometer : '',
      );
      // Mover o cursor para o final do texto
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );

      return TextFormField(
        controller: textController,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: ShadcnStyle.inputDecoration(
          label: OdometroConstants.fieldLabels['odometro']!,
          suffix: OdometroConstants.units['odometro']!,
          hint: OdometroConstants.fieldHints['odometro']!,
          suffixIcon: controller.odometer.value > 0
              ? IconButton(
                  iconSize: OdometroConstants.dimensions['clearIconSize']!,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(OdometroConstants.sectionIcons['clear']!),
                  onPressed: () => controller.clearOdometer(),
                )
              : null,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(OdometroConstants.numberRegex),
          TextInputFormatter.withFunction((oldValue, newValue) {
            // Handle decimal places limit
            final text = newValue.text.replaceAll('.', ',');
            if (text.contains(',')) {
              final parts = text.split(',');
              if (parts.length == 2 &&
                  parts[1].length > OdometroConstants.decimalPlaces) {
                return TextEditingValue(
                  text:
                      '${parts[0]},${parts[1].substring(0, OdometroConstants.decimalPlaces)}',
                  selection:
                      TextSelection.collapsed(offset: parts[0].length + 3),
                );
              }
            }
            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }),
        ],
        validator: controller.validateOdometer,
        onSaved: (value) {
          if (value?.isNotEmpty ?? false) {
            controller.setOdometerFromString(value!);
          }
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            controller.setOdometerFromString(value);
          } else {
            controller.setOdometer(0.0);
          }
        },
      );
    });
  }

  Widget _buildDataRegistroField() {
    return GetBuilder<OdometroCadastroFormController>(
        id: 'date_field',
        builder: (controller) {
          final currentDate = controller.registrationDateTime;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: OdometroConstants.dimensions['sectionPadding']!),
              InputDecorator(
                decoration: ShadcnStyle.inputDecoration(
                  label: OdometroConstants.fieldLabels['dataHora']!,
                  suffixIcon: Icon(
                    OdometroConstants.sectionIcons['dataHora']!,
                    size: OdometroConstants.dimensions['calendarIconSize']!,
                    color: ShadcnStyle.labelColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date picker
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date =
                              await OdometroUIHelper.showDatePickerDialog(
                            Get.context!,
                            currentDate,
                          );
                          if (date != null) {
                            controller.selectDate(date);
                          }
                        },
                        child: Text(OdometroUIHelper.formatDate(currentDate)),
                      ),
                    ),
                    SizedBox(
                        width: OdometroConstants.dimensions['dividerSpacing']!),
                    Container(
                      height:
                          OdometroConstants.dimensions['timePickerSpacing']!,
                      width: OdometroConstants.dimensions['dividerWidth']!,
                      color: ShadcnStyle.borderColor,
                    ),
                    // Time picker
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time =
                              await OdometroUIHelper.showTimePickerDialog(
                            Get.context!,
                            currentDate,
                          );
                          if (time != null) {
                            controller.selectTime(time.hour, time.minute);
                          }
                        },
                        child: Text(
                          OdometroUIHelper.formatTime(currentDate),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildDescricaoField() {
    return Obx(() {
      final TextEditingController textController = TextEditingController(
        text: controller.description.value,
      );
      // Mover o cursor para o final do texto
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );

      return TextFormField(
        controller: textController,
        maxLength: OdometroConstants.maxDescriptionLength,
        maxLines: OdometroConstants.descriptionMaxLines,
        decoration: ShadcnStyle.inputDecoration(
          label: OdometroConstants.fieldLabels['descricao']!,
          hint: OdometroConstants.fieldHints['descricao']!,
          showCounter: true,
        ),
        validator: controller.validateDescription,
        onSaved: (value) => controller.setDescription(value?.trim() ?? ''),
        onChanged: (value) => controller.setDescription(value),
      );
    });
  }
}
