// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/widgets/models/valor_futuro_model.dart';
import 'info_section.dart';
import 'valor_futuro_main_results.dart';

class ValorFuturoResultCard extends StatelessWidget {
  final ValorFuturoModel modelo;
  final bool isVisible;
  final VoidCallback onShare;

  const ValorFuturoResultCard({
    super.key,
    required this.modelo,
    required this.isVisible,
    required this.onShare,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: isVisible,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(context),
                  const Divider(thickness: 1),
                  _buildResponsiveLayout(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Compartilhar'),
              style: ShadcnStyle.primaryButtonStyle,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Compartilhar'),
            style: ShadcnStyle.primaryButtonStyle,
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValorFuturoMainResults(modelo: modelo),
          const SizedBox(height: 16),
          InfoSection(modelo: modelo),
        ],
      );
    } else {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ValorFuturoMainResults(modelo: modelo),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: InfoSection(modelo: modelo),
            ),
          ],
        ),
      );
    }
  }
}
