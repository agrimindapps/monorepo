/// Immutable entity representing a feature discovery tooltip
class FeatureTooltip {
  final String id;
  final String title;
  final String description;
  final String targetWidget;
  final Map<String, dynamic> config;
  final int priority;
  final List<String> triggers;

  const FeatureTooltip({
    required this.id,
    required this.title,
    required this.description,
    required this.targetWidget,
    this.config = const {},
    this.priority = 1,
    this.triggers = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureTooltip &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          targetWidget == other.targetWidget &&
          config == other.config &&
          priority == other.priority &&
          triggers == other.triggers;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      targetWidget.hashCode ^
      config.hashCode ^
      priority.hashCode ^
      triggers.hashCode;

  @override
  String toString() =>
      'FeatureTooltip(id: $id, title: $title, priority: $priority)';
}
