// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../controller/detalhes_diagnostico_controller.dart';

class InfoSection extends StatelessWidget {
  final DetalhesDiagnosticoController controller;
  
  const InfoSection({
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
            _buildInfoCard(diagnostico, context, themeController.isDark.value),
          ],
        );
      }),
    );
  }


  Widget _buildInfoCard(dynamic diagnostico, BuildContext context, bool isDark) {
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
              gradient: _createPrimaryGradient(),
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
                    FontAwesome.info_solid,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Defensivos',
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
                  'Ingrediente Ativo',
                  diagnostico.ingredienteAtivo,
                  FontAwesome.flask_solid,
                  const Color(0xFF2E7D32),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Toxicologia',
                  diagnostico.toxico,
                  FontAwesome.skull_solid,
                  const Color(0xFF388E3C),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Classe Ambiental',
                  diagnostico.classAmbiental,
                  FontAwesome.leaf_solid,
                  const Color(0xFF43A047),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Classe Agronômica',
                  diagnostico.classeAgronomica,
                  FontAwesome.tractor_solid,
                  const Color(0xFF4CAF50),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Formulação',
                  diagnostico.formulacao,
                  FontAwesome.flask_vial_solid,
                  const Color(0xFF66BB6A),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Modo de Ação',
                  diagnostico.modoAcao,
                  FontAwesome.bolt_solid,
                  const Color(0xFF81C784),
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  context,
                  'Reg. MAPA',
                  diagnostico.mapa,
                  FontAwesome.address_card_solid,
                  const Color(0xFF1B5E20),
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
    Color accentColor,
    bool isDark,
  ) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 14,
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
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Não há informações',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
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
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  LinearGradient _createPrimaryGradient() {
    return const LinearGradient(
      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

}
