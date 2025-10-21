// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/core/widgets/textfield_widget.dart';
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/widgets/controllers/valor_futuro_controller.dart';

class ValorFuturoForm extends StatelessWidget {
  final bool isMobile;

  const ValorFuturoForm({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ValorFuturoController>();
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            isMobile
                ? _buildMobileInputFields(isDark, controller)
                : _buildDesktopInputFields(isDark, controller),
            const SizedBox(height: 15),
            _buildTaxaSwitch(isDark, controller),
            const SizedBox(height: 15),
            _buildButtons(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInputFields(
      bool isDark, ValorFuturoController controller) {
    return Column(
      children: [
        VTextField(
          labelText: 'Valor Inicial (R\$)',
          hintText: '1000,00',
          focusNode: controller.focusValorInicial,
          txEditController: controller.valorInicialController,
          prefixIcon: Icon(
            Icons.attach_money_outlined,
            color: isDark ? Colors.green.shade300 : Colors.green,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.valorInicialMask],
          showClearButton: true,
        ),
        const SizedBox(height: 8),
        VTextField(
          labelText: 'Taxa de Juros (%)',
          hintText: '12,00',
          focusNode: controller.focusTaxaJuros,
          txEditController: controller.taxaJurosController,
          prefixIcon: Icon(
            Icons.percent_outlined,
            color: isDark ? Colors.amber.shade300 : Colors.amber,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.taxaJurosMask],
          showClearButton: true,
        ),
        const SizedBox(height: 8),
        VTextField(
          labelText: 'Período',
          hintText: '12',
          focusNode: controller.focusPeriodo,
          txEditController: controller.periodoController,
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: isDark ? Colors.blue.shade300 : Colors.blue,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.periodoMask],
          showClearButton: true,
        ),
      ],
    );
  }

  Widget _buildDesktopInputFields(
      bool isDark, ValorFuturoController controller) {
    return Row(
      children: [
        Expanded(
          child: VTextField(
            labelText: 'Valor Inicial (R\$)',
            hintText: '1000,00',
            focusNode: controller.focusValorInicial,
            txEditController: controller.valorInicialController,
            prefixIcon: Icon(
              Icons.attach_money_outlined,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [controller.valorInicialMask],
            showClearButton: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: VTextField(
            labelText: 'Taxa de Juros (%)',
            hintText: '12,00',
            focusNode: controller.focusTaxaJuros,
            txEditController: controller.taxaJurosController,
            prefixIcon: Icon(
              Icons.percent_outlined,
              color: isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [controller.taxaJurosMask],
            showClearButton: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: VTextField(
            labelText: 'Período',
            hintText: '12',
            focusNode: controller.focusPeriodo,
            txEditController: controller.periodoController,
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [controller.periodoMask],
            showClearButton: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxaSwitch(bool isDark, ValorFuturoController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 20,
            color: isDark ? Colors.purple.shade300 : Colors.purple,
          ),
          const SizedBox(width: 12),
          Text(
            'Taxa de Juros',
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Mensal',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Switch(
                value: controller.ehAnual,
                onChanged: controller.setTipoTaxa,
                activeColor: isDark ? Colors.purple.shade300 : Colors.purple,
              ),
              Text(
                'Anual',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, ValorFuturoController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: controller.limpar,
          icon: const Icon(Icons.refresh),
          label: const Text('Limpar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => controller.calcular(context),
          style: ShadcnStyle.primaryButtonStyle,
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Calcular'),
        ),
      ],
    );
  }
}
