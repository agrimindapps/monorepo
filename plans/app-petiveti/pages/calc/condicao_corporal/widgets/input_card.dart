// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/condicao_corporal_controller.dart';

class InputCard extends StatelessWidget {
  final CondicaoCorporalController controller;

  const InputCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

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
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Avalie a condição corporal do seu animal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ),
            ),
            _buildEspecieDropdown(isDark),
            const SizedBox(height: 20),
            if (controller.especieSelecionada != null) ...[
              _buildCondicaoSelector(isDark),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEspecieDropdown(bool isDark) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.especieSelecionada,
        decoration: InputDecoration(
          labelText: 'Espécie do Animal',
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
          prefixIcon: Icon(
            Icons.pets_outlined,
            color: isDark ? Colors.green.shade300 : Colors.green,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
        items: controller.model.especies.map((especie) {
          return DropdownMenuItem<String>(
            value: especie,
            child: Text(
              especie,
              style: TextStyle(
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
            ),
          );
        }).toList(),
        onChanged: controller.atualizarEspecie,
      ),
    );
  }

  Widget _buildCondicaoSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condição Corporal (ECC)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione o número que melhor descreve a condição do seu animal:',
          style: TextStyle(
            fontSize: 14,
            color: ShadcnStyle.mutedTextColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildEccChips(isDark),
        const SizedBox(height: 12),
        _buildEccLegend(isDark),
      ],
    );
  }

  Widget _buildEccChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.model.indices[controller.especieSelecionada]!
          .map((indice) {
        final i = int.parse(indice);
        final isSelected = controller.indiceSelecionado == i;

        return GestureDetector(
          onTap: () => controller.atualizarIndice(isSelected ? null : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? controller.getSelectedColorForIndice(i)
                  : (isDark
                      ? Colors.grey.shade800
                      : controller.getColorForIndice(i)),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? controller.getSelectedColorForIndice(i)
                    : (isDark
                        ? Colors.grey.shade600
                        : controller
                            .getSelectedColorForIndice(i)
                            .withValues(alpha: 0.3)),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: controller
                            .getSelectedColorForIndice(i)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              indice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEccLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withValues(alpha: 0.2)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Guia de Avaliação:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendItem('1-3', 'Abaixo do peso', Colors.orange, isDark),
          const SizedBox(height: 4),
          _buildLegendItem('4-5', 'Peso ideal', Colors.green, isDark),
          const SizedBox(height: 4),
          _buildLegendItem('6-9', 'Acima do peso', Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String range, String description, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.7) : color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$range: $description',
          style: TextStyle(
            fontSize: 12,
            color: ShadcnStyle.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Semantics(
            label: 'Limpar seleção',
            hint: 'Remove a espécie e índice selecionados',
            child: TextButton.icon(
              onPressed: controller.limpar,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar'),
              style: ShadcnStyle.textButtonStyle,
            ),
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLoadingNotifier,
            builder: (context, isLoading, child) {
              return Semantics(
                label: isLoading ? 'Calculando resultado' : 'Calcular resultado da avaliação',
                hint: isLoading ? 'Aguarde, calculando...' : 'Inicia o cálculo da condição corporal',
                button: true,
                child: TextButton.icon(
                  onPressed: isLoading ? null : controller.calcular,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.assessment_outlined, size: 18),
                  label: Text(isLoading ? 'Avaliando...' : 'Avaliar'),
                  style: ShadcnStyle.primaryButtonStyle,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
