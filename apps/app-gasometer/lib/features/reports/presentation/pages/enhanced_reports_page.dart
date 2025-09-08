import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fuel/presentation/pages/add_fuel_page.dart';
import '../../../fuel/presentation/providers/fuel_form_provider.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/enhanced_data_viz.dart';
import '../widgets/enhanced_statistics_cards.dart';
import '../widgets/smart_empty_state.dart';

class EnhancedReportsPage extends StatefulWidget {
  const EnhancedReportsPage({super.key});

  @override
  State<EnhancedReportsPage> createState() => _EnhancedReportsPageState();
}

class _EnhancedReportsPageState extends State<EnhancedReportsPage>
    with AutomaticKeepAliveClientMixin {
  String? _selectedVehicleId;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
    final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
    
    await vehiclesProvider.initialize();
    
    if (vehiclesProvider.vehicles.isNotEmpty) {
      final vehicleId = vehiclesProvider.vehicles.first.id;
      
      if (mounted) {
        setState(() {
          _selectedVehicleId = vehicleId;
        });
        
        await reportsProvider.loadAllReportsForVehicle(vehicleId);
      }
    }
  }

  Future<void> _onRefresh() async {
    if (_selectedVehicleId != null) {
      final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
      await reportsProvider.loadAllReportsForVehicle(_selectedVehicleId!);
    } else {
      await _initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                key: _refreshKey,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorHeaderBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticText.heading(
                  'Estatísticas Detalhadas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                SemanticText.subtitle(
                  'Analise o desempenho dos seus veículos',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer3<ReportsProvider, VehiclesProvider, AuthProvider>(
      builder: (context, reportsProvider, vehiclesProvider, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Selector
            EnhancedVehicleSelector(
              selectedVehicleId: _selectedVehicleId,
              onVehicleChanged: (String? vehicleId) {
                setState(() {
                  _selectedVehicleId = vehicleId;
                });
                
                if (vehicleId != null) {
                  reportsProvider.loadAllReportsForVehicle(vehicleId);
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Content based on state
            if (reportsProvider.isLoading && !reportsProvider.hasCurrentMonthData)
              StandardLoadingView.initial(
                message: 'Carregando estatísticas...',
                height: 400,
              )
            else if (_shouldShowEmptyState(reportsProvider, vehiclesProvider))
              _buildSmartEmptyState(reportsProvider, vehiclesProvider, authProvider)
            else ...[
              // Enhanced Statistics Dashboard
              _buildEnhancedStatisticsDashboard(reportsProvider),
              const SizedBox(height: 32),
              
              // Visual Summary Cards
              _buildVisualSummaryCards(reportsProvider),
              const SizedBox(height: 32),
              
              // Insights Section
              _buildInsightsSection(reportsProvider),
            ],
          ],
        );
      },
    );
  }

  bool _shouldShowEmptyState(ReportsProvider reportsProvider, VehiclesProvider vehiclesProvider) {
    return (!reportsProvider.isLoading && 
            !reportsProvider.hasCurrentMonthData && 
            !reportsProvider.hasCurrentYearData) ||
           vehiclesProvider.vehicles.isEmpty ||
           _selectedVehicleId == null;
  }

  Widget _buildSmartEmptyState(
    ReportsProvider reportsProvider, 
    VehiclesProvider vehiclesProvider, 
    AuthProvider authProvider
  ) {
    final hasVehicles = vehiclesProvider.vehicles.isNotEmpty;
    final isFirstTime = hasVehicles && !reportsProvider.hasCurrentMonthData && !reportsProvider.hasCurrentYearData;
    final hasError = reportsProvider.hasError;
    
    return ReportsEmptyState(
      isFirstTime: isFirstTime,
      hasVehicles: hasVehicles,
      isOnline: true, // Could be enhanced with connectivity check
      hasError: hasError,
      errorMessage: reportsProvider.errorMessage,
      onAddVehicle: () => _showAddVehicleDialog(),
      onAddFuel: () => _showAddFuelDialog(authProvider, vehiclesProvider),
      onRefresh: _onRefresh,
      onShowTutorial: () => _showTutorial(),
    );
  }

  Widget _buildEnhancedStatisticsDashboard(ReportsProvider reportsProvider) {
    return EnhancedSummaryDashboard(
      title: 'Resumo Geral',
      subtitle: 'Principais métricas do período',
      metrics: [
        SummaryMetric(
          title: 'Gastos com Combustível',
          mainValue: reportsProvider.getCurrentYearStats()['fuel_spent'] ?? 'R\$ 0,00',
          subtitle: 'Este ano',
          icon: Icons.local_gas_station,
          color: GasometerDesignTokens.colorAnalyticsBlue,
          trend: _getTrendData(reportsProvider.getYearlyComparisons(), 'fuel_spent_growth'),
          trendData: _getFuelTrendData(), // Would be populated from actual data
        ),
        SummaryMetric(
          title: 'Litros Consumidos',
          mainValue: reportsProvider.getCurrentYearStats()['fuel_liters'] ?? '0,0L',
          subtitle: 'Este ano',
          icon: Icons.opacity,
          color: GasometerDesignTokens.colorAnalyticsGreen,
          trendData: _getFuelVolumeTrendData(),
        ),
        SummaryMetric(
          title: 'Distância Percorrida',
          mainValue: reportsProvider.getCurrentYearStats()['distance'] ?? '0 km',
          subtitle: 'Este ano',
          icon: Icons.straighten,
          color: GasometerDesignTokens.colorAnalyticsPurple,
          trend: _getTrendData(reportsProvider.getYearlyComparisons(), 'distance_growth'),
          trendData: _getDistanceTrendData(),
        ),
      ],
      headerAction: IconButton(
        onPressed: () => _exportData(reportsProvider),
        icon: const Icon(Icons.file_download_outlined),
        tooltip: 'Exportar relatório',
      ),
    );
  }

  Widget _buildVisualSummaryCards(ReportsProvider reportsProvider) {
    final currentMonth = reportsProvider.getCurrentMonthStats();
    final currentYear = reportsProvider.getCurrentYearStats();
    final monthlyComparisons = reportsProvider.getMonthlyComparisons();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Detalhamento por Período',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildComparisonCard(
                    'Este Mês vs Mês Anterior',
                    currentMonth,
                    monthlyComparisons,
                    GasometerDesignTokens.colorAnalyticsBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildComparisonCard(
                    'Este Ano',
                    currentYear,
                    {},
                    GasometerDesignTokens.colorAnalyticsGreen,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildComparisonCard(
                      'Este Mês vs Anterior',
                      currentMonth,
                      monthlyComparisons,
                      GasometerDesignTokens.colorAnalyticsBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildComparisonCard(
                      'Este Ano',
                      currentYear,
                      {},
                      GasometerDesignTokens.colorAnalyticsGreen,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    String title,
    Map<String, String> stats,
    Map<String, String> comparisons,
    Color color,
  ) {
    final fuelSpent = stats['fuel_spent'] ?? 'R\$ 0,00';
    final fuelLiters = stats['fuel_liters'] ?? '0,0L';
    final distance = stats['distance'] ?? '0 km';
    
    return VisualStatisticCard(
      title: title,
      mainValue: fuelSpent,
      subtitle: '$fuelLiters • $distance',
      icon: Icons.analytics,
      iconColor: color,
      comparisons: comparisons.isNotEmpty ? [
        ComparisonItem(
          label: 'Combustível',
          value: fuelSpent,
          percentage: 85, // Would be calculated from real data
          color: color,
        ),
        ComparisonItem(
          label: 'Distância',
          value: distance,
          percentage: 70,
          color: color.withValues(alpha: 0.7),
        ),
      ] : null,
      onTap: () => _showDetailedView(title),
    );
  }

  Widget _buildInsightsSection(ReportsProvider reportsProvider) {
    final insights = _generateInsights(reportsProvider);
    
    if (insights.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Insights Inteligentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInsightCard(insight),
        )),
      ],
    );
  }

  Widget _buildInsightCard(InsightData insight) {
    return SemanticCard(
      semanticLabel: 'Insight: ${insight.title}',
      semanticHint: insight.description,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: insight.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: insight.color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                insight.icon,
                color: insight.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticText.heading(
                    insight.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SemanticText(
                    insight.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (insight.actionLabel != null)
              TextButton(
                onPressed: insight.onAction,
                style: TextButton.styleFrom(
                  foregroundColor: insight.color,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(insight.actionLabel!),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  TrendData? _getTrendData(Map<String, String> comparisons, String key) {
    final growthStr = comparisons[key];
    if (growthStr == null || growthStr == '0%') return null;
    
    final cleanGrowth = growthStr.replaceAll('%', '').replaceAll('+', '');
    final growth = double.tryParse(cleanGrowth);
    if (growth == null) return null;
    
    return TrendData(
      percentage: growth.abs(),
      isPositive: growth > 0,
      period: 'vs período anterior',
    );
  }

  List<DataPoint> _getFuelTrendData() {
    // Mock data - would be replaced with real data
    final now = DateTime.now();
    return List.generate(12, (index) => DataPoint(
      value: 300 + (index * 50) + (index % 3 * 20),
      timestamp: DateTime(now.year, now.month - (11 - index)),
      label: 'Mês ${index + 1}',
    ));
  }

  List<DataPoint> _getFuelVolumeTrendData() {
    // Mock data
    final now = DateTime.now();
    return List.generate(12, (index) => DataPoint(
      value: 40 + (index * 5) + (index % 2 * 10),
      timestamp: DateTime(now.year, now.month - (11 - index)),
      label: 'Mês ${index + 1}',
    ));
  }

  List<DataPoint> _getDistanceTrendData() {
    // Mock data
    final now = DateTime.now();
    return List.generate(12, (index) => DataPoint(
      value: 1000 + (index * 200) + (index % 4 * 100),
      timestamp: DateTime(now.year, now.month - (11 - index)),
      label: 'Mês ${index + 1}',
    ));
  }

  List<InsightData> _generateInsights(ReportsProvider reportsProvider) {
    final insights = <InsightData>[];
    
    // Mock insights - would be generated from real data analysis
    final currentMonth = reportsProvider.getCurrentMonthStats();
    final fuelSpent = currentMonth['fuel_spent'] ?? 'R\$ 0,00';
    
    if (fuelSpent != 'R\$ 0,00') {
      insights.add(InsightData(
        title: 'Consumo acima da média',
        description: 'Seus gastos este mês estão 15% acima da média dos últimos 6 meses.',
        icon: Icons.trending_up,
        color: Colors.orange,
        actionLabel: 'Ver dicas',
        onAction: () => _showFuelTips(),
      ));
      
      insights.add(InsightData(
        title: 'Oportunidade de economia',
        description: 'Com base no seu padrão de uso, você pode economizar até R\$ 120/mês otimizando suas rotas.',
        icon: Icons.savings,
        color: Colors.green,
        actionLabel: 'Saiba como',
        onAction: () => _showEconomyTips(),
      ));
    }
    
    return insights;
  }

  // Action methods
  Future<void> _showAddVehicleDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    if (result == true && mounted) {
      await _initializeData();
    }
  }

  Future<void> _showAddFuelDialog(AuthProvider authProvider, VehiclesProvider vehiclesProvider) async {
    if (_selectedVehicleId == null) return;
    
    try {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FuelFormProvider()),
            ChangeNotifierProvider.value(value: vehiclesProvider),
            ChangeNotifierProvider.value(value: authProvider),
          ],
          builder: (context, child) => AddFuelPage(vehicleId: _selectedVehicleId),
        ),
      );
      
      if (result?['success'] == true && mounted) {
        await _onRefresh();
        _showSuccessMessage(result?['message'] as String? ?? 'Abastecimento adicionado com sucesso!');
      }
    } catch (e) {
      debugPrint('Error opening add fuel dialog: $e');
      if (mounted) {
        _showErrorMessage('Erro ao abrir formulário de combustível');
      }
    }
  }

  void _showTutorial() {
    // Navigate to tutorial or show tutorial dialog
    debugPrint('Show tutorial');
  }

  void _showDetailedView(String title) {
    debugPrint('Show detailed view for: $title');
  }

  void _showFuelTips() {
    debugPrint('Show fuel tips');
  }

  void _showEconomyTips() {
    debugPrint('Show economy tips');
  }

  Future<void> _exportData(ReportsProvider reportsProvider) async {
    final csvData = await reportsProvider.exportCurrentMonthToCSV();
    if (csvData != null) {
      _showSuccessMessage('Relatório exportado com sucesso!');
    } else {
      _showErrorMessage('Erro ao exportar relatório');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class InsightData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const InsightData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onAction,
  });
}