import 'dart:developer';

import 'package:flutter/material.dart';

/// Sistema avançado de otimização de widget tree e renderização
class WidgetOptimizer {
  static final WidgetOptimizer _instance = WidgetOptimizer._internal();
  factory WidgetOptimizer() => _instance;
  WidgetOptimizer._internal();

  final Map<String, RebuildTracker> _rebuildTrackers = {};
  final Set<String> _optimizedWidgets = {};
  bool _isProfileMode = false;

  /// Ativa modo de profiling para análise detalhada
  void enableProfiling() {
    _isProfileMode = true;
    log('Widget profiling enabled', name: 'WidgetOptimizer');
  }

  /// Desativa modo de profiling
  void disableProfiling() {
    _isProfileMode = false;
    log('Widget profiling disabled', name: 'WidgetOptimizer');
  }

  /// Rastreia rebuilds de um widget
  void trackRebuild(String widgetKey, String widgetType) {
    if (!_isProfileMode) return;

    final tracker =
        _rebuildTrackers[widgetKey] ??= RebuildTracker(widgetKey, widgetType);
    tracker.recordRebuild();

    if (tracker.rebuildCount > 10) {
      log(
        'High rebuild count detected for $widgetKey: ${tracker.rebuildCount}',
        name: 'WidgetOptimizer',
      );
    }
  }

  /// Obtém relatório de rebuilds excessivos
  RebuildReport getRebuildReport({Duration? period}) {
    final now = DateTime.now();
    final cutoff = period != null ? now.subtract(period) : null;

    final problematicWidgets = <RebuildTracker>[];

    for (final tracker in _rebuildTrackers.values) {
      final relevantRebuilds =
          cutoff != null
              ? tracker.rebuildTimes
                  .where((time) => time.isAfter(cutoff))
                  .length
              : tracker.rebuildCount;

      if (relevantRebuilds > 5) {
        // Threshold para rebuilds problemáticos
        problematicWidgets.add(tracker);
      }
    }

    problematicWidgets.sort((a, b) => b.rebuildCount.compareTo(a.rebuildCount));

    return RebuildReport(
      generatedAt: now,
      period: period,
      totalTrackedWidgets: _rebuildTrackers.length,
      problematicWidgets: problematicWidgets,
      optimizedWidgets: _optimizedWidgets.toList(),
    );
  }

  /// Limpa dados de profiling antigos
  void clearProfilingData({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(
      olderThan ?? const Duration(hours: 1),
    );

    _rebuildTrackers.removeWhere((key, tracker) {
      return tracker.firstRebuild.isBefore(cutoff);
    });
  }
}

/// Tracker de rebuilds para widgets individuais
class RebuildTracker {
  final String widgetKey;
  final String widgetType;
  final List<DateTime> rebuildTimes = [];
  late final DateTime firstRebuild;

  RebuildTracker(this.widgetKey, this.widgetType) {
    firstRebuild = DateTime.now();
  }

  void recordRebuild() {
    rebuildTimes.add(DateTime.now());
  }

  int get rebuildCount => rebuildTimes.length;

  Duration get totalLifetime =>
      rebuildTimes.isEmpty
          ? Duration.zero
          : rebuildTimes.last.difference(firstRebuild);

  double get rebuildRate =>
      totalLifetime.inMilliseconds > 0
          ? rebuildCount / (totalLifetime.inMilliseconds / 1000.0)
          : 0.0;
}

/// Relatório de rebuilds
class RebuildReport {
  final DateTime generatedAt;
  final Duration? period;
  final int totalTrackedWidgets;
  final List<RebuildTracker> problematicWidgets;
  final List<String> optimizedWidgets;

  const RebuildReport({
    required this.generatedAt,
    this.period,
    required this.totalTrackedWidgets,
    required this.problematicWidgets,
    required this.optimizedWidgets,
  });

  bool get hasProblematicWidgets => problematicWidgets.isNotEmpty;
}

/// Widget otimizado com RepaintBoundary automático
class OptimizedWidget extends StatelessWidget {
  final Widget child;
  final String? debugLabel;
  final bool forceRepaintBoundary;
  final bool enableProfiling;

  const OptimizedWidget({
    super.key,
    required this.child,
    this.debugLabel,
    this.forceRepaintBoundary = false,
    this.enableProfiling = false,
  });

  @override
  Widget build(BuildContext context) {
    final optimizer = WidgetOptimizer();
    final widgetKey = debugLabel ?? '${child.runtimeType}_${child.hashCode}';

    if (enableProfiling) {
      optimizer.trackRebuild(widgetKey, child.runtimeType.toString());
    }

    Widget optimizedChild = child;
    if (forceRepaintBoundary || _shouldApplyRepaintBoundary()) {
      optimizedChild = RepaintBoundary(child: optimizedChild);
    }

    return optimizedChild;
  }

