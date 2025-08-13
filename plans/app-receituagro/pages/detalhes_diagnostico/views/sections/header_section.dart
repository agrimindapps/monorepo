// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../controller/detalhes_diagnostico_controller.dart';

class HeaderSection extends StatelessWidget {
  final DetalhesDiagnosticoController controller;
  
  const HeaderSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      final diagnostico = controller.diagnostico.value;
      
      return Card(
        elevation: 2,
        color: isDark ? const Color(0xFF1E1E22) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDefensivoInfo(diagnostico.nomeDefensivo, isDark),
              const SizedBox(height: 12),
              _buildPragaInfo(
                diagnostico.nomePraga,
                diagnostico.nomeCientifico,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildCulturaInfo(diagnostico.cultura, isDark),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDefensivoInfo(String nomeDefensivo, bool isDark) {
    return InkWell(
      onTap: () {
        // TODO: Implementar navegação para defensivo
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.green.shade900.withValues(alpha: 0.2)
              : Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.green.shade600 : Colors.green.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesome.leaf_solid,
              size: 18,
              color: isDark ? Colors.green.shade300 : Colors.green.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Defensivo',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.green.shade300
                          : Colors.green.shade700,
                    ),
                  ),
                  Text(
                    nomeDefensivo.isNotEmpty
                        ? nomeDefensivo
                        : 'Não especificado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.green.shade300 : Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPragaInfo(String nomePraga, String nomeCientifico, bool isDark) {
    return InkWell(
      onTap: () {
        // TODO: Implementar navegação para praga
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.red.shade900.withValues(alpha: 0.2)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.red.shade600 : Colors.red.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesome.bug_solid,
              size: 18,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Praga',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    nomePraga.isNotEmpty ? nomePraga : 'Não especificada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (nomeCientifico.isNotEmpty)
                    Text(
                      nomeCientifico,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturaInfo(String cultura, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.teal.shade900.withValues(alpha: 0.2)
            : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.teal.shade600 : Colors.teal.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesome.wheat_awn_solid,
            size: 18,
            color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cultura',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                  ),
                ),
                Text(
                  cultura.isNotEmpty ? cultura : 'Não especificada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
