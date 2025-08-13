// Flutter imports:
import 'package:flutter/material.dart';

/// Widget específico de item de indicação de defensivo para pragas
class PragaIndicacaoItem extends StatelessWidget {
  final Map<dynamic, dynamic> indicacao;
  final VoidCallback onTap;

  const PragaIndicacaoItem({
    super.key,
    required this.indicacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildLeadingAvatar(),
        title: Text(
          indicacao['nomeDefensivo'] ?? 'Defensivo não especificado',
          maxLines: 1,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    final nome = indicacao['nomeDefensivo'] ?? 'NA';
    final initials = nome.length >= 2 ? nome.substring(0, 2).toUpperCase() : 'NA';

    return CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (indicacao['ingredienteAtivo'] != null)
          Text(
            indicacao['ingredienteAtivo'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        if (indicacao['dosagem'] != null)
          Text(
            'Dosagem: ${indicacao['dosagem']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
      ],
    );
  }
}
