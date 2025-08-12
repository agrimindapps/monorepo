// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/veiculos_cadastro_form_controller.dart';
import '../models/veiculos_constants.dart';
import '../views/veiculos_cadastro_form_view.dart';

/// Helper function para abrir dialog de cadastro de veículo
///
/// Gerencia a criação e exibição do dialog de cadastro/edição de veículos
/// usando o padrão DialogCadastro.show() para consistência visual.
Future<bool?> VeiculosCadastro(
  BuildContext context,
  VeiculoCar? veiculo,
) {
  final formWidgetKey = GlobalKey<VeiculosCadastroWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: veiculo == null
        ? VeiculosConstants.titulosDialogos['cadastrar']!
        : VeiculosConstants.titulosDialogos['editar']!,
    formKey: formWidgetKey,
    maxHeight: 570,
    onSubmit: () {
      if (!formWidgetKey.currentState!.isLoading) {
        formWidgetKey.currentState!.submit();
      }
    },
    disableSubmitWhen: () => formWidgetKey.currentState?.isLoading ?? false,
    formWidget: (key) => VeiculosCadastroWidget(key: key, veiculo: veiculo),
  );
}

class VeiculosCadastroWidget extends StatefulWidget {
  final VeiculoCar? veiculo;

  const VeiculosCadastroWidget({super.key, this.veiculo});

  @override
  VeiculosCadastroWidgetState createState() => VeiculosCadastroWidgetState();
}

class VeiculosCadastroWidgetState extends State<VeiculosCadastroWidget> {
  late VeiculosCadastroFormController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Always create a fresh controller to avoid state conflicts
    if (Get.isRegistered<VeiculosCadastroFormController>()) {
      Get.delete<VeiculosCadastroFormController>();
    }
    _controller = Get.put(VeiculosCadastroFormController());

    // Initialize form with vehicle data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeForm(widget.veiculo);
    });
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<VeiculosCadastroFormController>()) {
      Get.delete<VeiculosCadastroFormController>();
    }
    super.dispose();
  }

  // This method is called by the dialog parent
  Future<void> submit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final success = await _controller.submitForm();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
      // Se não foi bem-sucedido, não fechamos o diálogo para que o usuário
      // possa ver a mensagem de erro e tentar novamente
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VeiculosCadastroFormController>(
      builder: (controller) => const VeiculosCadastroFormView(),
    );
  }
}
