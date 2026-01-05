import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../domain/models/dashboard_indicator.dart';

/// Dashboard indicators (warning lights) list page
class DashboardIndicatorsPage extends StatefulWidget {
  const DashboardIndicatorsPage({super.key});

  @override
  State<DashboardIndicatorsPage> createState() => _DashboardIndicatorsPageState();
}

class _DashboardIndicatorsPageState extends State<DashboardIndicatorsPage> {
  final _searchController = TextEditingController();
  List<DashboardIndicator> _filteredIndicators = DashboardIndicatorDatabase.indicators;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIndicators = DashboardIndicatorDatabase.indicators;
      } else {
        _filteredIndicators = DashboardIndicatorDatabase.search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Group by severity
    final critical = _filteredIndicators
        .where((i) => i.severity == IndicatorSeverity.critical)
        .toList();
    final warning = _filteredIndicators
        .where((i) => i.severity == IndicatorSeverity.warning)
        .toList();
    final information = _filteredIndicators
        .where((i) => i.severity == IndicatorSeverity.information)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (critical.isNotEmpty) ...[
                    _buildSectionHeader(
                      'CRÍTICO',
                      'Pare imediatamente',
                      Colors.red,
                      Icons.error,
                    ),
                    const SizedBox(height: 12),
                    ...critical.map((indicator) => _buildIndicatorCard(indicator)),
                    const SizedBox(height: 24),
                  ],
                  if (warning.isNotEmpty) ...[
                    _buildSectionHeader(
                      'ATENÇÃO',
                      'Verificar o quanto antes',
                      Colors.orange,
                      Icons.warning,
                    ),
                    const SizedBox(height: 12),
                    ...warning.map((indicator) => _buildIndicatorCard(indicator)),
                    const SizedBox(height: 24),
                  ],
                  if (information.isNotEmpty) ...[
                    _buildSectionHeader(
                      'INFORMATIVO',
                      'Funções ativas',
                      Colors.blue,
                      Icons.info,
                    ),
                    const SizedBox(height: 12),
                    ...information.map((indicator) => _buildIndicatorCard(indicator)),
                  ],
                  if (_filteredIndicators.isEmpty) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum indicador encontrado',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Luzes do Painel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Entenda os indicadores do seu veículo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
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

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar indicador...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark 
              ? theme.colorScheme.surfaceContainerHighest 
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorCard(DashboardIndicator indicator) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/tools/dashboard-indicators/${indicator.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicator icon circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: indicator.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicator.color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  indicator.icon,
                  color: indicator.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Indicator info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indicator.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      indicator.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: indicator.severityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            indicator.severityLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: indicator.severityColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          indicator.canDrive ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: indicator.canDrive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          indicator.canDrive ? 'Pode dirigir' : 'Não dirija',
                          style: TextStyle(
                            fontSize: 11,
                            color: indicator.canDrive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
