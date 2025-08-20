// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../../core/widgets/textbuttontopicon_widget.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/capacidade_campo_controller.dart';
import '../../models/solo_info_model.dart';

class CapacidadeCampoFormWidget extends StatelessWidget {
  final CapacidadeCampoController controller;
  final VoidCallback onShowHelp;

  const CapacidadeCampoFormWidget({
    super.key,
    required this.controller,
    required this.onShowHelp,
  });

  Widget _buildSoloSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o tipo de solo:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: SoloInfo.solosDisponiveis.length,
            itemBuilder: (context, index) {
              final solo = SoloInfo.solosDisponiveis[index];
              final isSelected = controller.tipoSolo == solo.nome;

              return GestureDetector(
                onTap: () => controller.setTipoSolo(solo.nome),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? solo.cor.withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? solo.cor : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: solo.cor,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        solo.nome,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? solo.cor : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CC: ${solo.capacidadeCampo}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSoloInfo() {
    final soloInfo = SoloInfo.solosDisponiveis
        .firstWhere((info) => info.nome == controller.tipoSolo);

    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              soloInfo.nome,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              soloInfo.descricao,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUmidadeAtualFields() {
    return Visibility(
      visible: controller.camposAdicionais,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Medição de Umidade Atual',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          VTextField(
            labelText: 'Peso do solo úmido (g)',
            focusNode: controller.soloPesoFocus,
            txEditController: controller.soloPesoController,
            prefixIcon: const Icon(FontAwesome.weight_scale_solid, size: 18),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          VTextField(
            labelText: 'Peso do solo seco (g)',
            focusNode: controller.soloSecoFocus,
            txEditController: controller.soloSecoController,
            prefixIcon: const Icon(FontAwesome.sun_plant_wilt_solid, size: 18),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dados de Entrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: onShowHelp,
                  tooltip: 'Ajuda',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            _buildSoloSelector(),
            const SizedBox(height: 8),
            _buildSoloInfo(),
            const SizedBox(height: 16),

            // Switch para mostrar campos adicionais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calcular umidade atual do solo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: controller.camposAdicionais,
                  activeColor: SoloInfo.solosDisponiveis
                      .firstWhere((info) => info.nome == controller.tipoSolo)
                      .cor,
                  onChanged: controller.setCamposAdicionais,
                ),
              ],
            ),

            _buildUmidadeAtualFields(),

            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Parâmetros do Solo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            VTextField(
              labelText: 'Capacidade de campo (%)',
              focusNode: controller.capacidadeCampoFocus,
              txEditController: controller.capacidadeCampoController,
              prefixIcon: const Icon(FontAwesome.droplet_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Ponto de murcha permanente (%)',
              focusNode: controller.pontoMurchaFocus,
              txEditController: controller.pontoMurchaController,
              prefixIcon: const Icon(FontAwesome.plant_wilt_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Densidade do solo (g/cm³)',
              focusNode: controller.densidadeSoloFocus,
              txEditController: controller.densidadeSoloController,
              prefixIcon:
                  const Icon(FontAwesome.weight_hanging_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),

            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Condições de Campo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            VTextField(
              labelText: 'Profundidade do sistema radicular (cm)',
              focusNode: controller.profundidadeRaizFocus,
              txEditController: controller.profundidadeRaizController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_vertical_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Área irrigada (ha)',
              focusNode: controller.areaIrrigadaFocus,
              txEditController: controller.areaIrrigadaController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_combined_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VTextButtom(
                    title: 'Limpar',
                    onPress: controller.limpar,
                  ),
                  const SizedBox(width: 8),
                  VTextButtom(
                    title: 'Calcular',
                    onPress: controller.calcular,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
