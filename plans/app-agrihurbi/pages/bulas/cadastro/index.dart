// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/bulas_cadastro_controller.dart';
import 'widgets/bula_form_widget.dart';

class BulasCadastroPage extends StatefulWidget {
  const BulasCadastroPage({super.key, required this.idReg});
  final String idReg;

  @override
  State<BulasCadastroPage> createState() => _BulasCadastroPageState();
}

class _BulasCadastroPageState extends State<BulasCadastroPage> {
  late final BulasCadastroController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BulasCadastroController());
    _controller.initializeData(widget.idReg);
    
    // Observer para mensagens de erro
    ever(_controller.errorMessage, (String message) {
      if (message.isNotEmpty) {
        _showMessage(message, isError: true);
      }
    });
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageHeaderWidget(
                title: widget.idReg.isEmpty ? 'Nova Bula' : 'Editar Bula',
                subtitle: 'Cadastro de bula',
                icon: Icons.medical_information,
                showBackButton: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      if (_controller.isLoading.value) return;
                      
                      final navigator = Navigator.of(context);
                      final result = await _controller.salvarRegistro();
                      if (result) {
                        if (mounted) {
                          _showMessage(widget.idReg.isEmpty
                              ? 'Registro cadastrado com sucesso!'
                              : 'Registro atualizado com sucesso!');
                          navigator.pop();
                        }
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BulaFormWidget(controller: _controller),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<BulasCadastroController>();
    super.dispose();
  }
}
