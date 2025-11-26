
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';


/// News Article Model
///
/// Represents a news article with complete information
/// for RSS feeds and agriculture news display
class NewsArticleModel extends NewsArticleEntity {
  final NewsCategoryModel _category;

  const NewsArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.author,
    required super.sourceUrl,
    required super.imageUrl,
    required super.publishedAt,
    required NewsCategoryModel category,
    required super.tags,
    super.isPremium = false,
    super.readTimeMinutes = 3,
  }) : _category = category,
       super(
          category: NewsCategory.crops, // placeholder, será sobrescrito pelo getter
        );

  /// Override getter to convert model category to domain category
  @override
  NewsCategory get category => _category.toEntity();

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
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      author: (json['author'] as String?) ?? '',
      sourceUrl: (json['sourceUrl'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      publishedAt: DateTime.tryParse((json['publishedAt'] as String?) ?? '') ?? DateTime.now(),
      category: NewsCategoryModel.fromString((json['category'] as String?) ?? 'crops'),
      tags: List<String>.from((json['tags'] as List?) ?? []),
      isPremium: (json['isPremium'] as bool?) ?? false,
      readTimeMinutes: (json['readTimeMinutes'] as int?) ?? 3,
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
      category: category ?? _category,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
    );
  }
}

/// News Category Model
enum NewsCategoryModel {
  crops,
  
  livestock,
  
  technology,
  
  market,
  
  weather,
  
  sustainability,
  
  government,
  
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