  bool _shouldApplyRepaintBoundary() {
    return child is ListView ||
        child is GridView ||
        child is CustomScrollView ||
        child is AnimatedWidget ||
        child is CustomPaint;
  }
}

/// Builder otimizado que minimiza rebuilds
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Listenable>? listenables;
  final String? debugLabel;

  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.listenables,
    this.debugLabel,
  });

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> {
  late String _widgetKey;

  @override
  void initState() {
    super.initState();
    _widgetKey =
        widget.debugLabel ?? '${widget.runtimeType}_${widget.hashCode}';
    if (widget.listenables != null) {
      for (final listenable in widget.listenables!) {
        listenable.addListener(_onListenableChanged);
      }
    }
  }

  @override
  void dispose() {
    if (widget.listenables != null) {
      for (final listenable in widget.listenables!) {
        listenable.removeListener(_onListenableChanged);
      }
    }
    super.dispose();
  }

  void _onListenableChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetOptimizer().trackRebuild(_widgetKey, widget.runtimeType.toString());

    return RepaintBoundary(child: widget.builder(context));
  }
}

/// Lista otimizada com reciclagem de widgets
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? debugLabel;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.debugLabel,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  final Map<int, Widget> _cachedWidgets = {};

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListView.builder(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final itemKey = '${item.hashCode}_$index';

          return _cachedWidgets[index] ??= RepaintBoundary(
            key: ValueKey(itemKey),
            child: widget.itemBuilder(context, item, index),
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(OptimizedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _cachedWidgets.clear();
    }
  }
}

/// Grid otimizado com performance aprimorada
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final String? debugLabel;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.padding,
    this.controller,
    this.debugLabel,
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GridView.builder(
        controller: widget.controller,
        padding: widget.padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            key: ValueKey('grid_item_${widget.items[index].hashCode}'),
            child: widget.itemBuilder(context, widget.items[index], index),
          );
        },
      ),
    );
  }
}

/// Animação otimizada para performance
class OptimizedAnimatedBuilder extends StatefulWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const OptimizedAnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  State<OptimizedAnimatedBuilder> createState() =>
      _OptimizedAnimatedBuilderState();
}

class _OptimizedAnimatedBuilderState extends State<OptimizedAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          return widget.builder(context, widget.child);
        },
      ),
    );
  }
}

/// Mixin para otimização automática de widgets
mixin WidgetOptimizationMixin<T extends StatefulWidget> on State<T> {
  late String _widgetKey;

  @override
  void initState() {
    super.initState();
    _widgetKey = '${widget.runtimeType}_${widget.hashCode}';
  }

  @override
  Widget build(BuildContext context) {
    WidgetOptimizer().trackRebuild(_widgetKey, widget.runtimeType.toString());
    return buildOptimized(context);
  }

  Widget buildOptimized(BuildContext context);

  /// Envolve um widget com RepaintBoundary se necessário
  Widget optimizeWidget(Widget child, {bool force = false}) {
    if (force || _shouldOptimize(child)) {
      return RepaintBoundary(child: child);
    }
    return child;
  }

  bool _shouldOptimize(Widget widget) {
    return widget is ListView ||
        widget is GridView ||
        widget is CustomPaint ||
        widget is AnimatedWidget;
  }
}

/// Extension para facilitar otimizações
extension WidgetOptimizationExtensions on Widget {
  /// Aplica RepaintBoundary neste widget
  Widget optimized({String? debugLabel}) {
    return OptimizedWidget(debugLabel: debugLabel, child: this);
  }

  /// Aplica otimizações específicas baseadas no tipo
  Widget autoOptimized() {
    if (this is ListView || this is GridView || this is CustomScrollView) {
      return RepaintBoundary(child: this);
    }

    if (this is AnimatedWidget || this is CustomPaint) {
      return RepaintBoundary(child: this);
    }

    return this;
  }
}

/// Detector de performance em tempo real
class PerformanceDetector extends StatefulWidget {
  final Widget child;
  final void Function(PerformanceIssue issue)? onIssueDetected;

  const PerformanceDetector({
    super.key,
    required this.child,
    this.onIssueDetected,
  });

  @override
  State<PerformanceDetector> createState() => _PerformanceDetectorState();
}

class _PerformanceDetectorState extends State<PerformanceDetector>
    with WidgetsBindingObserver {
  final List<Duration> _frameTimes = [];
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_recordFrameTime);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _recordFrameTime(Duration timestamp) {
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }
      if (frameDuration.inMilliseconds > 16) {
        // >16ms = <60fps
        widget.onIssueDetected?.call(
          PerformanceIssue(
            type: PerformanceIssueType.frameDrop,
            severity: _calculateSeverity(frameDuration),
            description:
                'Frame drop detected: ${frameDuration.inMilliseconds}ms',
            timestamp: now,
          ),
        );
      }
    }

    _lastFrameTime = now;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(_recordFrameTime);
    }
  }

  PerformanceIssueSeverity _calculateSeverity(Duration frameDuration) {
    final ms = frameDuration.inMilliseconds;
    if (ms > 50) return PerformanceIssueSeverity.critical;
    if (ms > 33) return PerformanceIssueSeverity.high;
    if (ms > 20) return PerformanceIssueSeverity.medium;
    return PerformanceIssueSeverity.low;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Issue de performance detectado
class PerformanceIssue {
  final PerformanceIssueType type;
  final PerformanceIssueSeverity severity;
  final String description;
  final DateTime timestamp;

  const PerformanceIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
  });
}

enum PerformanceIssueType {
  frameDrop,
  excessiveRebuild,
  memoryLeak,
  slowRender,
}

enum PerformanceIssueSeverity { low, medium, high, critical }
