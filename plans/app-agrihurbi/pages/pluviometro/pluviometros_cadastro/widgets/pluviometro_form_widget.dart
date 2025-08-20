// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../components/form_field_components.dart';
import '../controllers/pluviometro_cadastro_controller.dart';
import '../state/form_state_manager.dart';
import '../utils/responsive_layout.dart';
import '../validators/form_field_validators.dart';

class PluviometroFormWidget extends StatefulWidget {
  final Pluviometro? pluviometro;

  const PluviometroFormWidget({super.key, this.pluviometro});

  @override
  PluviometroFormWidgetState createState() => PluviometroFormWidgetState();
}

class PluviometroFormWidgetState extends State<PluviometroFormWidget> {
  late final PluviometroCadastroController controller;
  late final FormStateManager formStateManager;
  late final FormBuilder formBuilder;

  @override
  void initState() {
    super.initState();
    controller = PluviometroCadastroController();
    formStateManager = FormStateManager();
    formBuilder = FormBuilder(formKey: controller.formKey);

    controller.init(widget.pluviometro);
    _initializeFormState();
  }

  @override
  void dispose() {
    controller.dispose();
    formStateManager.dispose();
    super.dispose();
  }

  void _initializeFormState() {
    if (widget.pluviometro != null) {
      formStateManager.populate({
        'descricao': widget.pluviometro!.descricao,
        'quantidade': widget.pluviometro!.quantidade,
        'latitude': widget.pluviometro!.latitude,
        'longitude': widget.pluviometro!.longitude,
        'fkGrupo': widget.pluviometro!.fkGrupo,
      });
    }
  }

  Future<void> submit() async {
    final success = await controller.submit(context, widget.pluviometro);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: RepaintBoundary(
          child: Column(
            children: [
              // Seção de informações básicas
              RepaintBoundary(
                child: _buildBasicInfoSection(),
              ),

              ResponsiveSpacer(
                  customSize: ResponsiveLayout.getSectionSpacing(context)),

              // Seção de localização
              RepaintBoundary(
                child: _buildLocationSection(),
              ),

              ResponsiveSpacer(
                  customSize: ResponsiveLayout.getSectionSpacing(context)),

              // Seção de configurações
              RepaintBoundary(
                child: _buildConfigSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FormFieldComponents.section(
      title: 'Informações Básicas',
      children: [
        ValueListenableBuilder<String>(
          valueListenable: formStateManager.getFieldNotifier('descricao'),
          builder: (context, value, child) {
            return FormFieldComponents.descricaoField(
              validator: FormFieldValidators.validateDescricao,
              onSaved: (value) => controller.descricao = value!,
              initialValue: controller.descricao,
              onChanged: (value) =>
                  formStateManager.setFieldValue('descricao', value),
            );
          },
        ),
        FormFieldComponents.spacer(),
        ValueListenableBuilder<String>(
          valueListenable: formStateManager.getFieldNotifier('quantidade'),
          builder: (context, value, child) {
            return FormFieldComponents.quantidadeField(
              validator: FormFieldValidators.validateQuantidade,
              onSaved: (value) {
                if (value?.isNotEmpty ?? false) {
                  controller.quantidade = double.parse(value!);
                }
              },
              controller: controller.quantidadeController,
              onChanged: (value) =>
                  formStateManager.setFieldValue('quantidade', value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return FormFieldComponents.section(
      title: 'Localização (Opcional)',
      children: [
        ResponsiveWidget(
          mobile: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: formStateManager.getFieldNotifier('latitude'),
                builder: (context, value, child) {
                  return FormFieldComponents.latitudeField(
                    validator: FormFieldValidators.validateLatitude,
                    onSaved: (value) =>
                        formStateManager.setFieldValue('latitude', value),
                    initialValue: widget.pluviometro?.latitude ?? '',
                    onChanged: (value) =>
                        formStateManager.setFieldValue('latitude', value),
                  );
                },
              ),
              FormFieldComponents.spacer(),
              ValueListenableBuilder<String>(
                valueListenable: formStateManager.getFieldNotifier('longitude'),
                builder: (context, value, child) {
                  return FormFieldComponents.longitudeField(
                    validator: FormFieldValidators.validateLongitude,
                    onSaved: (value) =>
                        formStateManager.setFieldValue('longitude', value),
                    initialValue: widget.pluviometro?.longitude ?? '',
                    onChanged: (value) =>
                        formStateManager.setFieldValue('longitude', value),
                  );
                },
              ),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable:
                      formStateManager.getFieldNotifier('latitude'),
                  builder: (context, value, child) {
                    return FormFieldComponents.latitudeField(
                      validator: FormFieldValidators.validateLatitude,
                      onSaved: (value) =>
                          formStateManager.setFieldValue('latitude', value),
                      initialValue: widget.pluviometro?.latitude ?? '',
                      onChanged: (value) =>
                          formStateManager.setFieldValue('latitude', value),
                    );
                  },
                ),
              ),
              const ResponsiveSpacer(isVertical: false),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable:
                      formStateManager.getFieldNotifier('longitude'),
                  builder: (context, value, child) {
                    return FormFieldComponents.longitudeField(
                      validator: FormFieldValidators.validateLongitude,
                      onSaved: (value) =>
                          formStateManager.setFieldValue('longitude', value),
                      initialValue: widget.pluviometro?.longitude ?? '',
                      onChanged: (value) =>
                          formStateManager.setFieldValue('longitude', value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        FormFieldComponents.spacer(),
        ValueListenableBuilder<bool>(
          valueListenable: formStateManager.getSubmittingNotifier(),
          builder: (context, isSubmitting, child) {
            return FormFieldComponents.gpsButton(
              label: 'Obter Localização Atual',
              onPressed: _getCurrentLocation,
              enabled: !isSubmitting,
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfigSection() {
    return FormFieldComponents.section(
      title: 'Configurações',
      children: [
        ValueListenableBuilder<String>(
          valueListenable: formStateManager.getFieldNotifier('fkGrupo'),
          builder: (context, value, child) {
            return FormFieldComponents.grupoField(
              validator: FormFieldValidators.validateGrupo,
              onSaved: (value) =>
                  formStateManager.setFieldValue('fkGrupo', value),
              initialValue: widget.pluviometro?.fkGrupo ?? '',
              onChanged: (value) =>
                  formStateManager.setFieldValue('fkGrupo', value),
            );
          },
        ),
      ],
    );
  }

  void _getCurrentLocation() async {
    // Implementação futura para obter localização GPS
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidade de GPS será implementada em breve')),
    );
  }
}
