// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../models/menu_item_model.dart';
import '../models/navigation_model.dart';
import '../models/section_model.dart';
import '../services/analytics_service.dart';
import '../services/navigation_service.dart';

class MoreController extends ChangeNotifier {
  // Services
  late final NavigationService _navigationService;
  late final AnalyticsService _analyticsService;

  // State
  List<MenuSection> _sections = [];
  final Map<String, bool> _sectionExpansion = {};
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastInteraction;

  // Getters
  List<MenuSection> get sections => _sections;
  List<MenuSection> get visibleSections => _sections.where((s) => s.isVisible).toList();
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get hasSections => _sections.isNotEmpty;
  int get sectionCount => _sections.length;
  int get visibleSectionCount => visibleSections.length;
  DateTime? get lastInteraction => _lastInteraction;

  // Section expansion state
  bool isSectionExpanded(String sectionId) {
    return _sectionExpansion[sectionId] ?? true;
  }

  MoreController() {
    _initializeServices();
  }

  void _initializeServices() {
    _navigationService = NavigationService();
    _analyticsService = AnalyticsService();
  }

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadSections();
      await _loadPreferences();
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar página: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSections() async {
    try {
      _sections = MenuSectionRepository.getDefaultSections();
      
      // Initialize expansion state for all sections
      for (final section in _sections) {
        _sectionExpansion[section.id] = section.isExpanded;
      }
    } catch (e) {
      debugPrint('Error loading sections: $e');
      _sections = [];
    }
  }

