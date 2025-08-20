// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../models/navigation_model.dart';
import '../services/scroll_service.dart';

class NavigationController extends ChangeNotifier {
  // Services
  late final ScrollService _scrollService;

  // State
  NavigationState _navigationState = const NavigationState();
  NavigationHistory _history = PromoNavigationRepository.createEmptyHistory();
  NavigationScrollBehavior _scrollBehavior = PromoNavigationRepository.getDefaultScrollBehavior();
  bool _isInitialized = false;

  // Controllers
  ScrollController? _scrollController;
  
  // Getters
  NavigationState get navigationState => _navigationState;
  NavigationHistory get history => _history;
  NavigationScrollBehavior get scrollBehavior => _scrollBehavior;
  bool get isInitialized => _isInitialized;
  ScrollController? get scrollController => _scrollController;

  // Navigation state getters
  NavigationSection? get currentSection => _navigationState.currentSection;
  double get scrollOffset => _navigationState.scrollOffset;
  bool get isScrolling => _navigationState.isScrolling;
  List<NavigationSection> get visibleSections => _navigationState.visibleSections;

  NavigationController() {
    _initializeServices();
  }

  void _initializeServices() {
    _scrollService = ScrollService();
  }

  Future<void> initialize() async {
    try {
      _scrollController = ScrollController();
      _scrollController!.addListener(_onScrollChanged);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('NavigationController initialization error: $e');
    }
  }

  void _onScrollChanged() {
    if (_scrollController == null) return;

    final offset = _scrollController!.offset;
    final currentSection = PromoNavigationRepository.getCurrentSection(offset);
    final visibleSections = PromoNavigationRepository.getVisibleSections(
      offset,
      _scrollController!.position.viewportDimension,
    );

    _updateNavigationState(
      currentSection: currentSection,
      scrollOffset: offset,
      visibleSections: visibleSections,
    );

    if (currentSection != null && currentSection != _navigationState.currentSection) {
      _updateHistory(currentSection);
    }
  }

  void _updateNavigationState({
    NavigationSection? currentSection,
    double? scrollOffset,
    bool? isScrolling,
    List<NavigationSection>? visibleSections,
  }) {
    _navigationState = _navigationState.copyWith(
      currentSection: currentSection,
      scrollOffset: scrollOffset,
      isScrolling: isScrolling,
      visibleSections: visibleSections,
    );
    notifyListeners();
  }

  void _updateHistory(NavigationSection section) {
    _history = _history.addVisitedSection(section);
  }

  // Navigation methods
  Future<void> scrollToSection(NavigationSection section) async {
    if (_scrollController == null || !_isInitialized) return;

    _updateNavigationState(isScrolling: true);

    try {
      await _scrollService.animateToOffset(
        _scrollController!,
        section.offset,
        duration: _scrollBehavior.duration,
        curve: _scrollBehavior.curve,
      );
      
      _updateHistory(section);
    } catch (e) {
      debugPrint('Error scrolling to section ${section.id}: $e');
    } finally {
      _updateNavigationState(isScrolling: false);
    }
  }

  Future<void> scrollToSectionById(String sectionId) async {
    final section = PromoNavigationRepository.getSectionById(sectionId);
    if (section != null) {
      await scrollToSection(section);
    }
  }

  Future<void> scrollToOffset(double offset) async {
    if (_scrollController == null || !_isInitialized) return;

    _updateNavigationState(isScrolling: true);

    try {
      await _scrollService.animateToOffset(
        _scrollController!,
        offset,
        duration: _scrollBehavior.duration,
        curve: _scrollBehavior.curve,
      );
    } catch (e) {
      debugPrint('Error scrolling to offset $offset: $e');
    } finally {
      _updateNavigationState(isScrolling: false);
    }
  }

  void jumpToSection(NavigationSection section) {
    if (_scrollController == null || !_isInitialized) return;

    try {
      _scrollController!.jumpTo(section.offset);
      _updateHistory(section);
    } catch (e) {
      debugPrint('Error jumping to section ${section.id}: $e');
    }
  }

  void jumpToOffset(double offset) {
    if (_scrollController == null || !_isInitialized) return;

    try {
      _scrollController!.jumpTo(offset);
    } catch (e) {
      debugPrint('Error jumping to offset $offset: $e');
    }
  }

  // Navigation control
  Future<void> scrollToNext() async {
    final current = _navigationState.currentSection;
    if (current != null) {
      final next = PromoNavigationRepository.getNextSection(current);
      if (next != null) {
        await scrollToSection(next);
      }
    }
  }

  Future<void> scrollToPrevious() async {
    final current = _navigationState.currentSection;
    if (current != null) {
      final previous = PromoNavigationRepository.getPreviousSection(current);
      if (previous != null) {
        await scrollToSection(previous);
      }
    }
  }

