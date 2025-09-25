import 'dart:async';

import 'package:flutter/material.dart';

import 'package:core/core.dart';

/// Network Status Widget
/// 
/// Features:
/// - Real-time network connectivity monitoring
/// - Connection type indicators (WiFi, Mobile, None)
/// - Connection quality indicators
/// - Offline mode awareness
/// - Auto-retry mechanisms
/// - Compact and detailed display modes
class NetworkStatusWidget extends StatefulWidget {
  /// Display variant: compact (just icon/indicator) or detailed (with text)
  final NetworkStatusVariant variant;
  
  /// Whether to show connection type (WiFi/Mobile)
  final bool showConnectionType;
  
  /// Whether to show connection quality indicator
  final bool showQualityIndicator;
  
  /// Callback when network status changes
  final void Function(NetworkStatus)? onStatusChanged;
  
  /// Custom styling
  final NetworkStatusStyle? style;

  const NetworkStatusWidget({
    super.key,
    this.variant = NetworkStatusVariant.compact,
    this.showConnectionType = true,
    this.showQualityIndicator = false,
    this.onStatusChanged,
    this.style,
  });

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ConnectivityService _connectivityService;

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  ConnectivityType _connectionType = ConnectivityType.none;
  ConnectionQuality _connectionQuality = ConnectionQuality.unknown;
  StreamSubscription<bool>? _connectivitySubscription;
  int _retryAttempts = 0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _initializeNetworkMonitoring();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Initialize network monitoring with real ConnectivityService
  void _initializeNetworkMonitoring() async {
    _connectivityService = ConnectivityService.instance;
    await _connectivityService.initialize();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) async {
      await _updateNetworkStatus(isOnline);
      setState(() {});
      widget.onStatusChanged?.call(_currentStatus);
    });

    // Get initial status
    _checkInitialNetworkStatus();
  }

  /// Check initial network status
  Future<void> _checkInitialNetworkStatus() async {
    final result = await _connectivityService.isOnline();
    result.fold(
      (failure) {
        setState(() {
          _currentStatus = NetworkStatus.unknown;
          _connectionType = ConnectivityType.none;
          _connectionQuality = ConnectionQuality.none;
          _pulseController.stop();
        });
      },
      (isOnline) async {
        await _updateNetworkStatus(isOnline);
        setState(() {});
      },
    );
  }

  /// Update network status based on connectivity
  Future<void> _updateNetworkStatus(bool isOnline) async {
    if (isOnline) {
      // Get current connection type
      final connectivityResult = await _connectivityService.getConnectivityType();
      final connectivityType = connectivityResult.fold(
        (failure) => ConnectivityType.none,
        (type) => type,
      );
      _connectionType = connectivityType;

      // Set status and quality based on connection type
      switch (connectivityType) {
        case ConnectivityType.wifi:
          _currentStatus = NetworkStatus.connected;
          _connectionQuality = ConnectionQuality.excellent;
          _pulseController.stop();
          _retryAttempts = 0;
          break;
        case ConnectivityType.mobile:
          _currentStatus = NetworkStatus.connected;
          _connectionQuality = ConnectionQuality.good;
          _pulseController.stop();
          _retryAttempts = 0;
          break;
        case ConnectivityType.ethernet:
          _currentStatus = NetworkStatus.connected;
          _connectionQuality = ConnectionQuality.excellent;
          _pulseController.stop();
          _retryAttempts = 0;
          break;
        case ConnectivityType.bluetooth:
        case ConnectivityType.other:
          _currentStatus = NetworkStatus.limited;
          _connectionQuality = ConnectionQuality.poor;
          _pulseController.repeat(reverse: true);
          break;
        case ConnectivityType.none:
          _currentStatus = NetworkStatus.disconnected;
          _connectionQuality = ConnectionQuality.none;
          _pulseController.stop();
          _retryAttempts++;
          break;
        case ConnectivityType.vpn:
          _currentStatus = NetworkStatus.connected;
          _connectionQuality = ConnectionQuality.good;
          _pulseController.stop();
          _retryAttempts = 0;
          break;
        case ConnectivityType.offline:
          _currentStatus = NetworkStatus.disconnected;
          _connectionQuality = ConnectionQuality.none;
          _pulseController.stop();
          _retryAttempts++;
          break;
        case ConnectivityType.online:
          _currentStatus = NetworkStatus.connected;
          _connectionQuality = ConnectionQuality.good;
          _pulseController.stop();
          _retryAttempts = 0;
          break;
      }
    } else {
      _currentStatus = NetworkStatus.disconnected;
      _connectionType = ConnectivityType.none;
      _connectionQuality = ConnectionQuality.none;
      _pulseController.stop();
      _retryAttempts++;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case NetworkStatusVariant.compact:
        return _buildCompactIndicator(context);
      case NetworkStatusVariant.detailed:
        return _buildDetailedIndicator(context);
    }
  }

  /// Build compact network status indicator
  Widget _buildCompactIndicator(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _currentStatus == NetworkStatus.limited ? _pulseAnimation.value : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connection Type Icon
              if (widget.showConnectionType)
                Icon(
                  _getConnectionTypeIcon(),
                  size: 14,
                  color: _getStatusColor(context),
                ),
              
              const SizedBox(width: 4),
              
              // Status Icon
              Icon(
                _getStatusIcon(),
                size: 16,
                color: _getStatusColor(context),
              ),
              
              // Quality Indicator
              if (widget.showQualityIndicator) ...[
                const SizedBox(width: 4),
                _buildQualityIndicator(context),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Build detailed network status indicator
  Widget _buildDetailedIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? NetworkStatusStyle.defaultStyle(theme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon with Animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentStatus == NetworkStatus.limited ? _pulseAnimation.value : 1.0,
                child: Icon(
                  _getStatusIcon(),
                  size: 14,
                  color: _getStatusColor(context),
                ),
              );
            },
          ),
          
          const SizedBox(width: 6),
          
          // Status Text
          Text(
            _getStatusText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(context),
              fontWeight: FontWeight.w500,
              fontSize: style.fontSize,
            ),
          ),
          
          // Connection Type
          if (widget.showConnectionType && _connectionType != ConnectivityType.none) ...[
            const SizedBox(width: 4),
            Text(
              '•',
              style: TextStyle(
                color: _getStatusColor(context).withValues(alpha: 0.5),
                fontSize: 8,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _getConnectionTypeIcon(),
              size: 10,
              color: _getStatusColor(context).withValues(alpha: 0.7),
            ),
          ],
          
          // Quality Indicator
          if (widget.showQualityIndicator && _connectionQuality != ConnectionQuality.none) ...[
            const SizedBox(width: 6),
            _buildQualityIndicator(context),
          ],
          
          // Retry Counter (when disconnected)
          if (_currentStatus == NetworkStatus.disconnected && _retryAttempts > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(context).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$_retryAttempts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(context),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build connection quality indicator (signal bars)
  Widget _buildQualityIndicator(BuildContext context) {
    final color = _getStatusColor(context);
    final barCount = _getQualityBarCount();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < barCount;
        final height = 6.0 + (index * 2);
        
        return Container(
          width: 2,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  /// Get status color based on network status
  Color _getStatusColor(BuildContext context) {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.limited:
        return Colors.orange;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.unknown:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  /// Get status icon based on network status
  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return Icons.cloud_done;
      case NetworkStatus.limited:
        return Icons.cloud_queue;
      case NetworkStatus.disconnected:
        return Icons.cloud_off;
      case NetworkStatus.unknown:
        return Icons.cloud_outlined;
    }
  }

  /// Get connection type icon
  IconData _getConnectionTypeIcon() {
    switch (_connectionType) {
      case ConnectivityType.wifi:
        return Icons.wifi;
      case ConnectivityType.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityType.ethernet:
        return Icons.lan;
      case ConnectivityType.bluetooth:
        return Icons.bluetooth;
      case ConnectivityType.other:
        return Icons.device_hub;
      case ConnectivityType.none:
        return Icons.signal_cellular_off;
      case ConnectivityType.vpn:
        return Icons.vpn_lock;
      case ConnectivityType.offline:
        return Icons.signal_cellular_off;
      case ConnectivityType.online:
        return Icons.wifi;
    }
  }

  /// Get status text
  String _getStatusText() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return 'Online';
      case NetworkStatus.limited:
        return 'Limitado';
      case NetworkStatus.disconnected:
        return 'Offline';
      case NetworkStatus.unknown:
        return 'Verificando...';
    }
  }

  /// Get quality bar count for visual indicator
  int _getQualityBarCount() {
    switch (_connectionQuality) {
      case ConnectionQuality.excellent:
        return 4;
      case ConnectionQuality.good:
        return 3;
      case ConnectionQuality.fair:
        return 2;
      case ConnectionQuality.poor:
        return 1;
      case ConnectionQuality.none:
      case ConnectionQuality.unknown:
        return 0;
    }
  }
}

/// Network Status Enums and Classes
enum NetworkStatus {
  unknown,
  connected,
  limited,
  disconnected,
}


enum ConnectionQuality {
  unknown,
  none,
  poor,
  fair,
  good,
  excellent,
}

enum NetworkStatusVariant {
  compact,
  detailed,
}

/// Network Status Styling Configuration
class NetworkStatusStyle {
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  
  const NetworkStatusStyle({
    this.fontSize = 10,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });
  
  static NetworkStatusStyle defaultStyle(ThemeData theme) {
    return const NetworkStatusStyle();
  }
}