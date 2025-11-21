import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

/// Widget especializado para exibir dados técnicos de aplicação
/// Mostra dosagem, intervalos, épocas de aplicação e métodos
class DadosTecnicosWidget extends StatelessWidget {
  final Map<String, String> dadosTecnicos;
  final bool temAplicacaoTerrestre;
  final bool temAplicacaoAerea;
  final String? aplicacaoTerrestre;
  final String? aplicacaoAerea;

  const DadosTecnicosWidget({
    super.key,
    required this.dadosTecnicos,
    this.temAplicacaoTerrestre = false,
    this.temAplicacaoAerea = false,
    this.aplicacaoTerrestre,
    this.aplicacaoAerea,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme),
        const SizedBox(height: 16),
        _buildDadosTecnicosCards(theme),
        if (temAplicacaoTerrestre || temAplicacaoAerea) ...[
          const SizedBox(height: 16),
          _buildAplicacaoMethods(theme),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.engineering,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Dados Técnicos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDadosTecnicosCards(ThemeData theme) {
    return Column(
      children: dadosTecnicos.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildDadoTecnicoCard(theme, entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildDadoTecnicoCard(ThemeData theme, String label, String valor) {
    final config = _getDadoTecnicoConfig(label);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (config.descricao != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    config.descricao!,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAplicacaoMethods(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métodos de Aplicação',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (temAplicacaoTerrestre) 
              Expanded(
                child: _buildAplicacaoCard(
                  theme: theme,
                  tipo: 'Aplicação Terrestre',
                  valor: aplicacaoTerrestre ?? 'N/A',
                  icon: FontAwesomeIcons.tractor,
                  color: Colors.brown,
                ),
              ),
            if (temAplicacaoTerrestre && temAplicacaoAerea) 
              const SizedBox(width: 12),
            if (temAplicacaoAerea) 
              Expanded(
                child: _buildAplicacaoCard(
                  theme: theme,
                  tipo: 'Aplicação Aérea',
                  valor: aplicacaoAerea ?? 'N/A',
                  icon: FontAwesomeIcons.helicopter,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAplicacaoCard({
    required ThemeData theme,
    required String tipo,
    required String valor,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  DadoTecnicoConfig _getDadoTecnicoConfig(String label) {
    switch (label.toLowerCase()) {
      case 'dosagem':
        return DadoTecnicoConfig(
          icon: Icons.medication,
          color: Colors.green,
          descricao: 'Quantidade de produto por hectare',
        );
      case 'intervalo':
      case 'intervalo de aplicação':
        return DadoTecnicoConfig(
          icon: Icons.schedule,
          color: Colors.orange,
          descricao: 'Tempo entre aplicações',
        );
      case 'época de aplicação':
        return DadoTecnicoConfig(
          icon: FontAwesomeIcons.calendar,
          color: Colors.purple,
          descricao: 'Período recomendado para aplicação',
        );
      case 'modo de ação':
        return DadoTecnicoConfig(
          icon: FontAwesomeIcons.bolt,
          color: Colors.red,
          descricao: 'Como o produto atua na praga',
        );
      case 'formulação':
        return DadoTecnicoConfig(
          icon: FontAwesomeIcons.vial,
          color: Colors.blue,
          descricao: 'Tipo de formulação do produto',
        );
      case 'intervalo de segurança':
        return DadoTecnicoConfig(
          icon: FontAwesomeIcons.shield,
          color: Colors.amber,
          descricao: 'Tempo de espera antes da colheita',
        );
      default:
        return DadoTecnicoConfig(
          icon: Icons.info,
          color: Colors.grey,
        );
    }
  }
}

class DadoTecnicoConfig {
  final IconData icon;
  final Color color;
  final String? descricao;

  DadoTecnicoConfig({
    required this.icon,
    required this.color,
    this.descricao,
  });
}
