// Widget de formulário de entrada para densidade óssea

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../model/densidade_ossea_model.dart';

class DensidadeOsseaInputForm extends StatelessWidget {
  final DensidadeOsseaModel model;
  final Function() onCalcular;
  final Function() onLimpar;
  final Function(void Function()) setState;

  const DensidadeOsseaInputForm({
    super.key,
    required this.model,
    required this.onCalcular,
    required this.onLimpar,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...existing code...
          ],
        ),
      ),
    );
  }
  // ...existing code (métodos auxiliares do formulário)...
}
