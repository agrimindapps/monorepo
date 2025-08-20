// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../../models/17_peso_model.dart';
import '../../../../widgets/date_field_widget.dart';
import '../../../../widgets/numeric_field_widget.dart';
import '../../../../widgets/observation_field_widget.dart';
import '../controllers/peso_cadastro_controller.dart';

Future<bool?> pesoCadastro(
  BuildContext context, 
  PesoAnimal? peso, {
  Function(PesoAnimal)? onPesoSaved,
}) async {
  final formWidgetKey = GlobalKey<PesoFormWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: peso == null ? 'Registrar Peso' : 'Editar Registro de Peso',
    formKey: formWidgetKey,
    maxHeight: 370,
    onSubmit: () {
      formWidgetKey.currentState?._submit();
    },
    formWidget: (key) => PesoFormWidget(
      key: key,
      peso: peso,
      onPesoSaved: onPesoSaved,
    ),
  );
}

class PesoFormWidget extends StatefulWidget {
  final PesoAnimal? peso;
  final Function(PesoAnimal)? onPesoSaved;

  const PesoFormWidget({
    super.key, 
    this.peso,
    this.onPesoSaved,
  });

  @override
  PesoFormWidgetState createState() => PesoFormWidgetState();
}

class PesoFormWidgetState extends State<PesoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late PesoCadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PesoCadastroController(onPesoSaved: widget.onPesoSaved));

    if (widget.peso != null) {
      controller.initializeForEditing(widget.peso!);
    } else {
      controller.initializeForCreation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          DateFieldWidget(
            label: 'Data da Pesagem',
            initialDate: controller.dataPesagemDate,
            lastDate: DateTime.now(),
            onDateSelected: (date) {
              controller.setDataPesagem(date.millisecondsSinceEpoch);
            },
          ),
          const SizedBox(height: 16),
          NumericFieldWidget(
            label: 'Peso',
            suffix: 'kg',
            initialValue: controller.peso > 0 ? controller.peso : null,
            minValue: 0.01,
            maxValue: 500,
            validator: (value) {
              return controller.validatePesoInput(value);
            },
            onSaved: (value) => controller.setPeso(value),
          ),
          const SizedBox(height: 16),
          ObservationFieldWidget(
            label: 'Observações',
            initialValue: controller.observacoes,
            isRequired: false,
            onSaved: (value) => controller.setObservacoes(value ?? ''),
          ),
          if (controller.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (controller.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    ));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final success = await controller.savePeso(context, existingPeso: widget.peso);
    
    if (!success && mounted) {
      controller.showErrorSnackBar(context);
    }
  }

  @override
  void dispose() {
    Get.delete<PesoCadastroController>();
    super.dispose();
  }
}
