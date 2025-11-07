import 'package:flutter/material.dart';
import '../interfaces/i_connectivity_service.dart';

/// Widget that displays current connectivity status
/// Shows offline badge when device is not connected
class ConnectivityIndicator extends StatelessWidget {

  const ConnectivityIndicator({
    super.key,
    required this.connectivityService,
    this.child,
    this.showWhenOnline = false,
    this.margin,
    this.style = const ConnectivityIndicatorStyle(),
  });
  final IConnectivityService connectivityService;
  final Widget? child;
  final bool showWhenOnline;
  final EdgeInsetsGeometry? margin;
  final ConnectivityIndicatorStyle style;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;
        if (status == ConnectivityStatus.connected && !showWhenOnline) {
          return child ?? const SizedBox.shrink();
        }

        return Container(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildStatusIndicator(context, status),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, ConnectivityStatus status) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case ConnectivityStatus.connected:
        backgroundColor = style.onlineColor ?? Colors.green.shade600;
        textColor = style.onlineTextColor ?? Colors.white;
        icon = style.onlineIcon ?? Icons.wifi;
        text = style.onlineText ?? 'Online';
        break;
      case ConnectivityStatus.disconnected:
        backgroundColor = style.offlineColor ?? Colors.red.shade600;
        textColor = style.offlineTextColor ?? Colors.white;
        icon = style.offlineIcon ?? Icons.wifi_off;
        text = style.offlineText ?? 'Offline';
        break;
      case ConnectivityStatus.limited:
        backgroundColor = style.limitedColor ?? Colors.orange.shade600;
        textColor = style.limitedTextColor ?? Colors.white;
        icon = style.limitedIcon ?? Icons.signal_wifi_statusbar_connected_no_internet_4;
        text = style.limitedText ?? 'Limited';
        break;
      default:
        backgroundColor = style.unknownColor ?? Colors.grey.shade600;
        textColor = style.unknownTextColor ?? Colors.white;
        icon = style.unknownIcon ?? Icons.help_outline;
        text = style.unknownText ?? 'Unknown';
    }

    return Container(
      padding: style.padding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: style.borderRadius ?? BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: style.iconSize ?? 16.0,
            color: textColor,
          ),
          if (style.showText) ...[
            const SizedBox(width: 4.0),
            Text(
              text,
              style: style.textStyle?.copyWith(color: textColor) ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(width: 8.0),
            child!,
          ],
        ],
      ),
    );
  }
}

/// Connectivity indicator for AppBar
class AppBarConnectivityIndicator extends StatelessWidget implements PreferredSizeWidget {

  const AppBarConnectivityIndicator({
    super.key,
    required this.connectivityService,
    required this.appBar,
  });
  final IConnectivityService connectivityService;
  final PreferredSizeWidget appBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        appBar,
        ConnectivityBanner(connectivityService: connectivityService),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    appBar.preferredSize.height + 
    (connectivityService.isConnected as bool? ?? true ? 0.0 : 28.0)
  );
}

/// Banner that shows connectivity status
class ConnectivityBanner extends StatelessWidget {

  const ConnectivityBanner({
    super.key,
    required this.connectivityService,
  });
  final IConnectivityService connectivityService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;
        
        if (status == ConnectivityStatus.connected) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        String message;

        switch (status) {
          case ConnectivityStatus.disconnected:
            backgroundColor = Colors.red.shade700;
            message = 'You are offline. Some features may not be available.';
            break;
          case ConnectivityStatus.limited:
            backgroundColor = Colors.orange.shade700;
            message = 'Limited connectivity. Sync may be affected.';
            break;
          default:
            backgroundColor = Colors.grey.shade700;
            message = 'Connection status unknown.';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          color: backgroundColor,
          child: Row(
            children: [
              Icon(
                status == ConnectivityStatus.disconnected 
                    ? Icons.wifi_off 
                    : Icons.signal_wifi_statusbar_connected_no_internet_4,
                size: 16.0,
                color: Colors.white,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Floating connectivity indicator
class FloatingConnectivityIndicator extends StatelessWidget {

  const FloatingConnectivityIndicator({
    super.key,
    required this.connectivityService,
    this.alignment = Alignment.bottomLeft,
    this.margin = const EdgeInsets.all(16.0),
  });
  final IConnectivityService connectivityService;
  final Alignment alignment;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;
        
        if (status == ConnectivityStatus.connected) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Container(
              margin: margin,
              child: ConnectivityIndicator(
                connectivityService: connectivityService,
                style: const ConnectivityIndicatorStyle(
                  showText: true,
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Style configuration for connectivity indicator
class ConnectivityIndicatorStyle {

  const ConnectivityIndicatorStyle({
    this.onlineColor,
    this.offlineColor,
    this.limitedColor,
    this.unknownColor,
    this.onlineTextColor,
    this.offlineTextColor,
    this.limitedTextColor,
    this.unknownTextColor,
    this.onlineIcon,
    this.offlineIcon,
    this.limitedIcon,
    this.unknownIcon,
    this.onlineText,
    this.offlineText,
    this.limitedText,
    this.unknownText,
    this.showText = false,
    this.iconSize,
    this.textStyle,
    this.padding,
    this.borderRadius,
  });
  final Color? onlineColor;
  final Color? offlineColor;
  final Color? limitedColor;
  final Color? unknownColor;
  
  final Color? onlineTextColor;
  final Color? offlineTextColor;
  final Color? limitedTextColor;
  final Color? unknownTextColor;
  
  final IconData? onlineIcon;
  final IconData? offlineIcon;
  final IconData? limitedIcon;
  final IconData? unknownIcon;
  
  final String? onlineText;
  final String? offlineText;
  final String? limitedText;
  final String? unknownText;
  
  final bool showText;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
}
