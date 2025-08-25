// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/22_despesas_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/despesas_cadastro_form_controller.dart';
import '../views/despesas_cadastro_form_view.dart';

Future<bool?> despesaCadastro(BuildContext context, DespesaCar? despesa) {
  final formWidgetKey = GlobalKey<DespesaCadastroWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: despesa != null ? 'Editar Despesa' : 'Nova Despesa',
    formKey: formWidgetKey,
    maxHeight: 620,
    borderColor: Colors.red.withValues(alpha: 0.3),
    titleIcon: Icons.attach_money,
    titleIconColor: Colors.red,
    submitButtonText: despesa != null ? 'Salvar Alterações' : 'Adicionar',
    submitButtonColor: Colors.red,
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

class DespesaCadastroWidgetState extends State<DespesaCadastroWidget>
    with SingleTickerProviderStateMixin {
  late DespesaCadastroFormController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
    _animationController.dispose();
    // Clean up controller when widget is disposed
    if (Get.isRegistered<DespesaCadastroFormController>()) {
      Get.delete<DespesaCadastroFormController>();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (mounted) {
      // Show loading indicator
      _controller.isLoading.value = true;
      
      final success = await _controller.submit(context);
      
      if (success && mounted) {
        // Success animation before closing
        await _animationController.reverse();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _controller.isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GetBuilder<DespesaCadastroFormController>(
        builder: (controller) => Stack(
          children: [
            const DespesaCadastroFormView(),
            // Loading overlay
            Obx(() => controller.isLoading.value
                ? ColoredBox(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.despesa != null
                                  ? 'Salvando alterações...'
                                  : 'Adicionando despesa...',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
