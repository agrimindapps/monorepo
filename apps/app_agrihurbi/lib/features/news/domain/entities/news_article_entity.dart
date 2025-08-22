import 'package:equatable/equatable.dart';

/// News Article Entity for Agriculture News System
/// 
/// Represents a news article with complete information
/// for RSS feeds and agriculture news display
class NewsArticleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String sourceUrl;
  final String imageUrl;
  final DateTime publishedAt;
  final NewsCategory category;
  final List<String> tags;
  final bool isPremium;
  final int readTimeMinutes;

  const NewsArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.sourceUrl,
    required this.imageUrl,
    required this.publishedAt,
    required this.category,
    required this.tags,
    this.isPremium = false,
    this.readTimeMinutes = 3,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        author,
        sourceUrl,
        imageUrl,
        publishedAt,
        category,
        tags,
        isPremium,
        readTimeMinutes,
      ];
}

/// News Categories for Agriculture Content
enum NewsCategory {
  crops('Cultivos'),
  livestock('Pecuária'),
  technology('Tecnologia'),
  market('Mercado'),
  weather('Clima'),
  sustainability('Sustentabilidade'),
  government('Políticas'),
  research('Pesquisa');

  const NewsCategory(this.displayName);
  final String displayName;
}

/// News Filter Options
class NewsFilter extends Equatable {
  final List<NewsCategory> categories;
  final bool showOnlyPremium;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;

  const NewsFilter({
    this.categories = const [],
    this.showOnlyPremium = false,
    this.fromDate,
    this.toDate,
    this.searchQuery,
  });

  NewsFilter copyWith({
    List<NewsCategory>? categories,
    bool? showOnlyPremium,
    DateTime? fromDate,
    DateTime? toDate,
    String? searchQuery,
  }) {
    return NewsFilter(
      categories: categories ?? this.categories,
      showOnlyPremium: showOnlyPremium ?? this.showOnlyPremium,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        showOnlyPremium,
        fromDate,
        toDate,
        searchQuery,
      ];
}