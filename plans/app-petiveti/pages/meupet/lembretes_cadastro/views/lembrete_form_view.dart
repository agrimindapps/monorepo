// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../controllers/lembrete_form_controller.dart';
import 'styles/form_colors.dart';
import 'widgets/enhanced_form_fields.dart';
import 'widgets/form_actions.dart';
import 'widgets/form_header.dart';

double _getDialogWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 600) {
    return screenWidth * 0.9;
  } else if (screenWidth < 1024) {
    return 500;
  } else {
    return 600;
  }
}

Future<bool?> lembreteCadastro(BuildContext context, LembreteVet? lembrete) async {
  if (!Get.isRegistered<LembreteFormController>(tag: 'lembrete_form')) {
    await LembreteFormController.initialize();
  }

  if (!context.mounted) return null;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 320,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            minHeight: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            width: _getDialogWidth(context),
            padding: const EdgeInsets.all(16),
            child: LembreteFormView(lembrete: lembrete),
          ),
        ),
      ),
    ),
  );
}

class LembreteFormView extends StatefulWidget {
  final LembreteVet? lembrete;

  const LembreteFormView({super.key, this.lembrete});

  @override
  LembreteFormViewState createState() => LembreteFormViewState();
}

class LembreteFormViewState extends State<LembreteFormView> {
  late LembreteFormController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LembreteFormController());
    controller.initializeForm(lembrete: widget.lembrete);
  }

  Future<void> _submit() async {
    final success = await controller.submitForm();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lembrete salvo com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        _showErrorMessage();
      }
    }
  }

  void _showErrorMessage() {
    final errorMessage = controller.errorMessage ?? 'Erro ao salvar lembrete';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: LembreteFormColors.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormHeader(
            title: controller.getFormTitle(),
            isLoading: controller.isLoading,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: EnhancedLembreteFormFields(controller: controller),
            ),
          ),
          const SizedBox(height: 16),
          FormActions(
            controller: controller,
            onSubmit: _submit,
            onCancel: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    Get.delete<LembreteFormController>();
    super.dispose();
  }
}
