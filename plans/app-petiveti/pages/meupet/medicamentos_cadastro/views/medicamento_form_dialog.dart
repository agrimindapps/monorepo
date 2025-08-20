// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../../models/15_medicamento_model.dart';
import '../../../../widgets/date_field_widget.dart';
import '../../../../widgets/observation_field_widget.dart';
import '../../../../widgets/text_field_widget.dart';
import '../controllers/medicamento_cadastro_controller.dart';

Future<bool?> medicamentoCadastro(
    BuildContext context, MedicamentoVet? medicamento) {
  final formWidgetKey = GlobalKey<MedicamentoFormWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: 'Medicamento',
    formKey: formWidgetKey,
    maxHeight: 600,
    onSubmit: () {
      formWidgetKey.currentState?._submit();
    },
    formWidget: (key) => MedicamentoFormWidget(
      key: key,
      medicamento: medicamento,
    ),
  );
}

class MedicamentoFormWidget extends StatefulWidget {
  final MedicamentoVet? medicamento;

  const MedicamentoFormWidget({super.key, this.medicamento});

  @override
  MedicamentoFormWidgetState createState() => MedicamentoFormWidgetState();
}

class MedicamentoFormWidgetState extends State<MedicamentoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late MedicamentoCadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MedicamentoCadastroController());

    if (widget.medicamento != null) {
      controller.initializeForEditing(widget.medicamento!);
    } else {
      controller.initializeForCreation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Obx(() => TextFieldWidget(
                  label: 'Nome do Medicamento',
                  hint: 'Digite o nome do medicamento',
                  initialValue: controller.model.nomeMedicamento,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (value) => controller.setNomeMedicamento(value ?? ''),
                )),
            const SizedBox(height: 16),
            Obx(() => TextFieldWidget(
                  label: 'Dosagem',
                  hint: 'Ex: 1 comprimido, 10ml, etc.',
                  initialValue: controller.model.dosagem,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (value) => controller.setDosagem(value ?? ''),
                )),
            const SizedBox(height: 16),
            Obx(() => TextFieldWidget(
                  label: 'Frequência',
                  hint: 'Ex: 2 vezes ao dia, a cada 8 horas, etc.',
                  initialValue: controller.model.frequencia,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  validator: controller.validateFrequencia,
                  onSaved: (value) => controller.setFrequencia(value ?? ''),
                )),
            const SizedBox(height: 16),
            Obx(() => TextFieldWidget(
                  label: 'Duração',
                  hint: 'Ex: 7 dias, 2 semanas, etc.',
                  initialValue: controller.model.duracao,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (value) => controller.setDuracao(value ?? ''),
                )),
            const SizedBox(height: 16),
            Obx(() => DateFieldWidget(
                  label: 'Início do Tratamento',
                  initialDate: controller.inicioTratamentoDate,
                  onDateSelected: (date) {
                    controller.setInicioTratamento(date);
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => DateFieldWidget(
                  label: 'Fim do Tratamento',
                  initialDate: controller.fimTratamentoDate,
                  firstDate: controller.inicioTratamentoDate,
                  onDateSelected: (date) {
                    controller.setFimTratamento(date);
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => ObservationFieldWidget(
                  label: 'Observações',
                  hint: 'Observações adicionais sobre o medicamento',
                  initialValue: controller.model.observacoes,
                  onSaved: (value) => controller.setObservacoes(value),
                  isRequired: false,
                )),
            const SizedBox(height: 16),
            Obx(() => controller.hasError
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final success = await controller.submitForm(context, widget.medicamento);

    if (!success && mounted) {
      controller.showErrorSnackBar(context);
    }
  }

  @override
  void dispose() {
    Get.delete<MedicamentoCadastroController>();
    super.dispose();
  }
}
