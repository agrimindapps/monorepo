// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../controller/alcool_sangue_controller.dart';
import '../utils/alcool_sangue_utils.dart';

class AlcoolSangueResult extends StatelessWidget {
  final AlcoolSangueController controller;

  const AlcoolSangueResult({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.calculado,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultHeader(context),
                _buildResultValues(context),
                _buildTasGauge(context),
                _buildInfoSection(context),
              ],
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
          const Text(
            'Resultado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: controller.compartilhar,
            style: ShadcnStyle.primaryButtonStyle,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartilhar'),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Resultado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            onPressed: controller.compartilhar,
            style: ShadcnStyle.primaryButtonStyle,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartilhar'),
          ),
        ],
      );
    }
  }

  Widget _buildResultValues(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final numberFormat = NumberFormat('#,##0.00', 'pt_BR');

    // Determinar cores baseadas no nível de TAS
    Color tasColor = Colors.green;
    if (controller.modelo.tas > 0.05) tasColor = Colors.amber;
    if (controller.modelo.tas > 0.08) tasColor = Colors.orange;
    if (controller.modelo.tas > 0.15) tasColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taxa de Álcool no Sangue (TAS)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${numberFormat.format(controller.modelo.tas)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? tasColor.withValues(alpha: 0.9) : tasColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.modelo.condicao,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
          _buildRecoveryTime(),
        ],
      ),
    );
  }

  Widget _buildTasGauge(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final isSmallScreen = screenWidth < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determinar cores baseadas no nível de TAS
    Color tasColor = Colors.green;
    if (controller.modelo.tas > 0.05) tasColor = Colors.amber;
    if (controller.modelo.tas > 0.08) tasColor = Colors.orange;
    if (controller.modelo.tas > 0.15) tasColor = Colors.red;

    final tas = controller.modelo.tas;
    final percentage = (tas / 0.4).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escala de TAS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? tasColor.withValues(alpha: 0.7) : tasColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: [
            _buildTasMarker(Colors.green, '0.00-0.05'),
            _buildTasMarker(Colors.amber, '0.05-0.08'),
            _buildTasMarker(Colors.orange, '0.08-0.15'),
            _buildTasMarker(Colors.red, '0.15+'),
          ],
        ),
      ],
    );
  }

  Widget _buildTasMarker(Color color, String label) {
    final isDark = ThemeManager().isDark.value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.7) : color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryTime() {
    if (controller.modelo.tas <= 0.05) {
      return Container();
    }

    final horasParaLimite =
        AlcoolSangueUtils.calcularHorasParaLimite(controller.modelo.tas);
    final horas = horasParaLimite.floor();
    final minutos = ((horasParaLimite - horas) * 60).round();

    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      color:
          isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tempo estimado para poder dirigir:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${horas}h ${minutos}min',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Limites Legais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLimitInfoStacked('Brasil', '0.05%', Colors.amber),
                    _buildLimitInfoStacked('EUA', '0.08%', Colors.orange),
                    _buildLimitInfoStacked(
                        'Reino Unido', '0.08%', Colors.orange),
                  ],
                )
              : Column(
                  children: [
                    _buildLimitInfo('Brasil', '0.05%', Colors.amber),
                    _buildLimitInfo('EUA', '0.08%', Colors.orange),
                    _buildLimitInfo('Reino Unido', '0.08%', Colors.orange),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildLimitInfo(String lugar, String limite, Color cor) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lugar,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? cor.withValues(alpha: 0.2) : cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? cor.withValues(alpha: 0.3) : cor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              limite,
              style: TextStyle(
                color: isDark ? cor : cor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitInfoStacked(String lugar, String limite, Color cor) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lugar,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? cor.withValues(alpha: 0.2) : cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? cor.withValues(alpha: 0.3) : cor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              limite,
              style: TextStyle(
                color: isDark ? cor : cor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
