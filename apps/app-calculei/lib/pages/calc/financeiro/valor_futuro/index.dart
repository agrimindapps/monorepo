// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'controllers/valor_futuro_controller.dart';
import 'widgets/valor_futuro_form.dart';
import 'widgets/valor_futuro_result.dart';

class ValorFuturoPage extends StatefulWidget {
  const ValorFuturoPage({super.key});

  @override
  State<ValorFuturoPage> createState() => _ValorFuturoPageState();
}

class _ValorFuturoPageState extends State<ValorFuturoPage> {
  late ValorFuturoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ValorFuturoController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
            title: Row(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  size: 20,
                  color: ThemeManager().isDark.value
                      ? Colors.green.shade300
                      : Colors.green,
                ),
                const SizedBox(width: 10),
                const Text('Calculadora de Valor Futuro'),
              ],
            ),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: ValorFuturoForm(isMobile: isMobile),
                        ),
                        const SizedBox(height: 16),
                        ValorFuturoResult(isMobile: isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
