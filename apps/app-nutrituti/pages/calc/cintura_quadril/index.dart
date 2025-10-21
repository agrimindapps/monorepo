// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'controller/cintura_quadril_controller.dart';
import 'model/cintura_quadril_model.dart';
import 'widgets/cintura_quadril_form_widget.dart';
import 'widgets/cintura_quadril_info_widget.dart';
import 'widgets/cintura_quadril_result_widget.dart';

class CinturaQuadrilPage extends StatefulWidget {
  const CinturaQuadrilPage({super.key});

  @override
  State<CinturaQuadrilPage> createState() => _CinturaQuadrilPageState();
}

class _CinturaQuadrilPageState extends State<CinturaQuadrilPage> {
  final _controller = CinturaQuadrilController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.straighten_outlined,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.teal.shade300
                  : Colors.teal,
            ),
            const SizedBox(width: 10),
            const Text('Relação Cintura-Quadril'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => CinturaQuadrilInfoWidget.show(context),
            tooltip: 'Informações sobre a RCQ',
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Formulário isolado - não precisa rebuild geral do controller
                  CinturaQuadrilFormWidget(
                    controller: _controller,
                  ),
                  // Sistema de rebuild granular otimizado:
                  // 1. Primeiro escuta se deve mostrar resultado
                  // 2. Só então escuta mudanças no resultado específico
                  // 3. Adiciona transições suaves com AnimatedSwitcher
                  ValueListenableBuilder<bool>(
                    valueListenable: _controller.mostrarResultadoNotifier,
                    builder: (context, mostrarResultado, child) {
                      if (!mostrarResultado) return const SizedBox.shrink();

                      return ValueListenableBuilder<CinturaQuadrilModel?>(
                        valueListenable: _controller.resultadoNotifier,
                        builder: (context, resultado, child) {
                          if (resultado == null) return const SizedBox.shrink();

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey(
                                  resultado.rcq), // Key único para animação
                              children: [
                                const SizedBox(height: 16),
                                CinturaQuadrilResultWidget(
                                  resultado: resultado,
                                  onCompartilhar: _controller.compartilhar,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
