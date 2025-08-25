import 'package:flutter/material.dart';

import '../../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Widget especializado para comparar múltiplos defensivos
/// Mostra uma tabela comparativa side-by-side
class ComparacaoDefensivosWidget extends StatelessWidget {
  final List<DefensivoCompleto> defensivos;
  final VoidCallback onFechar;

  const ComparacaoDefensivosWidget({
    super.key,
    required this.defensivos,
    required this.onFechar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildComparacaoCards(theme),
                  _buildTabelaComparativa(theme),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.compare_arrows,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comparação de Defensivos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${defensivos.length} defensivos selecionados',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFechar,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparacaoCards(ThemeData theme) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: defensivos.length,
        itemBuilder: (context, index) {
          final defensivo = defensivos[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: _buildDefensivoComparacaoCard(theme, defensivo, index),
          );
        },
      ),
    );
  }

  Widget _buildDefensivoComparacaoCard(
    ThemeData theme, 
    DefensivoCompleto defensivo, 
    int index,
  ) {
    final cores = [Colors.blue, Colors.green, Colors.orange];
    final cor = cores[index % cores.length];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cor, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    defensivo.defensivo.nomeComum ?? defensivo.defensivo.nomeTecnico,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              defensivo.defensivo.fabricante ?? 'N/A',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricaChip(
                  theme,
                  '${defensivo.quantidadeDiagnosticos}',
                  'Usos',
                  Icons.medical_services,
                  cor,
                ),
                const SizedBox(width: 8),
                _buildMetricaChip(
                  theme,
                  defensivo.categoria.split(' ')[0],
                  'Prioridade',
                  Icons.star,
                  cor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (defensivo.temAlertas)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 12, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      'Alertas',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaChip(
    ThemeData theme,
    String valor,
    String label,
    IconData icon,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabelaComparativa(ThemeData theme) {
    final criterios = [
      {
        'titulo': 'Informações Básicas',
        'items': [
          {'label': 'Nome Comercial', 'getValue': (DefensivoCompleto d) => d.defensivo.nomeComum ?? 'N/A'},
          {'label': 'Nome Técnico', 'getValue': (DefensivoCompleto d) => d.defensivo.nomeTecnico},
          {'label': 'Fabricante', 'getValue': (DefensivoCompleto d) => d.defensivo.fabricante ?? 'N/A'},
          {'label': 'Ingrediente Ativo', 'getValue': (DefensivoCompleto d) => d.defensivo.ingredienteAtivo ?? 'N/A'},
        ],
      },
      {
        'titulo': 'Classificações',
        'items': [
          {'label': 'Classe Agronômica', 'getValue': (DefensivoCompleto d) => d.defensivo.classeAgronomica ?? 'N/A'},
          {'label': 'Modo de Ação', 'getValue': (DefensivoCompleto d) => d.defensivo.modoAcao ?? 'N/A'},
          {'label': 'Formulação', 'getValue': (DefensivoCompleto d) => d.defensivo.formulacao ?? 'N/A'},
          {'label': 'Toxicidade', 'getValue': (DefensivoCompleto d) => d.defensivo.toxico ?? 'N/A'},
        ],
      },
      {
        'titulo': 'Segurança',
        'items': [
          {'label': 'Classe Ambiental', 'getValue': (DefensivoCompleto d) => d.defensivo.classAmbiental ?? 'N/A'},
          {'label': 'Corrosivo', 'getValue': (DefensivoCompleto d) => d.defensivo.corrosivo ?? 'Não'},
          {'label': 'Inflamável', 'getValue': (DefensivoCompleto d) => d.defensivo.inflamavel ?? 'Não'},
        ],
      },
      {
        'titulo': 'Estatísticas',
        'items': [
          {'label': 'Quantidade de Usos', 'getValue': (DefensivoCompleto d) => '${d.quantidadeDiagnosticos}'},
          {'label': 'Culturas Relacionadas', 'getValue': (DefensivoCompleto d) => '${d.culturasRelacionadas.length}'},
          {'label': 'Pragas Relacionadas', 'getValue': (DefensivoCompleto d) => '${d.pragasRelacionadas.length}'},
          {'label': 'Categoria', 'getValue': (DefensivoCompleto d) => d.categoria},
        ],
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: criterios.map((criterio) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: _buildSecaoComparativa(theme, criterio),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecaoComparativa(ThemeData theme, Map<String, dynamic> criterio) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  criterio['titulo'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: (criterio['items'] as List).map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildLinhaComparativa(theme, item as Map<String, dynamic>),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaComparativa(ThemeData theme, Map<String, dynamic> item) {
    final cores = [Colors.blue, Colors.green, Colors.orange];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['label'] as String,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: defensivos.asMap().entries.map((entry) {
            final index = entry.key;
            final defensivo = entry.value;
            final valor = item['getValue'](defensivo) as String;
            final cor = cores[index % cores.length];
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < defensivos.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: cor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            valor,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}