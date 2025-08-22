import 'package:hive/hive.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';

part 'news_article_model.g.dart';

/// News Article Model with Hive Serialization
/// 
/// Represents a news article with complete information
/// for RSS feeds and agriculture news display
@HiveType(typeId: 10)
class NewsArticleModel extends NewsArticleEntity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final String author;
  
  @HiveField(5)
  final String sourceUrl;
  
  @HiveField(6)
  final String imageUrl;
  
  @HiveField(7)
  final DateTime publishedAt;
  
  @HiveField(8)
  final NewsCategoryModel category;
  
  @HiveField(9)
  final List<String> tags;
  
  @HiveField(10)
  final bool isPremium;
  
  @HiveField(11)
  final int readTimeMinutes;

  const NewsArticleModel({
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
  }) : super(
          id: id,
          title: title,
          description: description,
          content: content,
          author: author,
          sourceUrl: sourceUrl,
          imageUrl: imageUrl,
          publishedAt: publishedAt,
          category: category,
          tags: tags,
          isPremium: isPremium,
          readTimeMinutes: readTimeMinutes,
        );

  /// Create from Entity
  factory NewsArticleModel.fromEntity(NewsArticleEntity entity) {
    return NewsArticleModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      author: entity.author,
      sourceUrl: entity.sourceUrl,
      imageUrl: entity.imageUrl,
      publishedAt: entity.publishedAt,
      category: NewsCategoryModel.fromEntity(entity.category),
      tags: entity.tags,
      isPremium: entity.isPremium,
      readTimeMinutes: entity.readTimeMinutes,
    );
  }

  /// Create from JSON (RSS/API response)
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      sourceUrl: json['sourceUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      category: NewsCategoryModel.fromString(json['category'] ?? 'crops'),
      tags: List<String>.from(json['tags'] ?? []),
      isPremium: json['isPremium'] ?? false,
      readTimeMinutes: json['readTimeMinutes'] ?? 3,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'sourceUrl': sourceUrl,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category.name,
      'tags': tags,
      'isPremium': isPremium,
      'readTimeMinutes': readTimeMinutes,
    };
  }

  /// Copy with modifications
  NewsArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? author,
    String? sourceUrl,
    String? imageUrl,
    DateTime? publishedAt,
    NewsCategoryModel? category,
    List<String>? tags,
    bool? isPremium,
    int? readTimeMinutes,
  }) {
    return NewsArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
    );
  }
}

/// News Category Model with Hive Serialization
@HiveType(typeId: 11)
enum NewsCategoryModel {
  @HiveField(0)
  crops,
  
  @HiveField(1)
  livestock,
  
  @HiveField(2)
  technology,
  
  @HiveField(3)
  market,
  
  @HiveField(4)
  weather,
  
  @HiveField(5)
  sustainability,
  
  @HiveField(6)
  government,
  
  @HiveField(7)
  research;

  /// Convert to domain entity
  NewsCategory toEntity() {
    switch (this) {
      case NewsCategoryModel.crops:
        return NewsCategory.crops;
      case NewsCategoryModel.livestock:
        return NewsCategory.livestock;
      case NewsCategoryModel.technology:
        return NewsCategory.technology;
      case NewsCategoryModel.market:
        return NewsCategory.market;
      case NewsCategoryModel.weather:
        return NewsCategory.weather;
      case NewsCategoryModel.sustainability:
        return NewsCategory.sustainability;
      case NewsCategoryModel.government:
        return NewsCategory.government;
      case NewsCategoryModel.research:
        return NewsCategory.research;
    }
  }

  /// Create from domain entity
  static NewsCategoryModel fromEntity(NewsCategory category) {
    switch (category) {
      case NewsCategory.crops:
        return NewsCategoryModel.crops;
      case NewsCategory.livestock:
        return NewsCategoryModel.livestock;
      case NewsCategory.technology:
        return NewsCategoryModel.technology;
      case NewsCategory.market:
        return NewsCategoryModel.market;
      case NewsCategory.weather:
        return NewsCategoryModel.weather;
      case NewsCategory.sustainability:
        return NewsCategoryModel.sustainability;
      case NewsCategory.government:
        return NewsCategoryModel.government;
      case NewsCategory.research:
        return NewsCategoryModel.research;
    }
  }

  /// Create from string
  static NewsCategoryModel fromString(String categoryStr) {
    switch (categoryStr.toLowerCase()) {
      case 'crops':
      case 'cultivos':
        return NewsCategoryModel.crops;
      case 'livestock':
      case 'pecuária':
      case 'pecuaria':
        return NewsCategoryModel.livestock;
      case 'technology':
      case 'tecnologia':
        return NewsCategoryModel.technology;
      case 'market':
      case 'mercado':
        return NewsCategoryModel.market;
      case 'weather':
      case 'clima':
        return NewsCategoryModel.weather;
      case 'sustainability':
      case 'sustentabilidade':
        return NewsCategoryModel.sustainability;
      case 'government':
      case 'políticas':
      case 'politicas':
        return NewsCategoryModel.government;
      case 'research':
      case 'pesquisa':
        return NewsCategoryModel.research;
      default:
        return NewsCategoryModel.crops;
    }
  }

  String get displayName {
    switch (this) {
      case NewsCategoryModel.crops:
        return 'Cultivos';
      case NewsCategoryModel.livestock:
        return 'Pecuária';
      case NewsCategoryModel.technology:
        return 'Tecnologia';
      case NewsCategoryModel.market:
        return 'Mercado';
      case NewsCategoryModel.weather:
        return 'Clima';
      case NewsCategoryModel.sustainability:
        return 'Sustentabilidade';
      case NewsCategoryModel.government:
        return 'Políticas';
      case NewsCategoryModel.research:
        return 'Pesquisa';
    }
  }
}

/// News Filter Model for API requests
class NewsFilterModel {
  final List<NewsCategoryModel> categories;
  final bool showOnlyPremium;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;

  const NewsFilterModel({
    this.categories = const [],
    this.showOnlyPremium = false,
    this.fromDate,
    this.toDate,
    this.searchQuery,
  });

  /// Convert to domain entity
  NewsFilter toEntity() {
    return NewsFilter(
      categories: categories.map((c) => c.toEntity()).toList(),
      showOnlyPremium: showOnlyPremium,
      fromDate: fromDate,
      toDate: toDate,
      searchQuery: searchQuery,
    );
  }

  /// Create from domain entity
  static NewsFilterModel fromEntity(NewsFilter filter) {
    return NewsFilterModel(
      categories: filter.categories.map((c) => NewsCategoryModel.fromEntity(c)).toList(),
      showOnlyPremium: filter.showOnlyPremium,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
      searchQuery: filter.searchQuery,
    );
  }

  /// Convert to API query parameters
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (categories.isNotEmpty) {
      params['categories'] = categories.map((c) => c.name).join(',');
    }
    
    if (showOnlyPremium) {
      params['premium'] = 'true';
    }
    
    if (fromDate != null) {
      params['from'] = fromDate!.toIso8601String();
    }
    
    if (toDate != null) {
      params['to'] = toDate!.toIso8601String();
    }
    
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['q'] = searchQuery;
    }
    
    return params;
  }
}