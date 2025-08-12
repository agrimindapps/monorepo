// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/enums.dart';
import '../../../../widgets/form/dropdown_field_widget.dart';
import '../../../../widgets/form/form_section_widget.dart';
import '../controller/veiculos_cadastro_form_controller.dart';
import '../models/veiculos_constants.dart';
import '../services/veiculo_formatter_service.dart';
import '../widgets/veiculo_photo_picker.dart';

/// View responsável pela renderização do formulário de cadastro de veículos
///
/// Implementa a interface do usuário para cadastro e edição de veículos,
/// organizando os campos em seções lógicas e aplicando validações.
class VeiculosCadastroFormView extends StatefulWidget {
  const VeiculosCadastroFormView({super.key});

  @override
  State<VeiculosCadastroFormView> createState() =>
      _VeiculosCadastroFormViewState();
}

class _VeiculosCadastroFormViewState extends State<VeiculosCadastroFormView> {
  late final VeiculosCadastroFormController controller;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _corController;
  late final TextEditingController _odometroController;
  late final TextEditingController _placaController;
  late final TextEditingController _chassiController;
  late final TextEditingController _renavamController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VeiculosCadastroFormController>();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _corController = TextEditingController();
    _odometroController = TextEditingController();
    _placaController = TextEditingController();
    _chassiController = TextEditingController();
    _renavamController = TextEditingController();

