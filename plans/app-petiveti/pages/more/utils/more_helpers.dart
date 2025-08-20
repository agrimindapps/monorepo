// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/menu_item_model.dart';
import '../models/section_model.dart';
import '../models/share_model.dart';
import 'more_constants.dart';

class MoreHelpers {
  MoreHelpers._();

  // Color utilities
  static Color getColorForCategory(MenuItemCategory category) {
    switch (category) {
      case MenuItemCategory.about:
        return MoreConstants.aboutSectionColor;
      case MenuItemCategory.account:
        return MoreConstants.accountSectionColor;
      case MenuItemCategory.support:
        return MoreConstants.supportSectionColor;
    }
  }

  static Color getColorForType(MenuItemType type) {
    switch (type) {
      case MenuItemType.navigation:
        return MoreConstants.primaryColor;
      case MenuItemType.externalUrl:
        return MoreConstants.infoColor;
      case MenuItemType.share:
        return MoreConstants.successColor;
      case MenuItemType.email:
        return MoreConstants.errorColor;
      case MenuItemType.action:
        return MoreConstants.warningColor;
    }
  }

  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color getDarkerColor(Color color, double factor) {
    return Color.lerp(color, Colors.black, factor) ?? color;
  }

  static Color getLighterColor(Color color, double factor) {
    return Color.lerp(color, Colors.white, factor) ?? color;
  }

  // Icon utilities
  static IconData getIconForCategory(MenuItemCategory category) {
    switch (category) {
      case MenuItemCategory.about:
        return Icons.info_outline;
      case MenuItemCategory.account:
        return Icons.account_circle_outlined;
      case MenuItemCategory.support:
        return Icons.support_agent;
    }
  }

  static IconData getIconForType(MenuItemType type) {
    switch (type) {
      case MenuItemType.navigation:
        return MoreConstants.navigationIcon;
      case MenuItemType.externalUrl:
        return MoreConstants.externalIcon;
      case MenuItemType.share:
        return MoreConstants.shareIcon;
      case MenuItemType.email:
        return MoreConstants.emailIcon;
      case MenuItemType.action:
        return MoreConstants.defaultIcon;
    }
  }

  static IconData getTrailingIconForType(MenuItemType type) {
    switch (type) {
      case MenuItemType.navigation:
        return Icons.chevron_right;
      case MenuItemType.externalUrl:
        return Icons.open_in_new;
      case MenuItemType.share:
        return Icons.share;
      case MenuItemType.email:
        return Icons.mail_outline;
      case MenuItemType.action:
        return Icons.touch_app;
    }
  }

  // Text utilities
  static String getDisplayNameForCategory(MenuItemCategory category) {
    return category.displayName;
  }

  static String getDisplayNameForType(MenuItemType type) {
    return type.displayName;
  }

  static String getDescriptionForCategory(MenuItemCategory category) {
    switch (category) {
      case MenuItemCategory.about:
        return 'Informações sobre o aplicativo PetiVeti';
      case MenuItemCategory.account:
        return 'Configurações e recursos da sua conta';
      case MenuItemCategory.support:
        return 'Ajuda e suporte técnico';
    }
  }

  static String getDescriptionForType(MenuItemType type) {
    switch (type) {
      case MenuItemType.navigation:
        return 'Navegar para outra tela do aplicativo';
      case MenuItemType.externalUrl:
        return 'Abrir link externo no navegador';
      case MenuItemType.share:
        return 'Compartilhar conteúdo';
      case MenuItemType.email:
        return 'Enviar email';
      case MenuItemType.action:
        return 'Executar ação personalizada';
    }
  }

  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatTitle(String title) {
    return title.trim().isNotEmpty ? title.trim() : 'Sem título';
  }

  // Validation utilities
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidRoute(String? route) {
    if (route == null || route.isEmpty) return false;
    return route.startsWith('/');
  }

  static bool isValidMenuItem(MenuItem item) {
    if (item.title.isEmpty) return false;
    
    switch (item.type) {
      case MenuItemType.navigation:
        return isValidRoute(item.route);
      case MenuItemType.externalUrl:
        return isValidUrl(item.url);
      case MenuItemType.share:
        return item.shareText != null && item.shareText!.isNotEmpty;
      case MenuItemType.email:
        return isValidEmail(item.email);
      case MenuItemType.action:
        return item.customAction != null;
    }
  }

  static bool isValidSection(MenuSection section) {
    return section.title.isNotEmpty && section.items.isNotEmpty;
  }

  static bool isValidShareContent(ShareContent content) {
    return content.title.isNotEmpty && content.text.isNotEmpty;
  }

