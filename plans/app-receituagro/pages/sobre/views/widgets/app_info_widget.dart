// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/sobre_model.dart';

class AppInfoWidget extends StatelessWidget {
  final SobreModel sobreData;
  final String versaoAtual;
  final bool isDark;
  final VoidCallback onVersionTap;

  const AppInfoWidget({
    super.key,
    required this.sobreData,
    required this.versaoAtual,
    required this.isDark,
    required this.onVersionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 16),
        _buildVersionCard(),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Image.asset(
        sobreData.logoPath,
        width: 150,
      ),
    );
  }

  Widget _buildVersionCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Center(
              child: Text(
                versaoAtual,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            subtitle: Center(
              child: Text(
                'Informações da Versão',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            titleAlignment: ListTileTitleAlignment.top,
            visualDensity: VisualDensity.compact,
            onTap: onVersionTap,
          ),
        ],
      ),
    );
  }
}
