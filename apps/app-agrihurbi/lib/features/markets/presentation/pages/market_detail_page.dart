import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/presentation/providers/market_provider.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_info_card.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_price_chart.dart';
import 'package:app_agrihurbi/features/markets/presentation/widgets/market_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Market Detail Page
/// 
/// Displays detailed information about a specific market
/// including price charts, statistics, and real-time updates
class MarketDetailPage extends StatefulWidget {
  final String marketId;

  const MarketDetailPage({
    super.key,
    required this.marketId,
  });

  @override
  State<MarketDetailPage> createState() => _MarketDetailPageState();
}

class _MarketDetailPageState extends State<MarketDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  MarketEntity? _market;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<MarketProvider>();
      
      // Load market details
      final market = await provider.getMarketById(widget.marketId);
      
      if (market != null) {
        final isFavorite = await provider.isMarketFavorite(widget.marketId);
        
        setState(() {
          _market = market;
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Mercado não encontrado';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados do mercado';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_market == null) return;

    final provider = context.read<MarketProvider>();
    final newStatus = await provider.toggleFavorite(_market!.id);
    
    setState(() {
      _isFavorite = newStatus;
    });

    final message = newStatus 
        ? 'Adicionado aos favoritos' 
        : 'Removido dos favoritos';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_market?.name ?? 'Carregando...'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textLightColor,
        actions: [
          if (_market != null) ...[
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppTheme.textLightColor,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareMarket,
            ),
          ],
        ],
        bottom: _market != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.textLightColor,
                labelColor: AppTheme.textLightColor,
                unselectedLabelColor: AppTheme.textLightColor.withValues(alpha: 0.7),
                tabs: const [
                  Tab(text: 'Visão Geral'),
                  Tab(text: 'Gráfico'),
                  Tab(text: 'Estatísticas'),
                ],
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_market == null) {
      return const Center(child: Text('Mercado não encontrado'));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildChartTab(),
        _buildStatsTab(),
      ],
    );
  }

  /// Build overview tab with market information
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadMarketData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Info Card
            MarketInfoCard(market: _market!),
            
            const SizedBox(height: 16),

            // Price Information
            _buildPriceSection(),
            
            const SizedBox(height: 16),

            // Market Details
            _buildMarketDetails(),
            
            const SizedBox(height: 16),

            // Status and Exchange Information
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  /// Build price section
  Widget _buildPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preço Atual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _market!.formattedPrice,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _market!.isUp 
                                ? Icons.trending_up
                                : _market!.isDown
                                    ? Icons.trending_down
                                    : Icons.trending_flat,
                            color: _market!.isUp 
                                ? DesignTokens.infoColor
                                : _market!.isDown
                                    ? AppTheme.errorColor
                                    : DesignTokens.textSecondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_market!.formattedPriceChange} (${_market!.formattedChange})',
                            style: TextStyle(
                              color: _market!.isUp 
                                  ? DesignTokens.infoColor
                                  : _market!.isDown
                                      ? AppTheme.errorColor
                                      : DesignTokens.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_market!.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _market!.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(_market!.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build market details section
  Widget _buildMarketDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Mercado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Símbolo', _market!.symbol),
            _buildInfoRow('Tipo', _market!.type.displayName),
            _buildInfoRow('Unidade', _market!.unit),
            _buildInfoRow('Bolsa', _market!.exchange),
            _buildInfoRow('Moeda', _market!.currency),
            if (_market!.description != null)
              _buildInfoRow('Descrição', _market!.description!),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Build status section
  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Mercado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getStatusIcon(_market!.status),
                  color: _getStatusColor(_market!.status),
                ),
                const SizedBox(width: 8),
                Text(
                  _market!.status.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${_formatDateTime(_market!.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build chart tab
  Widget _buildChartTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: MarketPriceChart(
              marketId: widget.marketId,
              market: _market!,
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics tab
  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MarketStatsGrid(market: _market!),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar mercado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMarketData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Share market information
  void _shareMarket() {
    if (_market == null) return;

    final shareText = '''
${_market!.name} (${_market!.symbol})
Preço atual: ${_market!.formattedPrice}
Variação: ${_market!.formattedChange}
Bolsa: ${_market!.exchange}

Via AgriHurbi
''';

    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de compartilhamento em desenvolvimento')),
    );
  }

  /// Get color for market status
  Color _getStatusColor(MarketStatus status) {
    switch (status) {
      case MarketStatus.open:
        return DesignTokens.infoColor;
      case MarketStatus.closed:
        return DesignTokens.textSecondaryColor;
      case MarketStatus.suspended:
        return AppTheme.warningColor;
      case MarketStatus.preMarket:
      case MarketStatus.afterMarket:
        return AppTheme.infoColor;
    }
  }

  /// Get icon for market status
  IconData _getStatusIcon(MarketStatus status) {
    switch (status) {
      case MarketStatus.open:
        return Icons.radio_button_checked;
      case MarketStatus.closed:
        return Icons.radio_button_unchecked;
      case MarketStatus.suspended:
        return Icons.pause;
      case MarketStatus.preMarket:
      case MarketStatus.afterMarket:
        return Icons.schedule;
    }
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}