// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controller/peso_ideal_controller.dart';

class PesoIdealForm extends StatelessWidget {
  const PesoIdealForm({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Informe os valores para o cálculo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
            Consumer<PesoIdealController>(
              builder: (context, controller, child) {
                return _buildGeneroSelector(context, controller, isDark);
              },
            ),
            Consumer<PesoIdealController>(
              builder: (context, controller, child) {
                return VTextField(
                  labelText: 'Altura (cm)',
                  hintText: '0.0',
                  focusNode: controller.model.focusAltura,
                  txEditController: controller.model.alturaController,
                  prefixIcon: Icon(
                    Icons.height_outlined,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 1)],
                  showClearButton: true,
                );
              },
            ),
            Consumer<PesoIdealController>(
              builder: (context, controller, child) {
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: controller.limpar,
                        child: const Text('Limpar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => controller.calcular(context),
                        child: const Text('Calcular'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroSelector(
      BuildContext context, PesoIdealController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? ShadcnStyle.backgroundColor.withAlpha(128)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Gênero',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: controller.model.generoDef['id'] as int,
          items: controller.model.generos.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'] as int,
              child: Text(
                item['text'] as String,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateGenero(value);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
