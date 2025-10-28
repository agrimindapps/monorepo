// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../controller/calorias_exercicio_controller.dart';
import '../model/exercicio_model.dart';

class CaloriasExercicioFormWidget extends StatefulWidget {
  final CaloriasExercicioController controller;
  final void Function() onCalcular;

  const CaloriasExercicioFormWidget({
    super.key,
    required this.controller,
    required this.onCalcular,
  });

  @override
  State<CaloriasExercicioFormWidget> createState() =>
      _CaloriasExercicioFormWidgetState();
}

class _CaloriasExercicioFormWidgetState
    extends State<CaloriasExercicioFormWidget> {
  final _tempoController = TextEditingController();
  final _focus1 = FocusNode();

  final _tempomask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _tempoController.dispose();
    _focus1.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_tempoController.text.isEmpty) {
      _mostrarErro('Tempo não informado.');
      _focus1.requestFocus();
      return;
    }

    widget.controller.setTempo(_tempoController.text);
    if (widget.controller.calcular()) {
      widget.onCalcular();
    } else {
      _mostrarErro('Erro ao calcular. Verifique os valores informados.');
    }
  }

  void _limpar() {
    _tempoController.clear();
    widget.controller.limpar();
    setState(() {});
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(mensagem),
      backgroundColor: Colors.red.shade900,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Informe os valores para o cálculo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                _buildAtividadeDropdown(isDark),
                _buildTempoField(isDark),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _limpar,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpar'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: _calcular,
                        icon: const Icon(Icons.calculate_outlined, size: 18),
                        label: const Text('Calcular'),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.amber.shade700 : Colors.amber,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAtividadeDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF303030).withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<ExercicioModel>(
          decoration: InputDecoration(
            labelText: 'Atividade Física:',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.directions_run_outlined,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          initialValue: widget.controller.atividadeSelecionada,
          isExpanded: true,
          items: widget.controller.atividades.map((item) {
            return DropdownMenuItem<ExercicioModel>(
              value: item,
              child: Text(
                item.nome,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.controller.selecionarAtividade(value);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildTempoField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF303030).withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _tempoController,
          focusNode: _focus1,
          decoration: InputDecoration(
            labelText: 'Tempo (min)',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            hintText: '0',
            prefixIcon: Icon(
              Icons.timer_outlined,
              color: isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          style: TextStyle(
            color: isDark ? Colors.grey.shade200 : Colors.black,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [_tempomask],
        ),
      ),
    );
  }
}
