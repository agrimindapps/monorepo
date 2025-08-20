// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final List<Widget>? actions;
  final double? maxWidth;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: Container(
          padding: const EdgeInsets.all(ShadcnStyle.standardPadding),
          decoration: BoxDecoration(
            color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: ShadcnStyle.standardPadding),
              ...content,
              if (actions != null) ...[
                const SizedBox(height: ShadcnStyle.largeSpacing),
                _buildActions(),
              ] else ...[
                const SizedBox(height: ShadcnStyle.largeSpacing),
                _buildDefaultCloseButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: isDark ? Colors.blue.shade300 : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: ShadcnStyle.cardPadding),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!,
    );
  }

  Widget _buildDefaultCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ShadcnStyle.primaryButtonStyle,
        child: const Text('Fechar'),
      ),
    );
  }

  // Factory constructors para casos específicos
  factory InfoDialog.condicaoCorporal(BuildContext context) {
    return InfoDialog(
      title: 'Sobre a Condição Corporal',
      content: [
        _buildInstructionsSection(),
        const SizedBox(height: ShadcnStyle.standardPadding),
        _buildScaleSection(),
        const SizedBox(height: ShadcnStyle.standardPadding),
        _buildWarningSection(),
      ],
    );
  }

  static Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como funciona a avaliação:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: ShadcnStyle.smallSpacing),
        _buildInstructionItem('1. Observe seu animal de cima e de lado'),
        const SizedBox(height: ShadcnStyle.dialogMargin),
        _buildInstructionItem('2. Palpe suavemente as costelas e coluna vertebral'),
        const SizedBox(height: ShadcnStyle.dialogMargin),
        _buildInstructionItem('3. Avalie a cintura quando visto de cima'),
        const SizedBox(height: ShadcnStyle.dialogMargin),
        _buildInstructionItem('4. Observe a curvatura abdominal de lado'),
      ],
    );
  }

  static Widget _buildInstructionItem(String instruction) {
    return Text(
      instruction,
      style: TextStyle(color: ShadcnStyle.textColor),
    );
  }

  static Widget _buildScaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escala aplicada:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: ShadcnStyle.smallSpacing),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'ECC 1-3: Abaixo do peso (necessário ganho de peso)\n'
            'ECC 4-5: Peso ideal (manter alimentação atual)\n'
            'ECC 6-9: Acima do peso (necessário perda de peso)',
            style: TextStyle(
              fontFamily: 'monospace',
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildWarningSection() {
    final isDark = ThemeManager().isDark.value;
    
    return Container(
      padding: const EdgeInsets.all(ShadcnStyle.cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.shade900.withValues(alpha: 0.2)
            : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.amber.shade700.withValues(alpha: 0.3)
              : Colors.amber.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: isDark
                ? Colors.amber.shade300
                : Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: ShadcnStyle.smallSpacing),
          Expanded(
            child: Text(
              'Importante: Esta avaliação é apenas indicativa. Sempre consulte um veterinário para orientações específicas.',
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
