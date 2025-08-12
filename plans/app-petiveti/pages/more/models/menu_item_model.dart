// Flutter imports:
import 'package:flutter/material.dart';

enum MenuItemType {
  navigation('navigation', 'Navegação'),
  externalUrl('external_url', 'URL Externa'),
  share('share', 'Compartilhar'),
  email('email', 'Email'),
  action('action', 'Ação');

  const MenuItemType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum MenuItemCategory {
  about('about', 'Sobre o PetiVeti'),
  account('account', 'Conta'),
  support('support', 'Suporte');

  const MenuItemCategory(this.id, this.displayName);
  final String id;
  final String displayName;
}

class MenuItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final MenuItemType type;
  final MenuItemCategory category;
  final String? route;
  final String? url;
  final String? email;
  final String? emailSubject;
  final String? shareText;
  final VoidCallback? customAction;
  final bool isEnabled;
  final bool showBadge;
  final String? badgeText;

  const MenuItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
    required this.category,
    this.route,
    this.url,
    this.email,
    this.emailSubject,
    this.shareText,
    this.customAction,
    this.isEnabled = true,
    this.showBadge = false,
    this.badgeText,
  });

  MenuItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? color,
    MenuItemType? type,
    MenuItemCategory? category,
    String? route,
    String? url,
    String? email,
    String? emailSubject,
    String? shareText,
    VoidCallback? customAction,
    bool? isEnabled,
    bool? showBadge,
    String? badgeText,
  }) {
    return MenuItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      category: category ?? this.category,
      route: route ?? this.route,
      url: url ?? this.url,
      email: email ?? this.email,
      emailSubject: emailSubject ?? this.emailSubject,
      shareText: shareText ?? this.shareText,
      customAction: customAction ?? this.customAction,
      isEnabled: isEnabled ?? this.isEnabled,
      showBadge: showBadge ?? this.showBadge,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.id,
      'category': category.id,
      'route': route,
      'url': url,
      'email': email,
      'emailSubject': emailSubject,
      'shareText': shareText,
      'isEnabled': isEnabled,
      'showBadge': showBadge,
      'badgeText': badgeText,
    };
  }

  static MenuItem fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      icon: Icons.help_outline, // Default icon
      color: Colors.grey, // Default color
      type: _getMenuItemTypeById(json['type'] ?? 'action'),
      category: _getMenuItemCategoryById(json['category'] ?? 'about'),
      route: json['route'],
      url: json['url'],
      email: json['email'],
      emailSubject: json['emailSubject'],
      shareText: json['shareText'],
      isEnabled: json['isEnabled'] ?? true,
      showBadge: json['showBadge'] ?? false,
      badgeText: json['badgeText'],
    );
  }

  static MenuItemType _getMenuItemTypeById(String id) {
    return MenuItemType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => MenuItemType.action,
    );
  }

  static MenuItemCategory _getMenuItemCategoryById(String id) {
    return MenuItemCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => MenuItemCategory.about,
    );
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, title: $title, type: ${type.id}, category: ${category.id})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, type, category);
  }
}

