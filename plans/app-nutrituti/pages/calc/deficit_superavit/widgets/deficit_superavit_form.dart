// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';

class DeficitSuperavitForm extends StatelessWidget {
  final TextEditingController caloriasDiariasController;
  final TextEditingController metaPesoController;
  final TextEditingController tempoSemanaController;
  final FocusNode focusCalorias;
  final FocusNode focusMetaPeso;
  final FocusNode focusTempo;
  final VoidCallback onCalcular;
  final VoidCallback onLimpar;
  final VoidCallback onInfoPressed;
  final Function(int) onTipoMetaChanged;
  final int tipoMetaSelecionado;

  // Formatadores de texto
  final caloriasMask = MaskTextInputFormatter(
    mask: '####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final pesoMask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final tempoMask = MaskTextInputFormatter(
    mask: '##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  DeficitSuperavitForm({
    super.key,
    required this.caloriasDiariasController,
    required this.metaPesoController,
    required this.tempoSemanaController,
    required this.focusCalorias,
    required this.focusMetaPeso,
    required this.focusTempo,
    required this.onCalcular,
    required this.onLimpar,
    required this.onInfoPressed,
    required this.onTipoMetaChanged,
    required this.tipoMetaSelecionado,
  });

  final List<Map<String, dynamic>> _tiposMeta = [
    {'id': 1, 'text': 'Perda de Peso'},
    {'id': 2, 'text': 'Ganho de Peso'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final bool perderPeso = tipoMetaSelecionado == 1;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Insira seus dados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: ShadcnStyle.textColor,
                  ),
                  onPressed: onInfoPressed,
                  tooltip: 'Informações sobre o cálculo',
                ),
              ],
            ),
            _buildTipoMetaSelector(isDark, perderPeso),
            VTextField(
              labelText: 'Calorias Diárias Atuais (kcal)',
              hintText: 'Ex: 2000',
              focusNode: focusCalorias,
              txEditController: caloriasDiariasController,
              prefixIcon: Icon(
                Icons.whatshot_outlined,
                color: isDark ? Colors.orange.shade300 : Colors.orange,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [caloriasMask],
              showClearButton: true,
            ),
            VTextField(
              labelText: perderPeso
                  ? 'Meta de Perda de Peso (kg)'
                  : 'Meta de Ganho de Peso (kg)',
              hintText: 'Ex: 5,0',
              focusNode: focusMetaPeso,
              txEditController: metaPesoController,
              prefixIcon: Icon(
                Icons.monitor_weight_outlined,
                color: isDark ? Colors.green.shade300 : Colors.green,
              ),
              inputFormatters: [pesoMask],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Tempo para Atingir a Meta (semanas)',
              hintText: 'Ex: 12',
              focusNode: focusTempo,
              txEditController: tempoSemanaController,
              prefixIcon: Icon(
                Icons.timer_outlined,
                color: isDark ? Colors.purple.shade300 : Colors.purple,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [tempoMask],
              showClearButton: true,
            ),
            _buildInfoSection(perderPeso, isDark),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onLimpar,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    label: Text(
                      'Limpar',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    style: ShadcnStyle.textButtonStyle,
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: onCalcular,
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 20,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                    label: const Text(
                      'Calcular',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
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

  Widget _buildTipoMetaSelector(bool isDark, bool perderPeso) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Tipo de Meta',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.trending_down_outlined,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: tipoMetaSelecionado,
          items: _tiposMeta.map((tipo) {
            return DropdownMenuItem<int>(
              value: tipo['id'] as int,
              child: Text(
                tipo['text'] as String,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onTipoMetaChanged(value);
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

  Widget _buildInfoSection(bool perderPeso, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações Importantes:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              perderPeso
                  ? '• Para perder 1kg de gordura, é necessário um déficit de aproximadamente 7.700 calorias.\n'
                      '• Não é recomendado consumir menos que 1200 kcal por dia (para mulheres) ou 1500 kcal por dia (para homens).'
                  : '• Para ganhar 1kg de peso (não apenas músculo), é necessário um superávit de aproximadamente 7.700 calorias.\n'
                      '• Para ganho de massa muscular, combine o superávit calórico com treinamento de resistência adequado.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
