// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/25_manutencao_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../views/manutencoes_cadastro_form_view.dart';

Future<bool?> manutencaoCadastro(
    BuildContext context, ManutencaoCar? manutencao) {
  final formWidgetKey = GlobalKey<ManutencoesCadastroWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: manutencao != null ? 'Editar Manutenção' : 'Nova Manutenção',
    formKey: formWidgetKey,
    maxHeight: 620,
    borderColor: ShadcnStyle.primaryColor.withValues(alpha: 0.3),
    titleIcon: Icons.build,
    titleIconColor: ShadcnStyle.primaryColor,
    submitButtonText: manutencao != null ? 'Salvar Alterações' : 'Adicionar',
    submitButtonColor: ShadcnStyle.primaryColor,
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

class ManutencoesCadastroWidgetState extends State<ManutencoesCadastroWidget>
    with SingleTickerProviderStateMixin {
  late ManutencoesCadastroFormController _controller;
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
    _animationController.dispose();
    // Clean up controller when widget is disposed
    if (Get.isRegistered<ManutencoesCadastroFormController>()) {
      Get.delete<ManutencoesCadastroFormController>();
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
      child: GetBuilder<ManutencoesCadastroFormController>(
        builder: (controller) => Stack(
          children: [
            const ManutencoesCadastroFormView(),
            // Loading overlay
            Obx(() => controller.isLoading.value
                ? Container(
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
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ShadcnStyle.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.manutencao != null
                                  ? 'Salvando alterações...'
                                  : 'Adicionando manutenção...',
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
