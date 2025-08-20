// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../services/cepea_service.dart';
import 'animations.dart';

class CommoditiesAnimatedWidget extends StatefulWidget {
  const CommoditiesAnimatedWidget({super.key});

  @override
  State<CommoditiesAnimatedWidget> createState() => _CommoditiesAnimatedWidgetState();
}

class _CommoditiesAnimatedWidgetState extends State<CommoditiesAnimatedWidget> {
  final CepeaService _cepeaService = CepeaService();
  late StreamSubscription<Map<String, CommodityPrice>> _subscription;
  Map<String, CommodityPrice> _commoditiesData = {};
  DateTime _lastUpdated = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    // Inicializa o serviço
    _cepeaService.init();

    // Carrega os dados iniciais
    setState(() {
      _commoditiesData = _cepeaService.getCurrentPrices();
      _lastUpdated = _cepeaService.lastUpdate;
      _isLoading = false;
    });

    // Inscreve para receber atualizações
    _subscription = _cepeaService.pricesStream.listen((updatedData) {
      setState(() {
        _commoditiesData = updatedData;
        _lastUpdated = _cepeaService.lastUpdate;
      });
    });

    // Busca os preços mais recentes
    await _cepeaService.fetchLatestPrices();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Função para obter o ícone para cada commodity
  IconData _getIconForCommodity(String name) {
    switch (name) {
      case 'Soja':
        return FontAwesome.seedling_solid;
      case 'Milho':
        return FontAwesome.wheat_awn_solid;
      case 'Arroz':
        return FontAwesome.bowl_rice_solid;
      case 'Feijão':
        return FontAwesome.leaf_solid;
      case 'Café':
        return FontAwesome.mug_hot_solid;
      default:
        return FontAwesome.seedling_solid;
    }
  }

  // Função para obter a cor para cada commodity
  Color _getColorForCommodity(String name) {
    switch (name) {
      case 'Soja':
        return Colors.green.shade800;
      case 'Milho':
        return Colors.amber.shade800;
      case 'Arroz':
        return Colors.brown.shade400;
      case 'Feijão':
        return Colors.red.shade800;
      case 'Café':
        return Colors.brown.shade700;
      default:
        return Colors.blue.shade800;
    }
  }

  String _getFormattedUpdateTime() {
    return '${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshPrices() async {
    setState(() {
      _isLoading = true;
    });

    await _cepeaService.fetchLatestPrices();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleIn(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedFadeIn(
                    child: Text(
                      'Cotação de Commodities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                  AnimatedFadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green.shade800,
                            ),
                          )
                        else
                          AnimatedRotatingIcon(
                            icon: FontAwesome.chart_line_solid,
                            size: 16,
                            color: Colors.green.shade800,
                            isRotating: false,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          'Atualizado: ${_getFormattedUpdateTime()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              _isLoading && _commoditiesData.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : AnimatedListBuilder(
                      itemDuration: AnimationDurations.fast,
                      staggerDelay: const Duration(milliseconds: 100),
                      children: _commoditiesData.entries.map((entry) {
                        final data = entry.value;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: AnimatedContainer(
                            duration: AnimationDurations.normal,
                            curve: AnimationCurves.smooth,
                            child: Row(
                              children: [
                                AnimatedScaleIn(
                                  child: Icon(
                                    _getIconForCommodity(data.name),
                                    color: _getColorForCommodity(data.name),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedFadeIn(
                                        delay: const Duration(milliseconds: 50),
                                        child: Text(
                                          data.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      AnimatedFadeIn(
                                        delay: const Duration(milliseconds: 100),
                                        child: Text(
                                          data.unit,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    AnimatedFadeIn(
                                      delay: const Duration(milliseconds: 150),
                                      child: Text(
                                        data.formattedPrice,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        AnimatedSwitcher(
                                          duration: AnimationDurations.fast,
                                          child: Icon(
                                            data.isUp
                                                ? FontAwesome.caret_up_solid
                                                : FontAwesome.caret_down_solid,
                                            color:
                                                data.isUp ? Colors.green : Colors.red,
                                            size: 12,
                                            key: ValueKey(data.isUp),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        AnimatedFadeIn(
                                          delay: const Duration(milliseconds: 200),
                                          child: Text(
                                            data.formattedChange,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: data.isUp
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 12),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedScaleIn(
                      delay: const Duration(milliseconds: 350),
                      child: ElevatedButton.icon(
                        onPressed: _refreshPrices,
                        icon: AnimatedRotatingIcon(
                          icon: FontAwesome.arrows_rotate_solid,
                          size: 16,
                          isRotating: _isLoading,
                        ),
                        label: const Text('Atualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green.shade800,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    AnimatedScaleIn(
                      delay: const Duration(milliseconds: 400),
                      child: TextButton.icon(
                        onPressed: () {
                          // Futuramente poderá navegar para uma página detalhada de cotações
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Detalhes das cotações serão implementados em breve!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(FontAwesome.chart_column_solid, size: 16),
                        label: const Text('Ver mais detalhes'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Nota sobre a origem dos dados
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 450),
                child: AnimatedContainer(
                  duration: AnimationDurations.normal,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesome.circle_info_solid,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dados do CEPEA - Centro de Estudos Avançados em Economia Aplicada',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}