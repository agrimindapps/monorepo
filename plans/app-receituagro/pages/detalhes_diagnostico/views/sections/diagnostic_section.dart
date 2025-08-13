// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../controller/detalhes_diagnostico_controller.dart';

class DiagnosticSection extends StatelessWidget {
  final DetalhesDiagnosticoController controller;
  
  const DiagnosticSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        final diagnostico = controller.diagnostico.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiagnosticCard(diagnostico, context, themeController.isDark.value),
          ],
        );
      }),
    );
  }

  Widget _buildDiagnosticCard(dynamic diagnostico, BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _cardDecoration(context, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: _createDiagnosticGradient(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesome.clipboard_check_solid,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Diagnóstico',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  context,
                  'Dosagem',
                  diagnostico.dosagem,
                  FontAwesome.flask_solid,
                  const Color(0xFF2E7D32),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Vazão Terrestre',
                  diagnostico.vazaoTerrestre,
                  FontAwesome.tractor_solid,
                  const Color(0xFF388E3C),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Vazão Aérea',
                  diagnostico.vazaoAerea,
                  FontAwesome.plane_solid,
                  const Color(0xFF43A047),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Intervalo de Aplicação',
                  diagnostico.intervaloAplicacao,
                  FontAwesome.clock_solid,
                  const Color(0xFF4CAF50),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Intervalo de Segurança',
                  diagnostico.intervaloSeguranca,
                  FontAwesome.shield_halved_solid,
                  const Color(0xFF66BB6A),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    final displayValue = value.isEmpty ? 'Não especificado' : value;
    final isSpecified = value.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? Colors.grey.shade700
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSpecified
                        ? (isDark ? Colors.grey.shade300 : Colors.grey.shade600)
                        : Colors.grey.shade500,
                    fontStyle: isSpecified ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E22) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  LinearGradient _createDiagnosticGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2E7D32), // Verde para manter consistência
        Color(0xFF1B5E20),
      ],
    );
  }
}
