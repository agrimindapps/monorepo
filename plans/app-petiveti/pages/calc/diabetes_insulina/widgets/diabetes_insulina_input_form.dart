// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../controller/diabetes_insulina_controller.dart';
import '../utils/diabetes_insulina_utils.dart';

/// Formulário de entrada para a calculadora de diabetes e insulina
class DiabetesInsulinaInputForm extends StatelessWidget {
  final DiabetesInsulinaController controller;

  const DiabetesInsulinaInputForm({
    super.key,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Dados para Cálculo de Insulina',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: controller.model.especieSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Espécie',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.model.especies
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: controller.atualizarEspecie,
                        validator: (value) =>
                            value == null ? 'Selecione uma espécie' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: controller.model.tipoInsulinaSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Insulina',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.model.tiposInsulina
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: controller.atualizarTipoInsulina,
                        validator: (value) => value == null
                            ? 'Selecione o tipo de insulina'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.model.pesoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Peso do animal (kg)',
                          border: OutlineInputBorder(),
                        ),
                        validator: DiabetesInsulinaUtils.validateNumber,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller.model.glicemiaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nível de glicemia atual (mg/dL)',
                          border: OutlineInputBorder(),
                        ),
                        validator: DiabetesInsulinaUtils.validateIntNumber,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('O animal já recebe insulina?'),
                        value: controller.model.temDoseAnterior,
                        onChanged: controller.atualizarTemDoseAnterior,
                        subtitle: const Text(
                            'Selecione se já existe um tratamento em andamento'),
                      ),
                      if (controller.model.temDoseAnterior)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller:
                                controller.model.dosagemAnteriorController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Dose anterior (unidades)',
                              border: OutlineInputBorder(),
                            ),
                            validator: DiabetesInsulinaUtils.validateNumber,
                          ),
                        ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Usar dosagem específica?'),
                        value: controller.model.usarRegra,
                        onChanged: controller.atualizarUsarRegra,
                        subtitle: const Text(
                            'Selecione para inserir uma dosagem prescrita pelo veterinário'),
                      ),
                      if (controller.model.usarRegra)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller:
                                controller.model.dosagemInsulinaController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Dosagem prescrita (unidades)',
                              border: OutlineInputBorder(),
                            ),
                            validator: DiabetesInsulinaUtils.validateNumber,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controller.limpar,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Limpar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: controller.calcular,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calcular'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Importante: Esta calculadora é apenas para fins educativos. Sempre consulte um veterinário.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