  // Search utilities
  static List<MenuItem> searchMenuItems(List<MenuItem> items, String query) {
    if (query.isEmpty) return items;
    
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
             (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  static List<MenuSection> searchSections(List<MenuSection> sections, String query) {
    if (query.isEmpty) return sections;
    
    final lowerQuery = query.toLowerCase();
    return sections.where((section) {
      return section.title.toLowerCase().contains(lowerQuery) ||
             (section.subtitle?.toLowerCase().contains(lowerQuery) ?? false) ||
             section.items.any((item) => 
                 item.title.toLowerCase().contains(lowerQuery) ||
                 (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false));
    }).toList();
  }

  static String highlightSearchText(String text, String query) {
    if (query.isEmpty) return text;
    
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    
    if (index == -1) return text;
    
    return text.substring(0, index) +
           text.substring(index, index + query.length) +
           text.substring(index + query.length);
  }

  // Sorting utilities
  static List<MenuItem> sortItemsByTitle(List<MenuItem> items, {bool ascending = true}) {
    final sorted = List<MenuItem>.from(items);
    sorted.sort((a, b) => ascending 
        ? a.title.compareTo(b.title)
        : b.title.compareTo(a.title));
    return sorted;
  }

  static List<MenuItem> sortItemsByType(List<MenuItem> items) {
    final sorted = List<MenuItem>.from(items);
    sorted.sort((a, b) => a.type.index.compareTo(b.type.index));
    return sorted;
  }

  static List<MenuItem> sortItemsByCategory(List<MenuItem> items) {
    final sorted = List<MenuItem>.from(items);
    sorted.sort((a, b) => a.category.index.compareTo(b.category.index));
    return sorted;
  }

  static List<MenuSection> sortSectionsByTitle(List<MenuSection> sections, {bool ascending = true}) {
    final sorted = List<MenuSection>.from(sections);
    sorted.sort((a, b) => ascending 
        ? a.title.compareTo(b.title)
        : b.title.compareTo(a.title));
    return sorted;
  }

  // Filtering utilities
  static List<MenuItem> filterItemsByCategory(List<MenuItem> items, MenuItemCategory category) {
    return items.where((item) => item.category == category).toList();
  }

  static List<MenuItem> filterItemsByType(List<MenuItem> items, MenuItemType type) {
    return items.where((item) => item.type == type).toList();
  }

  static List<MenuItem> filterEnabledItems(List<MenuItem> items) {
    return items.where((item) => item.isEnabled).toList();
  }

  static List<MenuItem> filterItemsWithBadges(List<MenuItem> items) {
    return items.where((item) => item.showBadge).toList();
  }

  static List<MenuSection> filterVisibleSections(List<MenuSection> sections) {
    return sections.where((section) => section.isVisible).toList();
  }

  static List<MenuSection> filterSectionsWithItems(List<MenuSection> sections) {
    return sections.where((section) => section.hasVisibleItems).toList();
  }

  // Analytics utilities
  static Map<String, dynamic> createAnalyticsProperties({
    String? itemId,
    String? sectionId,
    MenuItemType? type,
    MenuItemCategory? category,
    String? action,
    Map<String, dynamic>? additional,
  }) {
    final properties = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'page': 'more_page',
    };

    if (itemId != null) properties['item_id'] = itemId;
    if (sectionId != null) properties['section_id'] = sectionId;
    if (type != null) properties['item_type'] = type.id;
    if (category != null) properties['item_category'] = category.id;
    if (action != null) properties['action'] = action;
    if (additional != null) properties.addAll(additional);

    return properties;
  }

  static String getAnalyticsEventName(String action, {String? prefix}) {
    final fullPrefix = prefix ?? MoreConstants.debugTag.toLowerCase();
    return '${fullPrefix}_$action';
  }

  // Error handling utilities
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return MoreConstants.defaultErrorMessage;
  }

  static String getDisplayErrorMessage(String errorType) {
    switch (errorType) {
      case 'network':
        return MoreConstants.errorNetworkUnavailable;
      case 'url':
        return MoreConstants.errorUrlInvalid;
      case 'email':
        return MoreConstants.errorEmailInvalid;
      case 'share':
        return MoreConstants.errorShareFailed;
      default:
        return MoreConstants.errorUnknown;
    }
  }

  // Date and time utilities
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora';
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Platform utilities
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }

  static bool isMobile(BuildContext context) {
    return isIOS(context) || isAndroid(context);
  }

  static bool isDesktop(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.windows ||
           platform == TargetPlatform.macOS ||
           platform == TargetPlatform.linux;
  }

  static String getPlatformStoreUrl(BuildContext context) {
    if (isIOS(context)) {
      return MoreConstants.appStoreUrl;
    } else {
      return MoreConstants.playStoreUrl;
    }
  }

  // Theme utilities
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getAdaptiveColor(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Widget utilities
  static Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildErrorWidget(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Debugging utilities
  static void debugLog(String message, {String? tag}) {
    if (MoreConstants.enableDebugMode) {
      final logTag = tag ?? MoreConstants.debugTag;
      debugPrint('[$logTag] $message');
    }
  }

  static void debugLogError(String error, {String? tag, dynamic stackTrace}) {
    if (MoreConstants.enableDebugMode) {
      final logTag = tag ?? MoreConstants.debugTag;
      debugPrint('[$logTag] ERROR: $error');
      if (stackTrace != null) {
        debugPrint('[$logTag] STACK: $stackTrace');
      }
    }
  }

  static Map<String, dynamic> getDebugInfo() {
    return {
      'constants': {
        'enableDebugMode': MoreConstants.enableDebugMode,
        'enableAnalytics': MoreConstants.enableAnalytics,
        'enableLogging': MoreConstants.enableLogging,
      },
      'features': {
        'enableSectionCollapse': MoreConstants.enableSectionCollapse,
        'enableSearch': MoreConstants.enableSearch,
        'enableShareHistory': MoreConstants.enableShareHistory,
      },
      'limits': {
        'maxSectionItems': MoreConstants.maxSectionItems,
        'maxSearchResults': MoreConstants.maxSearchResults,
        'maxShareHistoryItems': MoreConstants.maxShareHistoryItems,
      },
    };
  }
}
