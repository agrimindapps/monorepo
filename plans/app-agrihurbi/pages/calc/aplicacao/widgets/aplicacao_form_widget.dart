// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/aplicacao_controller.dart';

class AplicacaoFormWidget extends StatefulWidget {
  final String tipo;
  final String labelVolume;
  final IconData volumeIcon;
  final Color volumeColor;

  const AplicacaoFormWidget({
    super.key,
    required this.tipo,
    required this.labelVolume,
    required this.volumeIcon,
    this.volumeColor = Colors.blue,
  });

  @override
  State<AplicacaoFormWidget> createState() => _AplicacaoFormWidgetState();
}

class _AplicacaoFormWidgetState extends State<AplicacaoFormWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AplicacaoController>();
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VTextField(
                labelText: widget.labelVolume,
                hintText: '0.0',
                focusNode: controller.focus1,
                txEditController: controller.volumePulverizar,
                inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                showClearButton: true,
                validator: (value) =>
                    controller.validateVolumePulverizar(value),
              ),
              VTextField(
                labelText: 'Veloc. De Deslocamento (Km/h)',
                hintText: '0.0',
                focusNode: controller.focus2,
                txEditController: controller.velocidadeAplicacao,
                inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                showClearButton: true,
                validator: (value) =>
                    controller.validateVelocidadeAplicacao(value),
              ),
              VTextField(
                labelText: 'Espaçamento Entre Bicos (Cm)',
                hintText: '0.0',
                focusNode: controller.focus3,
                txEditController: controller.espacamentoBicos,
                inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                showClearButton: true,
                validator: (value) =>
                    controller.validateEspacamentoBicos(value),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: controller.limpar,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Limpar'),
                      style: ShadcnStyle.textButtonStyle,
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.calcular(context, widget.tipo);
                        }
                      },
                      icon: const Icon(Icons.calculate_outlined, size: 18),
                      label: const Text('Calcular'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
