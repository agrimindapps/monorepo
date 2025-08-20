// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';

class AdipososidadeInputForm extends StatefulWidget {
  final int generoSelecionado;
  final TextEditingController quadrilController;
  final TextEditingController alturaController;
  final TextEditingController idadeController;
  final FocusNode focusQuadril;
  final FocusNode focusAltura;
  final FocusNode focusIdade;
  final Function() onCalcular;
  final Function() onLimpar;
  final Function() onInfoPressed;
  final Function(int) onGeneroChanged;
  final String? quadrilError;
  final String? alturaError;
  final String? idadeError;

  const AdipososidadeInputForm({
    super.key,
    required this.generoSelecionado,
    required this.quadrilController,
    required this.alturaController,
    required this.idadeController,
    required this.focusQuadril,
    required this.focusAltura,
    required this.focusIdade,
    required this.onCalcular,
    required this.onLimpar,
    required this.onInfoPressed,
    required this.onGeneroChanged,
    this.quadrilError,
    this.alturaError,
    this.idadeError,
  });

  @override
  State<AdipososidadeInputForm> createState() => _AdipososidadeInputFormState();
}

class _AdipososidadeInputFormState extends State<AdipososidadeInputForm> {
  // Formatadores de texto
  final quadrilmask = MaskTextInputFormatter(
    mask: '###,#',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final alturamask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final idademask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Lista de opções de gênero
  final List<Map<String, dynamic>> _generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: isDark ? Colors.purple.shade300 : Colors.purple,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dados para cálculo do IAC',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark ? Colors.blue.shade300 : Colors.blue,
                    ),
                    onPressed: widget.onInfoPressed,
                    tooltip: 'Informações sobre o cálculo',
                  ),
                ],
              ),
            ),
            _buildGeneroDropdown(),
            VTextField(
              labelText: 'Circunferência do quadril (cm)',
              hintText: 'Ex: 100,0',
              focusNode: widget.focusQuadril,
              txEditController: widget.quadrilController,
              prefixIcon: Icon(
                Icons.hub_outlined,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              inputFormatters: [quadrilmask],
              showClearButton: true,
            ),
            if (widget.quadrilError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  widget.quadrilError!,
                  style: TextStyle(
                    color: widget.quadrilError!.startsWith('Atenção:')
                        ? Colors.orange
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            VTextField(
              labelText: 'Altura (cm)',
              hintText: 'Ex: 170',
              focusNode: widget.focusAltura,
              txEditController: widget.alturaController,
              prefixIcon: Icon(
                Icons.height,
                color: isDark ? Colors.green.shade300 : Colors.green,
              ),
              inputFormatters: [alturamask],
              showClearButton: true,
            ),
            if (widget.alturaError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  widget.alturaError!,
                  style: TextStyle(
                    color: widget.alturaError!.startsWith('Atenção:')
                        ? Colors.orange
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            VTextField(
              labelText: 'Idade (anos)',
              hintText: 'Ex: 30',
              focusNode: widget.focusIdade,
              txEditController: widget.idadeController,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: isDark ? Colors.amber.shade300 : Colors.amber,
              ),
              inputFormatters: [idademask],
              showClearButton: true,
            ),
            if (widget.idadeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  widget.idadeError!,
                  style: TextStyle(
                    color: widget.idadeError!.startsWith('Atenção:')
                        ? Colors.orange
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onLimpar,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                    style: ShadcnStyle.textButtonStyle,
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: widget.onCalcular,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Calcular'),
                    style: ShadcnStyle.primaryButtonStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroDropdown() {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ShadcnStyle.borderColor),
          color: isDark ? ShadcnStyle.backgroundColor : Colors.blueGrey.shade50,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: widget.generoSelecionado,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
            style: TextStyle(color: ShadcnStyle.textColor),
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            items: _generos.map((genero) {
              return DropdownMenuItem<int>(
                value: genero['id'] as int,
                child: Row(
                  children: [
                    Icon(
                      genero['id'] == 1 ? Icons.male : Icons.female,
                      color: genero['id'] == 1
                          ? (isDark ? Colors.blue.shade300 : Colors.blue)
                          : (isDark ? Colors.pink.shade300 : Colors.pink),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(genero['text'] as String),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onGeneroChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}
