// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/evapotranspiracao_controller.dart';
import '../widgets/evapotranspiracao/evapotranspiracao_form.dart';
import '../widgets/evapotranspiracao/evapotranspiracao_result.dart';

class EvapotranspiracaoPage extends StatefulWidget {
  const EvapotranspiracaoPage({super.key});

  @override
  State<EvapotranspiracaoPage> createState() => _EvapotranspiracaoPageState();
}

class _EvapotranspiracaoPageState extends State<EvapotranspiracaoPage>
    with TickerProviderStateMixin {
  late final EvapotranspiracaoController _controller;
  late final AnimationController _resultAnimationController;
  late final Animation<double> _resultAnimation;

  @override
  void initState() {
    super.initState();
    _controller = EvapotranspiracaoController();
    _resultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resultAnimation = CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutCubic,
    );

    _controller.addListener(_handleControllerUpdate);
  }

  void _handleControllerUpdate() {
    if (_controller.calculado) {
      _resultAnimationController.reset();
      _resultAnimationController.forward();
    }
    setState(() {});
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajuda - Evapotranspiração da Cultura'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evapotranspiração da Cultura (ETc)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'A evapotranspiração da cultura (ETc) representa a quantidade de água que a planta necessita para seu desenvolvimento ótimo. É calculada pela fórmula:',
                ),
                SizedBox(height: 8),
                Text(
                  'ETc = ETo × Kc × Ks',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Onde:',
                ),
                SizedBox(height: 8),
                Text(
                  '• Evapotranspiração de Referência (ETo): Taxa de evapotranspiração de uma cultura de referência hipotética.',
                ),
                Text(
                  '• Coeficiente de Cultura (Kc): Fator que relaciona a evapotranspiração da cultura com a evapotranspiração de referência.',
                ),
                Text(
                  '• Coeficiente de Estresse (Ks): Fator que reduz a evapotranspiração da cultura em condições de estresse hídrico.',
                ),
                SizedBox(height: 16),
                Text(
                  'Valores típicos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'O Kc varia de acordo com a cultura e seu estágio de desenvolvimento, geralmente entre 0.3 e 1.2.',
                ),
                Text(
                  'Em condições ótimas de umidade do solo, o valor de Ks é igual a 1.0.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
            child: EvapotranspiracaoForm(
              controller: _controller,
              onShowHelp: _showHelpDialog,
            ),
          ),
          const SizedBox(height: 20),
          if (_controller.calculado)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
              child: EvapotranspiracaoResult(
                controller: _controller,
                animation: _resultAnimation,
              ),
            ),
        ],
      ),
    );
  }
}
