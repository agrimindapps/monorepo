// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/22_despesas_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/despesas_cadastro_form_controller.dart';
import '../views/despesas_cadastro_form_view.dart';

Future<bool?> despesaCadastro(BuildContext context, DespesaCar? despesa) {
  final formWidgetKey = GlobalKey<DespesaCadastroWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: 'Despesa',
    formKey: formWidgetKey,
    maxHeight: 570,
    onSubmit: () {
      final controller = Get.find<DespesaCadastroFormController>();
      if (!controller.isLoading.value) {
        formWidgetKey.currentState?.submit();
      }
    },
    disableSubmitWhen: () {
      final controller = Get.find<DespesaCadastroFormController>();
      return controller.isLoading.value;
    },
    formWidget: (key) => DespesaCadastroWidget(
      key: key,
      despesa: despesa,
    ),
  );
}

class DespesaCadastroWidget extends StatefulWidget {
  final DespesaCar? despesa;

  const DespesaCadastroWidget({super.key, this.despesa});

  @override
  DespesaCadastroWidgetState createState() => DespesaCadastroWidgetState();
}

class DespesaCadastroWidgetState extends State<DespesaCadastroWidget> {
  late DespesaCadastroFormController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller if not already present
    if (!Get.isRegistered<DespesaCadastroFormController>()) {
      _controller = Get.put(DespesaCadastroFormController());
    } else {
      _controller = Get.find<DespesaCadastroFormController>();
    }

    // Initialize with despesa data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeWithDespesa(widget.despesa);
    });
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<DespesaCadastroFormController>()) {
      Get.delete<DespesaCadastroFormController>();
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
    return GetBuilder<DespesaCadastroFormController>(
      builder: (controller) => const DespesaCadastroFormView(),
    );
  }
}
