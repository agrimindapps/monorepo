// Flutter imports:
import 'package:flutter/material.dart';

enum NavigationSection {
  hero('hero', 'Início', Icons.home, 0),
  features('features', 'Recursos', Icons.grid_view, 700),
  screenshots('screenshots', 'Screenshots', Icons.phone_android, 1400),
  testimonials('testimonials', 'Depoimentos', Icons.rate_review, 2200),
  download('download', 'Download', Icons.download, 2800),
  faq('faq', 'FAQ', Icons.question_answer, 3300);

  const NavigationSection(this.id, this.displayName, this.icon, this.offset);
  final String id;
  final String displayName;
  final IconData icon;
  final double offset;
}

class PromoNavigationItem {
  final NavigationSection section;
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const PromoNavigationItem({
    required this.section,
    required this.title,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  PromoNavigationItem copyWith({
    NavigationSection? section,
    String? title,
    IconData? icon,
    bool? isActive,
    VoidCallback? onTap,
  }) {
    return PromoNavigationItem(
      section: section ?? this.section,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      onTap: onTap ?? this.onTap,
    );
  }

  String get sectionId => section.id;
  double get offset => section.offset;

  Map<String, dynamic> toJson() {
    return {
      'section': section.id,
      'title': title,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'PromoNavigationItem(section: ${section.id}, title: $title, isActive: $isActive)';
  }
}

class NavigationState {
  final NavigationSection? currentSection;
  final double scrollOffset;
  final bool isScrolling;
  final List<NavigationSection> visibleSections;

  const NavigationState({
    this.currentSection,
    this.scrollOffset = 0.0,
    this.isScrolling = false,
    this.visibleSections = const [],
  });

  NavigationState copyWith({
    NavigationSection? currentSection,
    double? scrollOffset,
    bool? isScrolling,
    List<NavigationSection>? visibleSections,
  }) {
    return NavigationState(
      currentSection: currentSection ?? this.currentSection,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      isScrolling: isScrolling ?? this.isScrolling,
      visibleSections: visibleSections ?? this.visibleSections,
    );
  }

  bool get hasCurrentSection => currentSection != null;
  String? get currentSectionId => currentSection?.id;
  String? get currentSectionTitle => currentSection?.displayName;

  bool isSectionActive(NavigationSection section) {
    return currentSection == section;
  }

  double getProgressToSection(NavigationSection section) {
    if (scrollOffset < section.offset) return 0.0;
    
    final nextSection = _getNextSection(section);
    if (nextSection == null) return 1.0;
    
    final sectionRange = nextSection.offset - section.offset;
    final progress = (scrollOffset - section.offset) / sectionRange;
    return progress.clamp(0.0, 1.0);
  }

  NavigationSection? _getNextSection(NavigationSection current) {
    const sections = NavigationSection.values;
    final currentIndex = sections.indexOf(current);
    
    if (currentIndex >= 0 && currentIndex < sections.length - 1) {
      return sections[currentIndex + 1];
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'currentSection': currentSection?.id,
      'scrollOffset': scrollOffset,
      'isScrolling': isScrolling,
      'visibleSections': visibleSections.map((s) => s.id).toList(),
    };
  }

  @override
  String toString() {
    return 'NavigationState(currentSection: ${currentSection?.id}, scrollOffset: $scrollOffset, isScrolling: $isScrolling)';
  }
}

class NavigationScrollBehavior {
  final Duration duration;
  final Curve curve;
  final double threshold;
  final bool enableAutoScroll;

  const NavigationScrollBehavior({
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.threshold = 100.0,
    this.enableAutoScroll = true,
  });

  NavigationScrollBehavior copyWith({
    Duration? duration,
    Curve? curve,
    double? threshold,
    bool? enableAutoScroll,
  }) {
    return NavigationScrollBehavior(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      threshold: threshold ?? this.threshold,
      enableAutoScroll: enableAutoScroll ?? this.enableAutoScroll,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration.inMilliseconds,
      'threshold': threshold,
      'enableAutoScroll': enableAutoScroll,
    };
  }

  @override
  String toString() {
    return 'NavigationScrollBehavior(duration: ${duration.inMilliseconds}ms, threshold: $threshold, enableAutoScroll: $enableAutoScroll)';
  }
}

class NavigationHistory {
  final List<NavigationSection> visitedSections;
  final DateTime lastNavigationTime;
  final NavigationSection? lastSection;

  const NavigationHistory({
    this.visitedSections = const [],
    required this.lastNavigationTime,
    this.lastSection,
  });

  NavigationHistory copyWith({
    List<NavigationSection>? visitedSections,
    DateTime? lastNavigationTime,
    NavigationSection? lastSection,
  }) {
    return NavigationHistory(
      visitedSections: visitedSections ?? this.visitedSections,
      lastNavigationTime: lastNavigationTime ?? this.lastNavigationTime,
      lastSection: lastSection ?? this.lastSection,
    );
  }

  NavigationHistory addVisitedSection(NavigationSection section) {
    final updatedSections = List<NavigationSection>.from(visitedSections);
    if (!updatedSections.contains(section)) {
      updatedSections.add(section);
    }
    
    return copyWith(
      visitedSections: updatedSections,
      lastNavigationTime: DateTime.now(),
      lastSection: section,
    );
  }

  bool hasVisited(NavigationSection section) {
    return visitedSections.contains(section);
  }

  int get visitedCount => visitedSections.length;
  bool get hasVisitedAll => visitedSections.length == NavigationSection.values.length;

  Duration get timeSinceLastNavigation {
    return DateTime.now().difference(lastNavigationTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'visitedSections': visitedSections.map((s) => s.id).toList(),
      'lastNavigationTime': lastNavigationTime.toIso8601String(),
      'lastSection': lastSection?.id,
    };
  }

  @override
  String toString() {
    return 'NavigationHistory(visitedCount: $visitedCount, lastSection: ${lastSection?.id})';
  }
}

class PromoNavigationRepository {
  static List<PromoNavigationItem> getNavigationItems({NavigationSection? activeSection}) {
    return NavigationSection.values.map((section) {
      return PromoNavigationItem(
        section: section,
        title: section.displayName,
        icon: section.icon,
        isActive: section == activeSection,
      );
    }).toList();
  }

  static List<NavigationSection> getAllSections() {
    return NavigationSection.values;
  }

  static NavigationSection? getSectionById(String id) {
    try {
      return NavigationSection.values.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  static NavigationSection? getSectionByOffset(double offset) {
    NavigationSection? closestSection;
    double minDistance = double.infinity;

    for (final section in NavigationSection.values) {
      final distance = (section.offset - offset).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestSection = section;
      }
    }

    return closestSection;
  }

  static NavigationSection? getCurrentSection(double scrollOffset) {
    NavigationSection? currentSection;
    
    for (final section in NavigationSection.values.reversed) {
      if (scrollOffset >= section.offset) {
        currentSection = section;
        break;
      }
    }
    
    return currentSection ?? NavigationSection.hero;
  }

  static NavigationSection? getNextSection(NavigationSection current) {
    const sections = NavigationSection.values;
    final currentIndex = sections.indexOf(current);
    
    if (currentIndex >= 0 && currentIndex < sections.length - 1) {
      return sections[currentIndex + 1];
    }
    
    return null;
  }

  static NavigationSection? getPreviousSection(NavigationSection current) {
    const sections = NavigationSection.values;
    final currentIndex = sections.indexOf(current);
    
    if (currentIndex > 0) {
      return sections[currentIndex - 1];
    }
    
    return null;
  }

  static double getTotalScrollDistance() {
    if (NavigationSection.values.isEmpty) return 0.0;
    return NavigationSection.values.last.offset;
  }

  static double getScrollProgress(double currentOffset) {
    final totalDistance = getTotalScrollDistance();
    if (totalDistance == 0) return 0.0;
    return (currentOffset / totalDistance).clamp(0.0, 1.0);
  }

  static List<NavigationSection> getVisibleSections(double scrollOffset, double viewportHeight) {
    final visibleSections = <NavigationSection>[];
    
    for (final section in NavigationSection.values) {
      final sectionStart = section.offset;
      final sectionEnd = sectionStart + 500; // Approximate section height
      
      final isVisible = (sectionStart <= scrollOffset + viewportHeight) &&
                       (sectionEnd >= scrollOffset);
      
      if (isVisible) {
        visibleSections.add(section);
      }
    }
    
    return visibleSections;
  }

  static NavigationScrollBehavior getDefaultScrollBehavior() {
    return const NavigationScrollBehavior(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      threshold: 100.0,
      enableAutoScroll: true,
    );
  }

  static NavigationHistory createEmptyHistory() {
    return NavigationHistory(
      visitedSections: const [],
      lastNavigationTime: DateTime.now(),
    );
  }

  static Map<String, dynamic> getNavigationStatistics(NavigationHistory history) {
    return {
      'totalSections': NavigationSection.values.length,
      'visitedSections': history.visitedCount,
      'completionPercentage': (history.visitedCount / NavigationSection.values.length * 100).round(),
      'hasVisitedAll': history.hasVisitedAll,
      'lastSection': history.lastSection?.id,
      'timeSinceLastNavigation': history.timeSinceLastNavigation.inSeconds,
    };
  }

  static List<String> getSectionTitles() {
    return NavigationSection.values.map((section) => section.displayName).toList();
  }

  static Map<String, double> getSectionOffsets() {
    final offsets = <String, double>{};
    for (final section in NavigationSection.values) {
      offsets[section.id] = section.offset;
    }
    return offsets;
  }

  static bool isValidSectionId(String id) {
    return NavigationSection.values.any((section) => section.id == id);
  }

  static NavigationSection getFirstSection() {
    return NavigationSection.values.first;
  }

  static NavigationSection getLastSection() {
    return NavigationSection.values.last;
  }

  static int getSectionIndex(NavigationSection section) {
    return NavigationSection.values.indexOf(section);
  }

  static NavigationSection? getSectionByIndex(int index) {
    if (index >= 0 && index < NavigationSection.values.length) {
      return NavigationSection.values[index];
    }
    return null;
  }
}
