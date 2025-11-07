import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';

/// Enhanced statistics card with improved empty state handling
class EnhancedStatisticsCard extends StatelessWidget {

  const EnhancedStatisticsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.primaryValue,
    required this.secondaryValue,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.percentageChange,
    this.isPositiveChange,
    this.state = StatisticsCardState.hasData,
    this.onRefresh,
    this.onAddData,
  });
  final String title;
  final IconData icon;
  final Color iconColor;
  final String primaryValue;
  final String secondaryValue;
  final String primaryLabel;
  final String secondaryLabel;
  final String? percentageChange;
  final bool? isPositiveChange;
  final StatisticsCardState state;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddData;

  @override
  Widget build(BuildContext context) {
    return SemanticCard(
      semanticLabel: 'Estatísticas de $title',
      semanticHint: _getSemanticHint(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(context),
            width: state == StatisticsCardState.noData ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildContent(context),
            if (state == StatisticsCardState.noData) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemanticText.heading(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              _buildStateIndicator(context),
            ],
          ),
        ),
        if (state == StatisticsCardState.hasData && onRefresh != null)
          IconButton(
            onPressed: onRefresh,
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            tooltip: 'Atualizar dados',
          ),
      ],
    );
  }

  Widget _buildStateIndicator(BuildContext context) {
    switch (state) {
      case StatisticsCardState.loading:
        return Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case StatisticsCardState.noData:
        return Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 12,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 6),
            Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case StatisticsCardState.hasData:
        if (percentageChange != null && isPositiveChange != null) {
          return Row(
            children: [
              Icon(
                isPositiveChange! ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isPositiveChange! ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                percentageChange!,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositiveChange! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
      case StatisticsCardState.loading:
        return _buildLoadingContent();
      case StatisticsCardState.noData:
        return _buildNoDataContent(context);
      case StatisticsCardState.hasData:
        return _buildDataContent(context);
    }
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 20,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.data_usage_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                'Adicione registros para ver estatísticas',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatColumn(
            context,
            primaryValue,
            primaryLabel,
            true,
          ),
        ),
        Container(
          height: 60,
          width: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        Expanded(
          child: _buildStatColumn(
            context,
            secondaryValue,
            secondaryLabel,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String value,
    String label,
    bool isPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SemanticText(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 24 : 20,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
            color: isPrimary 
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        SemanticText.label(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddData,
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Adicionar dados',
              style: TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
              foregroundColor: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (onRefresh != null)
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Atualizar', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  Color _getBorderColor(BuildContext context) {
    switch (state) {
      case StatisticsCardState.loading:
        return iconColor.withValues(alpha: 0.3);
      case StatisticsCardState.noData:
        return Theme.of(context).colorScheme.error.withValues(alpha: 0.4);
      case StatisticsCardState.hasData:
        return Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
    }
  }

  String _getSemanticHint() {
    switch (state) {
      case StatisticsCardState.loading:
        return 'Carregando dados de $title';
      case StatisticsCardState.noData:
        return 'Nenhum dado disponível para $title. Toque em adicionar dados para começar';
      case StatisticsCardState.hasData:
        return 'Estatísticas de $title: $primaryLabel $primaryValue, $secondaryLabel $secondaryValue';
    }
  }
}

/// Enhanced statistics section with better data handling
class EnhancedStatisticsSection extends StatelessWidget {

  const EnhancedStatisticsSection({
    super.key,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.hasData,
    required this.currentMonthStats,
    required this.currentYearStats,
    required this.monthlyComparisons,
    required this.yearlyComparisons,
    this.onRefresh,
    this.onAddFuel,
    this.onAddExpense,
  });
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasData;
  final Map<String, String> currentMonthStats;
  final Map<String, String> currentYearStats;
  final Map<String, String> monthlyComparisons;
  final Map<String, String> yearlyComparisons;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddFuel;
  final VoidCallback? onAddExpense;

  @override
  Widget build(BuildContext context) {
    final cardState = _getCardState();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 20),
        if (hasError && errorMessage != null) ...[
          _buildErrorState(context),
          const SizedBox(height: 20),
        ],
        _buildStatisticsGrid(context, cardState),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.analytics_outlined,
          color: GasometerDesignTokens.colorAnalyticsBlue,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemanticText.heading(
                'Resumo Estatístico',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              SemanticText.subtitle(
                'Visão geral dos seus gastos com veículos',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (hasData && onRefresh != null)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Atualizar estatísticas',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erro ao carregar dados',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                Text(
                  errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            TextButton(
              onPressed: onRefresh,
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, StatisticsCardState cardState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        if (isTablet) {
          return Row(
            children: [
              Expanded(child: _buildFuelCard(cardState)),
              const SizedBox(width: 16),
              Expanded(child: _buildConsumptionCard(cardState)),
              const SizedBox(width: 16),
              Expanded(child: _buildDistanceCard(cardState)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildFuelCard(cardState),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildConsumptionCard(cardState)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDistanceCard(cardState)),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFuelCard(StatisticsCardState cardState) {
    final fuelSpentGrowth = yearlyComparisons['fuel_spent_growth'];
    final isPositive = fuelSpentGrowth != null && fuelSpentGrowth != '0%'
        ? !fuelSpentGrowth.contains('-')
        : null;

    return EnhancedStatisticsCard(
      title: 'Abastecimento',
      icon: Icons.local_gas_station,
      iconColor: GasometerDesignTokens.colorAnalyticsBlue,
      primaryValue: currentYearStats['fuel_spent'] ?? 'R\$ 0,00',
      secondaryValue: currentMonthStats['fuel_spent'] ?? 'R\$ 0,00',
      primaryLabel: 'Este Ano',
      secondaryLabel: 'Este Mês',
      percentageChange: fuelSpentGrowth != '0%' ? fuelSpentGrowth : null,
      isPositiveChange: isPositive,
      state: cardState,
      onRefresh: onRefresh,
      onAddData: onAddFuel,
    );
  }

  Widget _buildConsumptionCard(StatisticsCardState cardState) {
    return EnhancedStatisticsCard(
      title: 'Combustível',
      icon: Icons.opacity,
      iconColor: GasometerDesignTokens.colorAnalyticsGreen,
      primaryValue: currentYearStats['fuel_liters'] ?? '0,0L',
      secondaryValue: currentMonthStats['fuel_liters'] ?? '0,0L',
      primaryLabel: 'Este Ano',
      secondaryLabel: 'Este Mês',
      state: cardState,
      onRefresh: onRefresh,
      onAddData: onAddFuel,
    );
  }

  Widget _buildDistanceCard(StatisticsCardState cardState) {
    final distanceGrowth = yearlyComparisons['distance_growth'];
    final isPositive = distanceGrowth != null && distanceGrowth != '0%'
        ? !distanceGrowth.contains('-')
        : null;

    return EnhancedStatisticsCard(
      title: 'Distância',
      icon: Icons.straighten,
      iconColor: GasometerDesignTokens.colorAnalyticsPurple,
      primaryValue: currentYearStats['distance'] ?? '0 km',
      secondaryValue: currentMonthStats['distance'] ?? '0 km',
      primaryLabel: 'Este Ano',
      secondaryLabel: 'Este Mês',
      percentageChange: distanceGrowth != '0%' ? distanceGrowth : null,
      isPositiveChange: isPositive,
      state: cardState,
      onRefresh: onRefresh,
      onAddData: onAddExpense,
    );
  }

  StatisticsCardState _getCardState() {
    if (isLoading) return StatisticsCardState.loading;
    if (!hasData) return StatisticsCardState.noData;
    return StatisticsCardState.hasData;
  }
}

enum StatisticsCardState {
  loading,
  noData,
  hasData,
}
