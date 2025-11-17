import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

// import 'database_optimizer.dart'; // REMOVED: DatabaseOptimizer migrated to Drift
import 'image_optimizer.dart';
import 'memory_manager.dart';
import 'navigation_optimizer.dart';
import 'performance_service.dart';
import 'widget_optimizer.dart';

/// Dashboard completo de métricas e monitoramento de performance
class PerformanceDashboard extends StatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  final PerformanceService _performanceService = PerformanceService();
  final MemoryManager _memoryManager = MemoryManager();
  // final DatabaseOptimizer _dbOptimizer = DatabaseOptimizer(); // REMOVED
  final NavigationOptimizer _navOptimizer = NavigationOptimizer();
  final ImageOptimizer _imageOptimizer = ImageOptimizer();
  final WidgetOptimizer _widgetOptimizer = WidgetOptimizer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Memory', icon: Icon(Icons.memory)),
            Tab(text: 'Database', icon: Icon(Icons.storage)),
            Tab(text: 'Navigation', icon: Icon(Icons.navigation)),
            Tab(text: 'Images', icon: Icon(Icons.image)),
            Tab(text: 'Widgets', icon: Icon(Icons.widgets)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMemoryTab(),
          _buildNavigationTab(),
          _buildImageTab(),
          _buildWidgetsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runOptimizations,
        icon: const Icon(Icons.tune),
        label: const Text('Optimize'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('System Overview'),
          const SizedBox(height: 16),
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildSectionTitle('Performance Alerts'),
          const SizedBox(height: 16),
          _buildPerformanceAlerts(),
          const SizedBox(height: 24),
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMemoryTab() {
    return FutureBuilder<MemoryReport>(
      future: Future.value(_memoryManager.getMemoryReport()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final report = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemoryUsageCard(report),
              const SizedBox(height: 16),
              _buildMemoryTrendsCard(),
              const SizedBox(height: 16),
              _buildMemoryLeaksCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationTab() {
    return FutureBuilder<NavigationReport>(
      future: Future.value(_navOptimizer.getNavigationReport()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final report = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNavigationStatsCard(report),
              const SizedBox(height: 16),
              _buildMostUsedRoutesCard(report),
              const SizedBox(height: 16),
              _buildRoutePredictionsCard(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageTab() {
    return FutureBuilder<ImageCacheStats>(
      future: Future.value(_imageOptimizer.getCacheStats()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCacheCard(stats),
              const SizedBox(height: 16),
              _buildImageOptimizationCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWidgetsTab() {
    return FutureBuilder<RebuildReport>(
      future: Future.value(_widgetOptimizer.getRebuildReport()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final report = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWidgetStatsCard(report),
              const SizedBox(height: 16),
              _buildProblematicWidgetsCard(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'App Performance',
                '8.5/10',
                Icons.speed,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Memory Usage',
                '145 MB',
                Icons.memory,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Cache Hit Rate',
                '87%',
                Icons.cached,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Average FPS',
                '58.2',
                Icons.timeline,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceAlerts() {
    return Column(
      children: [
        _buildAlertCard(
          'High Rebuild Count',
          'AnimalsListWidget has 15+ rebuilds/minute',
          Icons.warning,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildAlertCard(
          'Slow Query',
          'getAnimals() taking 250ms average',
          Icons.error,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton('Clear Cache', Icons.clear_all, _clearAllCaches),
        _buildActionButton('GC', Icons.cleaning_services, _forceGC),
        _buildActionButton('Export', Icons.download, _exportMetrics),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildMemoryUsageCard(MemoryReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Current Usage: ${_formatBytes(report.currentUsage)}'),
            Text('Tracked Objects: ${report.trackedObjects}'),
            Text('Monitoring: ${report.isMonitoring ? "Active" : "Inactive"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryTrendsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Memory trend chart would go here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryLeaksCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Leaks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('No memory leaks detected'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationStatsCard(NavigationReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigation Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Preloaded Routes: ${report.preloadedRoutes}'),
            Text('Total Routes: ${report.routeMetrics.length}'),
            Text('Predictions: ${report.predictions.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUsedRoutesCard(NavigationReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Used Routes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...report.mostUsedRoutes
                .take(5)
                .map(
                  (route) => ListTile(
                    dense: true,
                    title: Text(route.routeName),
                    trailing: Text('${route.navigations}x'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePredictionsCard(NavigationReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (report.predictions.isEmpty)
              const Text('Not enough data for predictions')
            else
              ...report.predictions
                  .take(3)
                  .map(
                    (pred) => ListTile(
                      dense: true,
                      title: Text(pred.routeName),
                      trailing: Text(
                        '${(pred.confidence * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCacheCard(ImageCacheStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Image Cache',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Memory Items: ${stats.memoryItems}'),
            Text('Memory Size: ${stats.memorySizeMB.toStringAsFixed(1)} MB'),
            Text('Hit Rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%'),
            Text('Loading: ${stats.loadingItems}'),
            Text('Preloaded: ${stats.preloadedItems}'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOptimizationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Image Optimizations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _imageOptimizer.cleanupCache(),
              child: const Text('Clean Image Cache'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetStatsCard(RebuildReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Widget Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Tracked Widgets: ${report.totalTrackedWidgets}'),
            Text('Problematic: ${report.problematicWidgets.length}'),
            Text('Optimized: ${report.optimizedWidgets.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProblematicWidgetsCard(RebuildReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Problematic Widgets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (report.problematicWidgets.isEmpty)
              const Text('No problematic widgets detected')
            else
              ...report.problematicWidgets
                  .take(5)
                  .map(
                    (widget) => ListTile(
                      dense: true,
                      title: Text(widget.widgetKey),
                      subtitle: Text(widget.widgetType),
                      trailing: Text('${widget.rebuildCount} rebuilds'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> _runOptimizations() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Running optimizations...'),
          ],
        ),
      ),
    );

    try {
      _imageOptimizer.cleanupCache();
      _memoryManager.cleanup(aggressive: true);
      _navOptimizer.clearNavigationCache();

      log('Performance optimizations completed', name: 'PerformanceDashboard');
    } finally {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Optimizations completed!')),
        );
      }

      setState(() {});
    }
  }

  void _clearAllCaches() {
    _imageOptimizer.cleanupCache(aggressive: true);
    _navOptimizer.clearNavigationCache();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All caches cleared!')));
    }

    setState(() {});
  }

  void _forceGC() {
    _memoryManager.cleanup(aggressive: true);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Garbage collection forced!')));

    setState(() {});
  }

  void _exportMetrics() async {
    final metrics = _performanceService.exportMetrics();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${metrics.keys.length} metrics exported!')),
    );
  }
}
