// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class VolumeSanguineoInfoDialog {
  static void show(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark),
                  const SizedBox(height: 16),
                  _buildContent(isDark),
                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: isDark ? Colors.blue.shade300 : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Informações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
      ],
    );
  }

  static Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'O que é Volume Sanguíneo?',
          'O volume sanguíneo total é a quantidade de sangue circulante no corpo. Conhecer este valor é importante para diversos procedimentos médicos, transfusões e avaliações clínicas.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Fórmula utilizada:',
          'Volume (L) = Peso (kg) × Fator / 1000',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Fatores por tipo:',
          '• Homens: 75 ml/kg\n• Mulheres: 65 ml/kg\n• Crianças: 80 ml/kg\n• Prematuros: 95 ml/kg\n• Recém-nascidos: 85 ml/kg',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Observação:',
          'Este cálculo fornece uma estimativa baseada em valores médios. O volume sanguíneo real pode variar de acordo com diversos fatores individuais como idade, condição física e estado de saúde.',
          isDark,
        ),
      ],
    );
  }

  static Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: ShadcnStyle.textColor),
        ),
      ],
    );
  }

  static Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Fechar'),
      ),
    );
  }
}