  Future<void> scrollToTop() async {
    await scrollToSection(NavigationSection.hero);
  }

  Future<void> scrollToBottom() async {
    await scrollToSection(NavigationSection.faq);
  }

  // Navigation items
  List<PromoNavigationItem> getNavigationItems() {
    return PromoNavigationRepository.getNavigationItems(
      activeSection: _navigationState.currentSection,
    );
  }

  PromoNavigationItem? getNavigationItem(NavigationSection section) {
    final items = getNavigationItems();
    try {
      return items.firstWhere((item) => item.section == section);
    } catch (e) {
      return null;
    }
  }

  // Progress and state queries
  double getScrollProgress() {
    return PromoNavigationRepository.getScrollProgress(_navigationState.scrollOffset);
  }

  double getProgressToSection(NavigationSection section) {
    return _navigationState.getProgressToSection(section);
  }

  bool isSectionActive(NavigationSection section) {
    return _navigationState.isSectionActive(section);
  }

  bool isSectionVisible(NavigationSection section) {
    return _navigationState.visibleSections.contains(section);
  }

  bool canScrollToNext() {
    final current = _navigationState.currentSection;
    if (current == null) return true;
    return PromoNavigationRepository.getNextSection(current) != null;
  }

  bool canScrollToPrevious() {
    final current = _navigationState.currentSection;
    if (current == null) return false;
    return PromoNavigationRepository.getPreviousSection(current) != null;
  }

  // Scroll behavior configuration
  void updateScrollBehavior(NavigationScrollBehavior behavior) {
    _scrollBehavior = behavior;
    notifyListeners();
  }

  void setScrollDuration(Duration duration) {
    _scrollBehavior = _scrollBehavior.copyWith(duration: duration);
  }

  void setScrollCurve(Curve curve) {
    _scrollBehavior = _scrollBehavior.copyWith(curve: curve);
  }

  void setScrollThreshold(double threshold) {
    _scrollBehavior = _scrollBehavior.copyWith(threshold: threshold);
  }

  void enableAutoScroll(bool enable) {
    _scrollBehavior = _scrollBehavior.copyWith(enableAutoScroll: enable);
  }

  // History management
  void clearHistory() {
    _history = PromoNavigationRepository.createEmptyHistory();
    notifyListeners();
  }

  bool hasVisitedSection(NavigationSection section) {
    return _history.hasVisited(section);
  }

  int getVisitedSectionCount() {
    return _history.visitedCount;
  }

  bool hasVisitedAllSections() {
    return _history.hasVisitedAll;
  }

  Duration getTimeSinceLastNavigation() {
    return _history.timeSinceLastNavigation;
  }

  // Statistics and analytics
  Map<String, dynamic> getNavigationStatistics() {
    return PromoNavigationRepository.getNavigationStatistics(_history);
  }

  Map<String, dynamic> getScrollStatistics() {
    return {
      'scrollOffset': _navigationState.scrollOffset,
      'scrollProgress': getScrollProgress(),
      'currentSection': _navigationState.currentSection?.id,
      'visibleSections': _navigationState.visibleSections.map((s) => s.id).toList(),
      'isScrolling': _navigationState.isScrolling,
      'scrollBehavior': _scrollBehavior.toJson(),
    };
  }

  // Validation and utility
  bool isValidScrollPosition(double offset) {
    return offset >= 0 && offset <= PromoNavigationRepository.getTotalScrollDistance();
  }

  NavigationSection? getSectionAtOffset(double offset) {
    return PromoNavigationRepository.getSectionByOffset(offset);
  }

  List<NavigationSection> getAllSections() {
    return PromoNavigationRepository.getAllSections();
  }

  Map<String, double> getSectionOffsets() {
    return PromoNavigationRepository.getSectionOffsets();
  }

  // Mobile menu support
  void showMobileMenu(BuildContext context) {
    if (!_isInitialized) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => _MobileNavigationMenu(
        controller: this,
        items: getNavigationItems(),
      ),
    );
  }

  // Keyboard navigation
  void handleKeyboardNavigation(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.pageUp:
        scrollToPrevious();
        break;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.pageDown:
        scrollToNext();
        break;
      case LogicalKeyboardKey.home:
        scrollToTop();
        break;
      case LogicalKeyboardKey.end:
        scrollToBottom();
        break;
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScrollChanged);
    _scrollController?.dispose();
    super.dispose();
  }
}

// Mobile navigation menu widget
class _MobileNavigationMenu extends StatelessWidget {
  final NavigationController controller;
  final List<PromoNavigationItem> items;

  const _MobileNavigationMenu({
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Navegação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              selected: item.isActive,
              onTap: () {
                Navigator.pop(context);
                controller.scrollToSection(item.section);
              },
            );
          }),
        ],
      ),
    );
  }
}
