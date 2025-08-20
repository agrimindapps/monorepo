// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/diluicao_defensivos_controller.dart';

class UnidadeSelectorWidget extends StatelessWidget {
  final DiluicaoDefensivosController controller;

  const UnidadeSelectorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.unidadeSelecionada,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          style: TextStyle(color: ShadcnStyle.textColor),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: controller.unidades.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: controller.setUnidade,
        ),
      ),
    );
  }
}