    _initializeControllers();
  }

  void _initializeControllers() {
    _marcaController.text = controller.marca.value;
    _modeloController.text = controller.modelo.value;
    _corController.text = controller.cor.value;
    _placaController.text = controller.placa.value;
    _chassiController.text = controller.chassi.value;
    _renavamController.text = controller.renavam.value;

    final odometroValue = controller.odometroInicial.value;
    _odometroController.text = odometroValue > 0
        ? odometroValue.toStringAsFixed(2).replaceAll('.', ',')
        : '';
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _corController.dispose();
    _odometroController.dispose();
    _placaController.dispose();
    _chassiController.dispose();
    _renavamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdentificationSection(),
          _buildTechnicalInfoSection(),
          _buildDocumentationSection(),
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }

  Widget _buildIdentificationSection() {
    return FormSectionWidget(
      title: VeiculosConstants.titulosSecoes['identificacao']!,
      icon: VeiculosConstants.iconesSecoes['identificacao']!,
      children: [
        _buildMarcaField(),
        const SizedBox(height: 12),
        _buildModeloField(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAnoField()),
            const SizedBox(width: 12),
            Expanded(child: _buildCorField()),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalInfoSection() {
    return FormSectionWidget(
      title: VeiculosConstants.titulosSecoes['informacoesTecnicas']!,
      icon: VeiculosConstants.iconesSecoes['informacoesTecnicas']!,
      children: [
        _buildCombustivelField(),
        const SizedBox(height: 12),
        _buildOdometroField(),
        const SizedBox(height: 12),
        _buildPlacaField(),
      ],
    );
  }

  Widget _buildDocumentationSection() {
    return FormSectionWidget(
      title: VeiculosConstants.titulosSecoes['documentacao']!,
      icon: VeiculosConstants.iconesSecoes['documentacao']!,
      children: [
        _buildChassiField(),
        const SizedBox(height: 12),
        _buildRenavamField(),
      ],
    );
  }

  Widget _buildMarcaField() {
    return Obx(() {
      if (_marcaController.text != controller.marca.value) {
        _marcaController.value = _marcaController.value.copyWith(
          text: controller.marca.value,
          selection:
              TextSelection.collapsed(offset: controller.marca.value.length),
        );
      }

      return TextFormField(
        controller: _marcaController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['marca']!,
          hintText: VeiculosConstants.dicasCampos['marca']!,
        ),
        validator: controller.validateMarca,
        onSaved: (value) => controller.setMarca(value ?? ''),
        onChanged: (value) => controller.setMarca(value),
      );
    });
  }

  Widget _buildModeloField() {
    return Obx(() {
      if (_modeloController.text != controller.modelo.value) {
        _modeloController.value = _modeloController.value.copyWith(
          text: controller.modelo.value,
          selection:
              TextSelection.collapsed(offset: controller.modelo.value.length),
        );
      }

      return TextFormField(
        controller: _modeloController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['modelo']!,
          hintText: VeiculosConstants.dicasCampos['modelo']!,
        ),
        validator: controller.validateModelo,
        onSaved: (value) => controller.setModelo(value ?? ''),
        onChanged: (value) => controller.setModelo(value),
      );
    });
  }

  Widget _buildAnoField() {
    return GetBuilder<VeiculosCadastroFormController>(
      id: 'ano_field',
      builder: (controller) => DropdownFieldWidget<int>(
        label: VeiculosConstants.rotulosCampos['ano']!,
        //value: controller.ano.value > 0 ? controller.ano.value : null,
        items: controller.getYearOptions(),
        itemLabelBuilder: (year) => year.toString(),
        validator: controller.validateAno,
        onChanged: (value) => controller.setAno(value ?? 0),
        onSaved: (value) => controller.setAno(value ?? 0),
      ),
    );
  }

  Widget _buildCorField() {
    return Obx(() {
      if (_corController.text != controller.cor.value) {
        _corController.value = _corController.value.copyWith(
          text: controller.cor.value,
          selection:
              TextSelection.collapsed(offset: controller.cor.value.length),
        );
      }

      return TextFormField(
        controller: _corController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['cor']!,
          hintText: VeiculosConstants.dicasCampos['cor']!,
        ),
        validator: controller.validateCor,
        onSaved: (value) => controller.setCor(value ?? ''),
        onChanged: (value) => controller.setCor(value),
      );
    });
  }

  Widget _buildCombustivelField() {
    return Obx(() {
      // Only observe the specific tipoCombustivel reactive variable
      final selectedCombustivel = controller.tipoCombustivel.value;

      return FormField<TipoCombustivel>(
        initialValue: selectedCombustivel,
        validator: controller.validateCombustivel,
        onSaved: (value) => controller.setTipoCombustivel(value!),
        builder: (FormFieldState<TipoCombustivel> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                VeiculosConstants.rotulosCampos['combustivel']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TipoCombustivel.values.map((tipo) {
                  final bool isSelected = selectedCombustivel == tipo;
                  return InkWell(
                    onTap: () {
                      state.didChange(tipo);
                      controller.setTipoCombustivel(tipo);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ShadcnStyle.focusColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? ShadcnStyle.focusColor
                              : ShadcnStyle.borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.getFuelIcon(tipo),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : ShadcnStyle.mutedTextColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tipo.descricao,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          );
        },
      );
    });
  }

  Widget _buildOdometroField() {
    return Obx(() {
      final odometroValue = controller.odometroInicial.value;
      final possuiLancamentos = controller.possuiLancamentos.value;

      final expectedText = odometroValue > 0
          ? odometroValue.toStringAsFixed(2).replaceAll('.', ',')
          : '';

      if (_odometroController.text != expectedText) {
        _odometroController.value = _odometroController.value.copyWith(
          text: expectedText,
          selection: TextSelection.collapsed(offset: expectedText.length),
        );
      }

      return TextFormField(
        controller: _odometroController,
        enabled: !possuiLancamentos,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['odometroAtual']!,
          hintText: VeiculosConstants.dicasCampos['odometroAtual']!,
          suffixText: VeiculosConstants.sufixos['odometro']!,
          helperText: possuiLancamentos
              ? VeiculosConstants.textosAjuda['odometroComLancamentos']
              : null,
        ),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            final cleanValue = value!.replaceAll(',', '.');
            final number = double.tryParse(cleanValue);
            return controller.validateOdometro(number);
          }
          return controller.validateOdometro(null);
        },
        onSaved: (value) {
          if (value?.isNotEmpty ?? false) {
            final cleanValue = value!.replaceAll(',', '.');
            final number = double.tryParse(cleanValue) ?? 0.0;
            controller.setOdometroInicial(number);
          } else {
            controller.setOdometroInicial(0.0);
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          TextInputFormatter.withFunction((oldValue, newValue) {
            var text = newValue.text.replaceAll('.', ',');
            if (text.contains(',')) {
              final parts = text.split(',');
              if (parts.length == 2 && parts[1].length > 2) {
                text = '${parts[0]},${parts[1].substring(0, 2)}';
              }
            }
            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }),
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            final cleanValue = value.replaceAll(',', '.');
            final number = double.tryParse(cleanValue) ?? 0.0;
            controller.setOdometroInicial(number);
          } else {
            controller.setOdometroInicial(0.0);
          }
        },
      );
    });
  }

  Widget _buildPlacaField() {
    return Obx(() {
      if (_placaController.text != controller.placa.value) {
        _placaController.value = _placaController.value.copyWith(
          text: controller.placa.value,
          selection:
              TextSelection.collapsed(offset: controller.placa.value.length),
        );
      }

      return TextFormField(
        controller: _placaController,
        maxLength: VeiculosConstants.placaComprimento,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: VeiculoFormatterService.placaInputFormatters,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['placa']!,
          hintText: VeiculosConstants.dicasCampos['placa']!,
        ),
        validator: controller.validatePlaca,
        onSaved: (value) => controller.setPlaca((value ?? '').toUpperCase()),
        onChanged: (value) => controller.setPlaca(value.toUpperCase()),
      );
    });
  }

  Widget _buildChassiField() {
    return Obx(() {
      if (_chassiController.text != controller.chassi.value) {
        _chassiController.value = _chassiController.value.copyWith(
          text: controller.chassi.value,
          selection:
              TextSelection.collapsed(offset: controller.chassi.value.length),
        );
      }

      return TextFormField(
        controller: _chassiController,
        maxLength: VeiculosConstants.chassiComprimento,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: VeiculoFormatterService.chassiInputFormatters,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['chassi']!,
          hintText: VeiculosConstants.dicasCampos['chassi']!,
        ),
        validator: controller.validateChassi,
        onSaved: (value) => controller.setChassi((value ?? '').toUpperCase()),
        onChanged: (value) => controller.setChassi(value.toUpperCase()),
      );
    });
  }

  Widget _buildRenavamField() {
    return Obx(() {
      if (_renavamController.text != controller.renavam.value) {
        _renavamController.value = _renavamController.value.copyWith(
          text: controller.renavam.value,
          selection:
              TextSelection.collapsed(offset: controller.renavam.value.length),
        );
      }

      return TextFormField(
        controller: _renavamController,
        maxLength: VeiculosConstants.renavamComprimento,
        keyboardType: TextInputType.number,
        inputFormatters: VeiculoFormatterService.renavamInputFormatters,
        decoration: InputDecoration(
          labelText: VeiculosConstants.rotulosCampos['renavam']!,
          hintText: VeiculosConstants.dicasCampos['renavam']!,
        ),
        onSaved: (value) => controller.setRenavam(value ?? ''),
        onChanged: (value) => controller.setRenavam(value),
      );
    });
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      children: [
        VeiculoPhotoPicker(
          initialPhotoPath: controller.foto.value,
          onPhotoChanged: (photoPath) => controller.setFoto(photoPath),
          isRequired: false,
        ),
      ],
    );
  }
}
