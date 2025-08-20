// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../controllers/external_actions_controller.dart';
import '../controllers/more_controller.dart';
import '../services/navigation_service.dart';
import '../utils/more_constants.dart';
import '../utils/more_helpers.dart';
import '../widgets/menu_item_widget.dart';
import '../widgets/menu_section_widget.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  late MoreController _controller;
  late ExternalActionsController _externalActionsController;

  @override
  void initState() {
    super.initState();
    _controller = MoreController();
    _externalActionsController = ExternalActionsController();
    
    // Set navigation context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().setContext(context);
      _initializeControllers();
    });
  }

  Future<void> _initializeControllers() async {
    await Future.wait([
      _controller.initialize(),
      _externalActionsController.initialize(),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _externalActionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _controller),
        ChangeNotifierProvider.value(value: _externalActionsController),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<MoreController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return MoreHelpers.buildLoadingWidget();
            }

            if (controller.hasError) {
              return MoreHelpers.buildErrorWidget(
                controller.errorMessage ?? MoreConstants.defaultErrorMessage,
                onRetry: () => controller.refresh(),
              );
            }

            if (!controller.hasSections) {
              return MoreHelpers.buildEmptyWidget(MoreConstants.infoNoItems);
            }

            return _buildContent(context, controller);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MoreController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(MoreConstants.defaultPadding),
        children: [
          if (MoreConstants.enableSearch) _buildSearchHeader(context),
          const SizedBox(height: MoreConstants.sectionSpacing),
          ..._buildSections(context, controller),
          const SizedBox(height: MoreConstants.sectionSpacing),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MoreConstants.defaultPadding),
        child: Row(
          children: [
            const Icon(Icons.search, size: MoreConstants.iconSize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buscar em ${_controller.sectionCount} seções...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterOptions,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, MoreController controller) {
    return controller.visibleSections.map((section) {
      if (MoreConstants.enableSectionCollapse) {
        return MenuSectionWidget(
          key: ValueKey(section.id),
          section: section,
          isExpanded: controller.isSectionExpanded(section.id),
          onExpansionChanged: (expanded) {
            controller.toggleSectionExpansion(section.id);
          },
          onItemTap: (item) => controller.handleItemTap(item),
          enableCollapse: true,
        );
      } else {
        return MenuSectionWidget(
          key: ValueKey(section.id),
          section: section,
          onItemTap: (item) => controller.handleItemTap(item),
          enableCollapse: false,
        );
      }
    }).toList();
  }

  Widget _buildFooter(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MoreConstants.defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MoreConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'v${MoreConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Feito com ❤️ para o cuidado dos pets',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (MoreConstants.enableDebugMode) ...[
              const SizedBox(height: 12),
              _buildDebugInfo(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo(BuildContext context) {
    return Consumer<MoreController>(
      builder: (context, controller, child) {
        final stats = controller.getPageStatistics();
        
        return ExpansionTile(
          title: const Text('Debug Info', style: TextStyle(fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seções: ${stats['totalSections']}', style: const TextStyle(fontSize: 10)),
                  Text('Itens: ${stats['totalItems']}', style: const TextStyle(fontSize: 10)),
                  Text('Última interação: ${stats['lastInteraction'] ?? 'Nenhuma'}', style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: controller.expandAllSections,
                        child: const Text('Expandir Tudo', style: TextStyle(fontSize: 10)),
                      ),
                      ElevatedButton(
                        onPressed: controller.collapseAllSections,
                        child: const Text('Contrair Tudo', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterOptionsSheet(controller: _controller),
    );
  }
}

class _FilterOptionsSheet extends StatelessWidget {
  final MoreController controller;

  const _FilterOptionsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MoreConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text(
                'Opções de Filtro',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Seções',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: controller.sections.map((section) {
              final isExpanded = controller.isSectionExpanded(section.id);
              return FilterChip(
                label: Text(section.title),
                selected: isExpanded,
                onSelected: (selected) {
                  controller.setSectionExpansion(section.id, selected);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  controller.expandAllSections();
                  Navigator.of(context).pop();
                },
                child: const Text('Expandir Todas'),
              ),
              TextButton(
                onPressed: () {
                  controller.collapseAllSections();
                  Navigator.of(context).pop();
                },
                child: const Text('Contrair Todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CompactMorePage extends StatelessWidget {
  const CompactMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoreController()..initialize(),
      child: Scaffold(
        body: Consumer<MoreController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return MoreHelpers.buildLoadingWidget();
            }

            if (controller.hasError) {
              return MoreHelpers.buildErrorWidget(
                controller.errorMessage ?? MoreConstants.defaultErrorMessage,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(8),
              children: controller.visibleSections.map((section) {
                return CompactMenuSectionWidget(
                  section: section,
                  onItemTap: (item) => controller.handleItemTap(item),
                  maxItems: 3,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class GridMorePage extends StatelessWidget {
  final int crossAxisCount;

  const GridMorePage({super.key, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoreController()..initialize(),
      child: Scaffold(
        body: Consumer<MoreController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return MoreHelpers.buildLoadingWidget();
            }

            if (controller.hasError) {
              return MoreHelpers.buildErrorWidget(
                controller.errorMessage ?? MoreConstants.defaultErrorMessage,
              );
            }

            final allItems = controller.sections
                .expand((section) => section.visibleItems)
                .toList();

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                return GridMenuItemWidget(
                  item: item,
                  onTap: () => controller.handleItemTap(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
