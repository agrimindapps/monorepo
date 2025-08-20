// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/implementos_cadastro_controller.dart';
import 'widgets/form_fields_widget.dart';
import 'widgets/image_selector_widget.dart';

class ImplementosCadastroPage extends StatefulWidget {
  const ImplementosCadastroPage({super.key, required this.idReg});
  final String idReg;

  @override
  State<ImplementosCadastroPage> createState() =>
      _ImplementosCadastroPageState();
}

class _ImplementosCadastroPageState extends State<ImplementosCadastroPage> {
  late final ImplementosCadastroController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImplementosCadastroController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _controller.initializeData(widget.idReg);
    } catch (e) {
      _showMessage('Erro ao carregar dados', isError: true);
    }
  }

  Future<void> _salvarRegistro() async {
    try {
      final success = await _controller.salvarRegistro();
      _showMessage(
          success ? 'Registro salvo com sucesso!' : 'Falha ao salvar registro');
      if (success) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage('Erro ao salvar registro: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ImplementosCadastroController>(
        builder: (context, controller, _) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PageHeaderWidget(
                      title: widget.idReg.isEmpty
                          ? 'Novo Implemento'
                          : 'Editar Implemento',
                      subtitle: 'Cadastro de implemento',
                      icon: Icons.fire_truck_sharp,
                      showBackButton: true,
                      actions: [
                        IconButton(
                          onPressed:
                              controller.isLoading ? null : _salvarRegistro,
                          icon: const Icon(Icons.save, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ImageSelectorWidget(
                                        isMiniatura: false,
                                        onTap: controller.selecionarImagens,
                                        label: 'Imagens',
                                        controller: controller,
                                      ),
                                      ImageSelectorWidget(
                                        isMiniatura: true,
                                        onTap: controller.selecionarMiniatura,
                                        label: 'Miniatura',
                                        controller: controller,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  FormFieldsWidget(controller: controller),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
