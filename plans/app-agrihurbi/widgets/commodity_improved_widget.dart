// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../models/commodity_model.dart';
import '../services/commodity_service.dart';
import 'loading_widgets.dart';

class CommodityImprovedWidget extends StatefulWidget {
  const CommodityImprovedWidget({super.key});

  @override
  State<CommodityImprovedWidget> createState() =>
      _CommodityImprovedWidgetState();
}

class _CommodityImprovedWidgetState extends State<CommodityImprovedWidget> {
  late final CommodityService commodityService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      commodityService = Get.find<CommodityService>();
    } catch (e) {
      commodityService = Get.put(CommodityService());
    }

    // Initialize sem setState
    Future.microtask(() {
      commodityService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Cotações',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(() {
          if (commodityService.isLoading &&
              commodityService.commodities.isEmpty) {
            return SizedBox(
              height: 200,
              child: Card(
                child: AgrihurbiLoading.loadingCommodities(),
              ),
            );
          }

          return Column(
            children: [
              _buildMarketStatusCard(commodityService.marketStatus),
              const SizedBox(height: 8),
              _buildCommoditiesCard(commodityService.commodities),
              if (commodityService.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    commodityService.errorMessage,
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMarketStatusCard(CommodityMarketStatus? status) {
    if (status == null) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: Card(
        color: status.isOpen ? Colors.green.shade50 : Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.isOpen ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      status.status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (status.nextOpen != null || status.nextClose != null)
                      Text(
                        status.isOpen
                            ? 'Fecha às ${DateFormat('HH:mm').format(status.nextClose!)}'
                            : 'Abre às ${DateFormat('HH:mm').format(status.nextOpen!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                status.isOpen ? Icons.trending_up : Icons.schedule,
                color: status.isOpen ? Colors.green : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommoditiesCard(List<CommodityModel> commodities) {
    if (commodities.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Card(
          child: Center(
            child: Text('Nenhuma cotação disponível'),
          ),
        ),
      );
    }

    final displayCommodities = commodities.take(5).toList();

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListView.separated(
                separatorBuilder: (context, index) => const Divider(height: 1),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayCommodities.length,
                itemBuilder: (context, index) {
                  final commodity = displayCommodities[index];
                  return _buildCommodityItem(commodity);
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Atualizado em ${DateFormat('HH:mm').format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implementar página de detalhes de commodities
                        // Navigator.push(
                        //   Get.context!,
                        //   MaterialPageRoute(
                        //     builder: (context) => CommoditiesDetalhesPage(),
                        //   ),
                        // );
                      },
                      child: const Text('Ver mais'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommodityItem(CommodityModel commodity) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: commodity.trendColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            CommodityService.instance.getCommodityIcon(commodity.category),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: Text(
        commodity.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        commodity.unit,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            commodity.formattedPrice,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                commodity.isUp
                    ? Icons.arrow_upward
                    : commodity.isDown
                        ? Icons.arrow_downward
                        : Icons.remove,
                size: 12,
                color: commodity.trendColor,
              ),
              const SizedBox(width: 2),
              Text(
                commodity.formattedChange,
                style: TextStyle(
                  fontSize: 12,
                  color: commodity.trendColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      visualDensity: VisualDensity.compact,
      onTap: () => _showCommodityDetails(commodity),
    );
  }

  void _showCommodityDetails(CommodityModel commodity) {
    Get.bottomSheet(
      CommodityDetailsBottomSheet(commodity: commodity),
      isScrollControlled: true,
    );
  }
}

class CommodityDetailsBottomSheet extends StatelessWidget {
  final CommodityModel commodity;

  const CommodityDetailsBottomSheet({
    super.key,
    required this.commodity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPriceInfo(),
                  const SizedBox(height: 20),
                  _buildStatistics(),
                  const SizedBox(height: 20),
                  _buildMetadata(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: commodity.trendColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              CommodityService.instance.getCommodityIcon(commodity.category),
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commodity.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${commodity.exchange} • ${commodity.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  commodity.formattedPrice,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: commodity.trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        commodity.isUp
                            ? Icons.trending_up
                            : commodity.isDown
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        size: 16,
                        color: commodity.trendColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        commodity.formattedChange,
                        style: TextStyle(
                          color: commodity.trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Variação: ${commodity.formattedChangeValue}',
              style: TextStyle(
                color: commodity.trendColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(commodity.lastUpdate)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = commodity.history.stats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas (52 semanas)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem('Máxima',
                'R\$ ${stats.high52Week.toStringAsFixed(2).replaceAll('.', ',')}'),
            _buildStatItem('Mínima',
                'R\$ ${stats.low52Week.toStringAsFixed(2).replaceAll('.', ',')}'),
            _buildStatItem('Média (30 dias)',
                'R\$ ${stats.average30Day.toStringAsFixed(2).replaceAll('.', ',')}'),
            _buildStatItem('Volatilidade',
                '${(stats.volatility * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    if (commodity.metadata.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Adicionais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...commodity.metadata.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatMetadataKey(entry.key),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'region':
        return 'Região';
      case 'quality':
        return 'Qualidade';
      case 'weight':
        return 'Peso';
      default:
        return key.capitalize ?? key;
    }
  }
}

class CommodityDetailPage extends StatelessWidget {
  const CommodityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final commodityService = Get.find<CommodityService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações Detalhadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => commodityService.fetchLatestPrices(),
          ),
        ],
      ),
      body: Obx(() {
        if (commodityService.isLoading &&
            commodityService.commodities.isEmpty) {
          return AgrihurbiLoading.loadingCommodities();
        }

        final categories = commodityService.categories;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMarketOverview(commodityService),
              const SizedBox(height: 20),
              ...categories.map((category) => _buildCategorySection(
                    category,
                    commodityService.getCommoditiesByCategory(category.id),
                  )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMarketOverview(CommodityService service) {
    final topMovers = service.getTopMovers();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral do Mercado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topMovers.isNotEmpty)
              Text(
                'Maior alta: ${topMovers.first.name} (${topMovers.first.formattedChange})',
                style: TextStyle(color: topMovers.first.trendColor),
              ),
            if (topMovers.length > 1)
              Text(
                'Maior queda: ${topMovers.last.name} (${topMovers.last.formattedChange})',
                style: TextStyle(color: topMovers.last.trendColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      CommodityCategory category, List<CommodityModel> commodities) {
    if (commodities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                category.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: commodities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final commodity = commodities[index];
              return ListTile(
                title: Text(commodity.name),
                subtitle: Text(commodity.unit),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      commodity.formattedPrice,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      commodity.formattedChange,
                      style: TextStyle(
                        color: commodity.trendColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
