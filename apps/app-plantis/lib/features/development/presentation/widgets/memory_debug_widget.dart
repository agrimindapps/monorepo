import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/memory_monitoring_service.dart';

/// Debug widget to display memory usage info
/// Only shown in debug mode
class MemoryDebugWidget extends StatefulWidget {
  final Widget child;
  final bool showMemoryOverlay;
  
  const MemoryDebugWidget({
    super.key,
    required this.child,
    this.showMemoryOverlay = false,
  });

  @override
  State<MemoryDebugWidget> createState() => _MemoryDebugWidgetState();
}

class _MemoryDebugWidgetState extends State<MemoryDebugWidget> {
  final MemoryMonitoringService _memoryService = MemoryMonitoringService.instance;
  MemoryReport? _currentReport;
  
  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      _memoryService.startMonitoring();
      
      // Update report every 30 seconds
      Future.delayed(const Duration(seconds: 2), _updateReport);
      _startPeriodicUpdate();
    }
  }
  
  void _startPeriodicUpdate() {
    if (!kDebugMode) return;
    
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _updateReport();
        _startPeriodicUpdate();
      }
    });
  }
  
  void _updateReport() {
    if (!mounted) return;
    
    setState(() {
      _currentReport = _memoryService.getMemoryReport();
    });
  }
  
  @override
  void dispose() {
    if (kDebugMode) {
      _memoryService.stopMonitoring();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !widget.showMemoryOverlay) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        _buildMemoryOverlay(),
      ],
    );
  }
  
  Widget _buildMemoryOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: GestureDetector(
        onTap: _showMemoryDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMemoryStatusColor().withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.memory,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _getMemoryText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getMemoryStatusColor() {
    final currentMemory = _currentReport?.currentSnapshot?.usedMemoryMB;
    if (currentMemory == null) return Colors.blue;
    
    if (currentMemory > 200) return Colors.red;
    if (currentMemory > 100) return Colors.orange;
    return Colors.green;
  }
  
  String _getMemoryText() {
    final currentMemory = _currentReport?.currentSnapshot?.usedMemoryMB;
    if (currentMemory == null) return 'Mem: --';
    
    return 'Mem: ${currentMemory}MB';
  }
  
  void _showMemoryDialog() {
    showDialog(
      context: context,
      builder: (context) => _MemoryReportDialog(report: _currentReport),
    );
  }
}

class _MemoryReportDialog extends StatelessWidget {
  final MemoryReport? report;
  
  const _MemoryReportDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.memory, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Memory Report'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: report == null 
            ? const Text('No memory data available')
            : _buildReportContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            MemoryMonitoringService.instance.clearAllCaches();
            Navigator.of(context).pop();
          },
          child: const Text('Clear Caches'),
        ),
      ],
    );
  }
  
  Widget _buildReportContent() {
    final report = this.report!;
    final snapshot = report.currentSnapshot;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Current Usage', [
          if (snapshot?.usedMemoryMB != null)
            _buildInfoRow('Used Memory', '${snapshot!.usedMemoryMB}MB'),
          if (snapshot?.heapMemoryMB != null)
            _buildInfoRow('Heap Capacity', '${snapshot!.heapMemoryMB}MB'),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSection('Averages', [
          if (report.averageMemoryMB != null)
            _buildInfoRow('Average Memory', '${report.averageMemoryMB!.toStringAsFixed(1)}MB'),
          if (report.peakMemoryMB != null)
            _buildInfoRow('Peak Memory', '${report.peakMemoryMB}MB'),
          _buildInfoRow('Trend', _getTrendText(report.memoryTrend)),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSection('Caches', [
          _buildInfoRow(
            'Image Cache', 
            '${snapshot?.imageCacheStats['cachedImages']} images (${snapshot?.imageCacheStats['totalSizeMB']}MB)'
          ),
          _buildInfoRow(
            'Search Cache', 
            '${snapshot?.searchCacheStats['cacheSize']} queries'
          ),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSection('Recommendations', 
          report.recommendations.map((rec) => Text(
            '• $rec',
            style: const TextStyle(fontSize: 14),
          )).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  String _getTrendText(MemoryTrend trend) {
    switch (trend) {
      case MemoryTrend.increasing:
        return '📈 Increasing';
      case MemoryTrend.decreasing:
        return '📉 Decreasing';
      case MemoryTrend.stable:
        return '📊 Stable';
    }
  }
}