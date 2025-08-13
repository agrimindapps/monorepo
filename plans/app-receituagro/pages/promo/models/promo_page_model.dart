class PromoPageModel {
  final String title;
  final String subtitle;
  final String description;
  final bool isLoading;

  const PromoPageModel({
    this.title = 'ReceituAgro',
    this.subtitle = 'Sua solução completa para agricultura',
    this.description = 'Sistema completo para gestão agrícola',
    this.isLoading = false,
  });

  PromoPageModel copyWith({
    String? title,
    String? subtitle,
    String? description,
    bool? isLoading,
  }) {
    return PromoPageModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromoPageModel &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.description == description &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        subtitle.hashCode ^
        description.hashCode ^
        isLoading.hashCode;
  }
}