class MenuItemRepository {
  static List<MenuItem> getDefaultMenuItems() {
    return [
      // Sobre o PetiVeti
      const MenuItem(
        id: 'promo_page',
        title: 'Página Promocional',
        icon: Icons.pages_rounded,
        color: Color(0xFF6A1B9A), // Purple 800
        type: MenuItemType.navigation,
        category: MenuItemCategory.about,
        route: '/promo',
      ),
      const MenuItem(
        id: 'share_app',
        title: 'Compartilhar App',
        icon: Icons.share,
        color: Color(0xFF388E3C), // Green 700
        type: MenuItemType.share,
        category: MenuItemCategory.about,
        shareText: 'Experimente o PetiVeti, o aplicativo completo para cuidar da saúde e bem-estar do seu pet! https://play.google.com/store/apps/details?id=com.petiveti',
      ),
      const MenuItem(
        id: 'rate_app',
        title: 'Avaliar App',
        icon: Icons.star,
        color: Color(0xFFFFA000), // Amber 700
        type: MenuItemType.externalUrl,
        category: MenuItemCategory.about,
        url: 'https://play.google.com/store/apps/details?id=com.petiveti',
      ),
      const MenuItem(
        id: 'about',
        title: 'Sobre',
        icon: Icons.info_outline,
        color: Color(0xFF1976D2), // Blue 700
        type: MenuItemType.navigation,
        category: MenuItemCategory.about,
        route: '/sobre',
      ),

      // Conta
      const MenuItem(
        id: 'premium',
        title: 'Versão Premium',
        subtitle: 'Recursos exclusivos',
        icon: Icons.workspace_premium,
        color: Color(0xFFFF8F00), // Amber 800
        type: MenuItemType.navigation,
        category: MenuItemCategory.account,
        route: '/subscription',
        showBadge: true,
        badgeText: 'Premium',
      ),
      const MenuItem(
        id: 'updates',
        title: 'Atualizações',
        subtitle: 'Novidades do app',
        icon: Icons.update,
        color: Color(0xFF303F9F), // Indigo 700
        type: MenuItemType.navigation,
        category: MenuItemCategory.account,
        route: '/atualizacoes',
      ),

      // Suporte
      const MenuItem(
        id: 'help',
        title: 'Ajuda',
        subtitle: 'Central de ajuda',
        icon: Icons.help_outline,
        color: Color(0xFF00796B), // Teal 700
        type: MenuItemType.externalUrl,
        category: MenuItemCategory.support,
        url: 'https://petiveti.com/ajuda',
      ),
      const MenuItem(
        id: 'contact',
        title: 'Contato',
        subtitle: 'Fale conosco',
        icon: Icons.mail_outline,
        color: Color(0xFFD32F2F), // Red 700
        type: MenuItemType.email,
        category: MenuItemCategory.support,
        email: 'suporte@petiveti.com',
        emailSubject: 'Suporte PetiVeti App',
      ),
    ];
  }

  static List<MenuItem> getItemsByCategory(MenuItemCategory category) {
    return getDefaultMenuItems()
        .where((item) => item.category == category)
        .toList();
  }

  static MenuItem? getItemById(String id) {
    try {
      return getDefaultMenuItems().firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MenuItemCategory> getCategories() {
    return MenuItemCategory.values;
  }

  static List<MenuItemType> getItemTypes() {
    return MenuItemType.values;
  }

  static String getCategoryDisplayName(MenuItemCategory category) {
    return category.displayName;
  }

  static String getTypeDisplayName(MenuItemType type) {
    return type.displayName;
  }

  static List<MenuItem> getEnabledItems() {
    return getDefaultMenuItems().where((item) => item.isEnabled).toList();
  }

  static List<MenuItem> getItemsWithBadges() {
    return getDefaultMenuItems().where((item) => item.showBadge).toList();
  }

  static Map<MenuItemCategory, List<MenuItem>> groupByCategory() {
    final grouped = <MenuItemCategory, List<MenuItem>>{};
    
    for (final item in getDefaultMenuItems()) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    
    return grouped;
  }

  static Map<MenuItemType, List<MenuItem>> groupByType() {
    final grouped = <MenuItemType, List<MenuItem>>{};
    
    for (final item in getDefaultMenuItems()) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }
    
    return grouped;
  }

  static List<MenuItem> filterByType(MenuItemType type) {
    return getDefaultMenuItems()
        .where((item) => item.type == type)
        .toList();
  }

  static bool hasExternalActions() {
    return getDefaultMenuItems().any((item) => 
        item.type == MenuItemType.externalUrl ||
        item.type == MenuItemType.email ||
        item.type == MenuItemType.share);
  }

  static int getItemCount() {
    return getDefaultMenuItems().length;
  }

  static int getCategoryItemCount(MenuItemCategory category) {
    return getItemsByCategory(category).length;
  }

  static Map<String, dynamic> getMenuStatistics() {
    final items = getDefaultMenuItems();
    final categories = <String, int>{};
    final types = <String, int>{};
    
    for (final item in items) {
      categories[item.category.id] = (categories[item.category.id] ?? 0) + 1;
      types[item.type.id] = (types[item.type.id] ?? 0) + 1;
    }
    
    return {
      'totalItems': items.length,
      'enabledItems': items.where((item) => item.isEnabled).length,
      'itemsWithBadges': items.where((item) => item.showBadge).length,
      'categoryCounts': categories,
      'typeCounts': types,
      'hasExternalActions': hasExternalActions(),
    };
  }
}
