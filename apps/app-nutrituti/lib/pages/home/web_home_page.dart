import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../database/feature_item.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/feature_card.dart';

class WebHomePage extends ConsumerWidget {
  final List<FeatureItem> features;
  final Function(FeatureItem) onFeatureTap;
  final Map<String, Color> categoryColors;
  final VoidCallback onExit;

  const WebHomePage({
    super.key,
    required this.features,
    required this.onFeatureTap,
    required this.categoryColors,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.health_and_safety, size: 32),
            const SizedBox(width: 12),
            Text(
              'NutriTuti',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
            tooltip: 'Alternar tema',
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: onExit,
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Sair'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 24),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sua saúde em primeiro lugar',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Acesse todas as ferramentas necessárias para manter uma vida saudável e equilibrada. De cálculos nutricionais a meditação, tudo em um só lugar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    height: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 48),
                            const DailySummaryCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 150,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Ferramentas',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final feature = features[index];
                      return FeatureCard(
                        feature: feature,
                        onTap: () => onFeatureTap(feature),
                        color: categoryColors[feature.title] ??
                            Theme.of(context).colorScheme.primary,
                      );
                    },
                    childCount: features.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