  Future<void> _loadPreferences() async {
    try {
      // In a real implementation, load user preferences for section expansion
      // For now, use default values
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Section management
  MenuSection? getSectionById(String id) {
    try {
      return _sections.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MenuItem> getSectionItems(String sectionId) {
    final section = getSectionById(sectionId);
    return section?.visibleItems ?? [];
  }

  void toggleSectionExpansion(String sectionId) {
    if (_sectionExpansion.containsKey(sectionId)) {
      _sectionExpansion[sectionId] = !_sectionExpansion[sectionId]!;
      notifyListeners();
      _trackInteraction('section_toggle', {'sectionId': sectionId, 'expanded': _sectionExpansion[sectionId]});
    }
  }

  void setSectionExpansion(String sectionId, bool expanded) {
    if (_sectionExpansion[sectionId] != expanded) {
      _sectionExpansion[sectionId] = expanded;
      notifyListeners();
    }
  }

  void expandAllSections() {
    bool changed = false;
    for (final sectionId in _sectionExpansion.keys) {
      if (!_sectionExpansion[sectionId]!) {
        _sectionExpansion[sectionId] = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _trackInteraction('expand_all_sections');
    }
  }

  void collapseAllSections() {
    bool changed = false;
    for (final sectionId in _sectionExpansion.keys) {
      if (_sectionExpansion[sectionId]!) {
        _sectionExpansion[sectionId] = false;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _trackInteraction('collapse_all_sections');
    }
  }

  // Item interaction
  Future<void> handleItemTap(MenuItem item) async {
    _updateLastInteraction();
    _trackInteraction('item_tap', {'itemId': item.id, 'type': item.type.id});

    try {
      switch (item.type) {
        case MenuItemType.navigation:
          await _handleNavigation(item);
          break;
        case MenuItemType.externalUrl:
          await _handleExternalUrl(item);
          break;
        case MenuItemType.share:
          await _handleShare(item);
          break;
        case MenuItemType.email:
          await _handleEmail(item);
          break;
        case MenuItemType.action:
          await _handleCustomAction(item);
          break;
      }
    } catch (e) {
      _setError('Erro ao processar ação: $e');
      _trackInteraction('item_error', {'itemId': item.id, 'error': e.toString()});
    }
  }

  Future<void> _handleNavigation(MenuItem item) async {
    if (item.route != null) {
      final navigationAction = NavigationAction(
        id: item.id,
        title: item.title,
        route: item.route!,
        type: NavigationType.push,
      );
      
      await _navigationService.navigateToPage(navigationAction);
    }
  }

  Future<void> _handleExternalUrl(MenuItem item) async {
    if (item.url != null) {
      await _navigationService.openExternalUrl(item.url!);
    }
  }

  Future<void> _handleShare(MenuItem item) async {
    if (item.shareText != null) {
      await _navigationService.shareText(item.shareText!);
    }
  }

  Future<void> _handleEmail(MenuItem item) async {
    if (item.email != null) {
      await _navigationService.sendEmail(
        email: item.email!,
        subject: item.emailSubject,
      );
    }
  }

  Future<void> _handleCustomAction(MenuItem item) async {
    if (item.customAction != null) {
      item.customAction!();
    }
  }

  // Analytics and tracking
  void _trackInteraction(String action, [Map<String, dynamic>? properties]) {
    _analyticsService.trackEvent('more_page_$action', properties ?? {});
  }

  void _updateLastInteraction() {
    _lastInteraction = DateTime.now();
  }

  // Search and filtering
  List<MenuItem> searchItems(String query) {
    if (query.isEmpty) return [];
    
    final allItems = _sections.expand((section) => section.visibleItems).toList();
    final lowerQuery = query.toLowerCase();
    
    return allItems.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
             (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<MenuSection> searchSections(String query) {
    if (query.isEmpty) return visibleSections;
    
    final lowerQuery = query.toLowerCase();
    
    return _sections.where((section) {
      // Check section title
      if (section.title.toLowerCase().contains(lowerQuery)) return true;
      
      // Check if any items in section match
      return section.visibleItems.any((item) {
        return item.title.toLowerCase().contains(lowerQuery) ||
               (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
      });
    }).toList();
  }

  List<MenuItem> getItemsByCategory(MenuItemCategory category) {
    return _sections
        .expand((section) => section.visibleItems)
        .where((item) => item.category == category)
        .toList();
  }

  List<MenuItem> getItemsByType(MenuItemType type) {
    return _sections
        .expand((section) => section.visibleItems)
        .where((item) => item.type == type)
        .toList();
  }

  // Statistics and information
  Map<String, dynamic> getPageStatistics() {
    final allItems = _sections.expand((section) => section.visibleItems).toList();
    
    return {
      'totalSections': _sections.length,
      'visibleSections': visibleSections.length,
      'totalItems': allItems.length,
      'itemsByCategory': _getItemCountsByCategory(),
      'itemsByType': _getItemCountsByType(),
      'sectionsExpanded': _sectionExpansion.values.where((expanded) => expanded).length,
      'lastInteraction': _lastInteraction?.toIso8601String(),
    };
  }

  Map<String, int> _getItemCountsByCategory() {
    final counts = <String, int>{};
    for (final category in MenuItemCategory.values) {
      counts[category.id] = getItemsByCategory(category).length;
    }
    return counts;
  }

  Map<String, int> _getItemCountsByType() {
    final counts = <String, int>{};
    for (final type in MenuItemType.values) {
      counts[type.id] = getItemsByType(type).length;
    }
    return counts;
  }

  // Validation and checks
  bool isValidSection(MenuSection section) {
    return section.hasVisibleItems;
  }

  bool canHandleItem(MenuItem item) {
    switch (item.type) {
      case MenuItemType.navigation:
        return item.route != null && item.route!.isNotEmpty;
      case MenuItemType.externalUrl:
        return item.url != null && item.url!.isNotEmpty;
      case MenuItemType.share:
        return item.shareText != null && item.shareText!.isNotEmpty;
      case MenuItemType.email:
        return item.email != null && item.email!.isNotEmpty;
      case MenuItemType.action:
        return item.customAction != null;
    }
  }

  List<MenuItem> getProblematicItems() {
    return _sections
        .expand((section) => section.visibleItems)
        .where((item) => !canHandleItem(item))
        .toList();
  }

  // Utility methods
  String getSectionTitle(String sectionId) {
    final section = getSectionById(sectionId);
    return section?.title ?? 'Seção Desconhecida';
  }

  int getSectionItemCount(String sectionId) {
    final section = getSectionById(sectionId);
    return section?.visibleItemCount ?? 0;
  }

  bool hasSectionItems(String sectionId) {
    return getSectionItemCount(sectionId) > 0;
  }

  MenuItemCategory? getSectionPrimaryCategory(String sectionId) {
    final section = getSectionById(sectionId);
    if (section == null || section.items.isEmpty) return null;
    
    // Return the most common category in the section
    final categoryCounts = <MenuItemCategory, int>{};
    for (final item in section.items) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }
    
    return categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Future<void> refresh() async {
    _clearError();
    await initialize();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('MoreController Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

}
