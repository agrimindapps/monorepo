import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/weather_provider.dart';
import '../widgets/rain_gauge_card_widget.dart';
import '../widgets/rain_gauges_summary.dart';

/// Page for listing and managing rain gauges (pluviômetros)
class RainGaugesPage extends ConsumerStatefulWidget {
  const RainGaugesPage({super.key});

  @override
  ConsumerState<RainGaugesPage> createState() => _RainGaugesPageState();
}

class _RainGaugesPageState extends ConsumerState<RainGaugesPage> {
  @override
  void initState() {
    super.initState();
    // Ensure rain gauges are loaded when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).loadRainGauges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final provider = ref.read(weatherProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluviômetros'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadRainGauges(refresh: true),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadRainGauges(refresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RainGaugesSummary(
                  rainGauges: state.rainGauges,
                  isLoading: state.isRainGaugesLoading,
                ),
              ),
            ),
            if (state.isRainGaugesLoading && state.rainGauges.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.hasError && state.rainGauges.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text('Erro: ${state.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadRainGauges(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.rainGauges.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum pluviômetro encontrado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gauge = state.rainGauges[index];
                      return RainGaugeCardWidget(
                        rainGauge: gauge,
                        onTap: () {
                          context.pushNamed(
                            'weather-rain-gauges-detail',
                            pathParameters: {'id': gauge.id},
                          );
                        },
                        onEdit: () {
                          context.pushNamed(
                            'weather-rain-gauges-edit',
                            pathParameters: {'id': gauge.id},
                          );
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir Pluviômetro'),
                              content: Text(
                                'Tem certeza que deseja excluir o pluviômetro "${gauge.locationName}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            final success = await provider.deleteRainGauge(
                              gauge.id,
                            );
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pluviômetro excluído'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.errorMessage ??
                                          'Erro ao excluir pluviômetro',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      );
                    },
                    childCount: state.rainGauges.length,
                  ),
                ),
              ),
            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('weather-rain-gauges-add');
        },
        tooltip: 'Adicionar Pluviômetro',
        child: const Icon(Icons.add),
      ),
    );
  }
}
