// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/rendimento_controller.dart';
import '../model/cereal_model.dart';
import '../widgets/info_card.dart';

class CerealPage extends StatefulWidget {
  const CerealPage({super.key});

  @override
  State<CerealPage> createState() => _CerealPageState();
}

class _CerealPageState extends State<CerealPage> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _impurezasController = TextEditingController();
  final _umidadeController = TextEditingController();
  final _hectaresController = TextEditingController();

  @override
  void dispose() {
    _pesoController.dispose();
    _impurezasController.dispose();
    _umidadeController.dispose();
    _hectaresController.dispose();
    super.dispose();
  }

  void _calcularRendimento(RendimentoController controller) {
    if (_formKey.currentState!.validate()) {
      final cereal = CerealModel(
        titulo: 'Cereais',
        descricao: 'Cálculo de rendimento para cereais',
        pesoHectolitrico: double.parse(_pesoController.text),
        impurezas: double.parse(_impurezasController.text),
        umidade: double.parse(_umidadeController.text),
        hectares: double.parse(_hectaresController.text),
      );

      controller.setRendimento(cereal);
      final resultado = controller.calcularRendimento();

      if (controller.mensagemErro.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => InfoCard(
            title: 'Resultado do Cálculo',
            content:
                'O rendimento estimado é de ${resultado.toStringAsFixed(2)} kg/ha',
            bulletPoints: const [],
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(RendimentoController());
    return GetBuilder<RendimentoController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cálculo de Rendimento - Cereais'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso Hectolítrico (kg/hl)',
                        helperText: 'Peso padrão por 100 litros',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o peso hectolítrico';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _impurezasController,
                      decoration: const InputDecoration(
                        labelText: 'Impurezas (%)',
                        helperText: 'Percentual de impurezas na amostra',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o percentual de impurezas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _umidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Umidade (%)',
                        helperText: 'Percentual de umidade na amostra',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o percentual de umidade';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hectaresController,
                      decoration: const InputDecoration(
                        labelText: 'Área (hectares)',
                        helperText: 'Área total plantada',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a área plantada';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (controller.mensagemErro.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          controller.mensagemErro,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => _calcularRendimento(controller),
                      child: const Text('Calcular Rendimento'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
