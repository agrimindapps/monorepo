/// Immutable entity representing an onboarding step
class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final Map<String, dynamic> config;
  final bool isRequired;
  final List<String> dependencies;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset,
    this.config = const {},
    this.isRequired = true,
    this.dependencies = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStep &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          imageAsset == other.imageAsset &&
          config == other.config &&
          isRequired == other.isRequired &&
          dependencies == other.dependencies;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      imageAsset.hashCode ^
      config.hashCode ^
      isRequired.hashCode ^
      dependencies.hashCode;

  @override
  String toString() =>
      'OnboardingStep(id: $id, title: $title, isRequired: $isRequired)';
}
