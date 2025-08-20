// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/semeadura_controller.dart';
import 'widgets/info_dialog_widget.dart';
import 'widgets/input_fields_widget.dart';
import 'widgets/results_widget.dart';

class SemeaduraPage extends StatefulWidget {
  const SemeaduraPage({super.key});

  @override
  State<SemeaduraPage> createState() => _SemeaduraPageState();
}

class _SemeaduraPageState extends State<SemeaduraPage> {
  final _controller = SemeaduraController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _exibirMensagem(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  void _showInfoDialog() {
    final isDark = ThemeManager().isDark.value;
    showDialog(
      context: context,
      builder: (context) => InfoDialogWidget(isDark: isDark),
    );
  }

  void _calcular() {
    if (!_controller.validarCampos(_exibirMensagem)) return;
    _controller.calcular();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: MediaQuery.of(context).size.width < 1024
              ? const Size.fromHeight(72)
              : const Size.fromHeight(72),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Semeadura',
              subtitle: 'Cálculo da quantidade de sementes para plantio',
              icon: Icons.grass,
              showBackButton: true,
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: InputFieldsWidget(
                            controller: _controller,
                            onCalcular: _calcular,
                            onLimpar: _controller.limpar,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ResultsWidget(
                          controller: _controller,
                          onCompartilhar: _controller.compartilhar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
