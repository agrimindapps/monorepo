// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/25_manutencao_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../views/manutencoes_cadastro_form_view.dart';

Future<bool?> manutencaoCadastro(
    BuildContext context, ManutencaoCar? manutencao) {
  final formWidgetKey = GlobalKey<ManutencoesCadastroWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: 'Manutenção',
    formKey: formWidgetKey,
    maxHeight: 570,
    onSubmit: () {
      final controller = Get.find<ManutencoesCadastroFormController>();
      if (!controller.isLoading.value) {
        formWidgetKey.currentState?.submit();
      }
    },
    disableSubmitWhen: () {
      final controller = Get.find<ManutencoesCadastroFormController>();
      return controller.isLoading.value;
    },
    formWidget: (key) => ManutencoesCadastroWidget(
      key: key,
      manutencao: manutencao,
    ),
  );
}

class ManutencoesCadastroWidget extends StatefulWidget {
  final ManutencaoCar? manutencao;

  const ManutencoesCadastroWidget({super.key, this.manutencao});

  @override
  ManutencoesCadastroWidgetState createState() =>
      ManutencoesCadastroWidgetState();
}

class ManutencoesCadastroWidgetState extends State<ManutencoesCadastroWidget> {
  late ManutencoesCadastroFormController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller if not already present
    if (!Get.isRegistered<ManutencoesCadastroFormController>()) {
      _controller = Get.put(ManutencoesCadastroFormController());
    } else {
      _controller = Get.find<ManutencoesCadastroFormController>();
    }

    // Initialize with manutencao data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeWithManutencao(widget.manutencao);
    });
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<ManutencoesCadastroFormController>()) {
      Get.delete<ManutencoesCadastroFormController>();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (mounted) {
      final success = await _controller.submit(context);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManutencoesCadastroFormController>(
      builder: (controller) => const ManutencoesCadastroFormView(),
    );
  }
}
