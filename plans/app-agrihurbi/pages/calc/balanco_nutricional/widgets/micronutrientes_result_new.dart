// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants.dart';
import '../controllers/micronutrientes_controller.dart';
import '../models/micronutrientes_model.dart';

class MicronutrientesResultNew extends StatelessWidget {
  const MicronutrientesResultNew({super.key});

  Widget _buildTitleRow(
      BuildContext context, MicronutrientesController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${BalancoNutricionalStrings.resultTitleMicronutrientes} ${controller.model.culturaSelecionada}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: controller.compartilhar,
          icon: const Icon(BalancoNutricionalIcons.shareSharp, size: 20),
        ),
      ],
    );
  }

  Widget _buildResultItem(String nome, num valorPorHa, num valorTotal,
      MicronutrientesController controller) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(fontSize: 14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.formatNumber(valorPorHa.toDouble())} kg/ha',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${controller.formatNumber(valorTotal.toDouble())} kg',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, MicronutrientesController controller) {
    final model = controller.model;
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(BalancoNutricionalStrings.infoComplementares,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(thickness: 1),
            const SizedBox(height: 5),
            const Text(
              BalancoNutricionalStrings.infoResultadosMicronutrientes,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              '${BalancoNutricionalStrings.infoNivelCritico} ${model.culturaSelecionada}:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (MicronutrientesModel.niveisCriticos
                .containsKey(model.culturaSelecionada)) ...[
              Text(
                '${BalancoNutricionalStrings.infoZinco} ${MicronutrientesModel.niveisCriticos[model.culturaSelecionada]!['zinco']} mg/dm³',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${BalancoNutricionalStrings.infoBoro} ${MicronutrientesModel.niveisCriticos[model.culturaSelecionada]!['boro']} mg/dm³',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${BalancoNutricionalStrings.infoCobre} ${MicronutrientesModel.niveisCriticos[model.culturaSelecionada]!['cobre']} mg/dm³',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${BalancoNutricionalStrings.infoManganes} ${MicronutrientesModel.niveisCriticos[model.culturaSelecionada]!['manganes']} mg/dm³',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${BalancoNutricionalStrings.infoFerro} ${MicronutrientesModel.niveisCriticos[model.culturaSelecionada]!['ferro']} mg/dm³',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MicronutrientesController>();

    return GetBuilder<MicronutrientesController>(
      builder: (_) {
    final model = controller.model;

        return Visibility(
      visible: model.calculado,
      child: Column(
        children: [
          Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context, controller),
                  const Divider(thickness: 1),
                  _buildResultItem(BalancoNutricionalStrings.resultZinco,
                      model.necessidadeZinco, model.totalZinco, controller),
                  _buildResultItem(BalancoNutricionalStrings.resultBoro,
                      model.necessidadeBoro, model.totalBoro, controller),
                  _buildResultItem(BalancoNutricionalStrings.resultCobre,
                      model.necessidadeCobre, model.totalCobre, controller),
                  _buildResultItem(
                      BalancoNutricionalStrings.resultManganes,
                      model.necessidadeManganes,
                      model.totalManganes,
                      controller),
                  _buildResultItem(BalancoNutricionalStrings.resultFerro,
                      model.necessidadeFerro, model.totalFerro, controller),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoCard(context, controller),
        ],
        ),
      );
      },
    );
  }
}
