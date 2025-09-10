import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/content_section_widget.dart';
import '../../domain/entities/defensivo_entity.dart';
import 'defensivos_empty_state_widget.dart';

/// Widget simplificado para exibir lista de defensivos
/// Usa o ContentListItemWidget padrão para consistência visual
/// 
/// Características:
/// - Design consistente com home defensivos
/// - Renderização otimizada com SliverList
/// - Items limpos e minimalistas
/// - Estado vazio integrado
class DefensivosListWidget extends StatelessWidget {
  final List<DefensivoEntity> defensivos;
  final bool modoComparacao;
  final List<DefensivoEntity> defensivosSelecionados;
  final Function(DefensivoEntity) onTap;
  final Function(DefensivoEntity)? onSelecaoChanged;
  final VoidCallback onClearFilters;

  const DefensivosListWidget({
    super.key,
    required this.defensivos,
    required this.modoComparacao,
    required this.defensivosSelecionados,
    required this.onTap,
    this.onSelecaoChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (defensivos.isEmpty) {
      return DefensivosEmptyStateWidget(
        onClearFilters: onClearFilters,
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: defensivos.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            indent: 64,
            endIndent: 8,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, index) {
            final defensivo = defensivos[index];
            
            return RepaintBoundary(
              child: ContentListItemWidget(
                title: defensivo.nome,
                subtitle: _getSubtitle(defensivo),
                category: _getCategory(defensivo),
                icon: FontAwesomeIcons.sprayCan,
                iconColor: const Color(0xFF4CAF50),
                onTap: () => onTap(defensivo),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getSubtitle(DefensivoEntity defensivo) {
    if (defensivo.fabricante?.isNotEmpty == true) {
      return defensivo.fabricante!;
    }
    if (defensivo.ingredienteAtivo?.isNotEmpty == true) {
      return defensivo.ingredienteAtivo!;
    }
    return 'Defensivo';
  }

  String? _getCategory(DefensivoEntity defensivo) {
    if (defensivo.classeAgronomica?.isNotEmpty == true) {
      return defensivo.classeAgronomica;
    }
    if (defensivo.modoAcao?.isNotEmpty == true) {
      return defensivo.modoAcao;
    }
    return null;
  }
}