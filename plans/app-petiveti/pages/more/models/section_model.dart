// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'menu_item_model.dart';

class MenuSection {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final List<MenuItem> items;
  final bool isVisible;
  final bool isExpanded;
  final int? maxItems;

  const MenuSection({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    required this.items,
    this.isVisible = true,
    this.isExpanded = true,
    this.maxItems,
  });

  MenuSection copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? color,
    List<MenuItem>? items,
    bool? isVisible,
    bool? isExpanded,
    int? maxItems,
  }) {
    return MenuSection(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      items: items ?? this.items,
      isVisible: isVisible ?? this.isVisible,
      isExpanded: isExpanded ?? this.isExpanded,
      maxItems: maxItems ?? this.maxItems,
    );
  }

  List<MenuItem> get visibleItems {
    final enabledItems = items.where((item) => item.isEnabled).toList();
    if (maxItems != null && enabledItems.length > maxItems!) {
      return enabledItems.take(maxItems!).toList();
    }
    return enabledItems;
  }

  bool get hasItems => items.isNotEmpty;
  bool get hasVisibleItems => visibleItems.isNotEmpty;
  int get itemCount => items.length;
  int get visibleItemCount => visibleItems.length;
  bool get hasMoreItems => maxItems != null && items.length > maxItems!;
  int get hiddenItemCount => hasMoreItems ? items.length - maxItems! : 0;

  MenuItem? getItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MenuItem> getItemsByType(MenuItemType type) {
    return items.where((item) => item.type == type).toList();
  }

  bool hasItemType(MenuItemType type) {
    return items.any((item) => item.type == type);
  }

  bool hasExternalActions() {
    return items.any((item) => 
        item.type == MenuItemType.externalUrl ||
        item.type == MenuItemType.email ||
        item.type == MenuItemType.share);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'items': items.map((item) => item.toJson()).toList(),
      'isVisible': isVisible,
      'isExpanded': isExpanded,
      'maxItems': maxItems,
    };
  }

  static MenuSection fromJson(Map<String, dynamic> json) {
    return MenuSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isVisible: json['isVisible'] ?? true,
      isExpanded: json['isExpanded'] ?? true,
      maxItems: json['maxItems'],
    );
  }

  @override
  String toString() {
    return 'MenuSection(id: $id, title: $title, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuSection &&
        other.id == id &&
        other.title == title &&
        other.items.length == items.length;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, items.length);
  }
}

class MenuSectionRepository {
  static List<MenuSection> getDefaultSections() {
    final menuItems = MenuItemRepository.getDefaultMenuItems();
    final groupedByCategory = MenuItemRepository.groupByCategory();
    
    return [
      MenuSection(
        id: 'about_section',
        title: 'Sobre o PetiVeti',
        icon: Icons.info_outline,
        color: Colors.blue,
        items: groupedByCategory[MenuItemCategory.about] ?? [],
      ),
      MenuSection(
        id: 'account_section',
        title: 'Conta',
        icon: Icons.account_circle_outlined,
        color: Colors.green,
        items: groupedByCategory[MenuItemCategory.account] ?? [],
      ),
      MenuSection(
        id: 'support_section',
        title: 'Suporte',
        icon: Icons.support_agent,
        color: Colors.orange,
        items: groupedByCategory[MenuItemCategory.support] ?? [],
      ),
    ];
  }

  static MenuSection? getSectionById(String id) {
    try {
      return getDefaultSections().firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  static MenuSection? getSectionByCategory(MenuItemCategory category) {
    return getDefaultSections().firstWhere(
      (section) => section.items.any((item) => item.category == category),
      orElse: () => MenuSection(
        id: 'empty_${category.id}',
        title: category.displayName,
        items: const [],
      ),
    );
  }

  static List<MenuSection> getVisibleSections() {
    return getDefaultSections().where((section) => section.isVisible).toList();
  }

  static List<MenuSection> getSectionsWithItems() {
    return getDefaultSections().where((section) => section.hasVisibleItems).toList();
  }

  static int getTotalItemCount() {
    return getDefaultSections()
        .map((section) => section.itemCount)
        .fold(0, (sum, count) => sum + count);
  }

  static int getTotalVisibleItemCount() {
    return getDefaultSections()
        .map((section) => section.visibleItemCount)
        .fold(0, (sum, count) => sum + count);
  }

  static bool hasExternalActions() {
    return getDefaultSections().any((section) => section.hasExternalActions());
  }

  static Map<String, int> getSectionItemCounts() {
    final counts = <String, int>{};
    for (final section in getDefaultSections()) {
      counts[section.id] = section.itemCount;
    }
    return counts;
  }

  static Map<String, List<MenuItemType>> getSectionTypes() {
    final types = <String, List<MenuItemType>>{};
    for (final section in getDefaultSections()) {
      final sectionTypes = <MenuItemType>{};
      for (final item in section.items) {
        sectionTypes.add(item.type);
      }
      types[section.id] = sectionTypes.toList();
    }
    return types;
  }

  static MenuSection createCustomSection({
    required String id,
    required String title,
    required List<MenuItem> items,
    String? subtitle,
    IconData? icon,
    Color? color,
    bool isVisible = true,
    bool isExpanded = true,
    int? maxItems,
  }) {
    return MenuSection(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      items: items,
      isVisible: isVisible,
      isExpanded: isExpanded,
      maxItems: maxItems,
    );
  }

  static Map<String, dynamic> getSectionStatistics() {
    final sections = getDefaultSections();
    
    return {
      'totalSections': sections.length,
      'visibleSections': sections.where((s) => s.isVisible).length,
      'sectionsWithItems': sections.where((s) => s.hasVisibleItems).length,
      'totalItems': getTotalItemCount(),
      'totalVisibleItems': getTotalVisibleItemCount(),
      'hasExternalActions': hasExternalActions(),
      'sectionItemCounts': getSectionItemCounts(),
      'sectionTypes': getSectionTypes(),
    };
  }

  static List<MenuItem> getAllItems() {
    return getDefaultSections()
        .expand((section) => section.items)
        .toList();
  }

  static List<MenuItem> getAllVisibleItems() {
    return getDefaultSections()
        .expand((section) => section.visibleItems)
        .toList();
  }

  static MenuItem? findItemById(String itemId) {
    for (final section in getDefaultSections()) {
      final item = section.getItemById(itemId);
      if (item != null) return item;
    }
    return null;
  }

  static MenuSection? findSectionContainingItem(String itemId) {
    for (final section in getDefaultSections()) {
      if (section.getItemById(itemId) != null) {
        return section;
      }
    }
    return null;
  }
}
