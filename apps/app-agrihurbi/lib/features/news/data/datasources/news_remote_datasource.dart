import 'package:app_agrihurbi/core/error/exceptions.dart';

import 'package:app_agrihurbi/features/news/data/models/commodity_price_model.dart';
import 'package:app_agrihurbi/features/news/data/models/news_article_model.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

/// News Remote Data Source
///
/// Handles RSS feed parsing and external API calls
/// for agriculture news and commodity prices
class NewsRemoteDataSource {
  final Dio _client;

  const NewsRemoteDataSource(this._client);

  /// Default RSS feeds for agriculture news
  static const List<String> _defaultRSSFeeds = [
    'https://agroweb.com.br/rss',
    'https://revistagloborural.globo.com/rss/ultimas-noticias.xml',
    'https://www.canalrural.com.br/feed/',
    'https://www.embrapa.br/noticias/rss',
    'https://www.agricultura.sp.gov.br/noticias/rss',
  ];

  /// Fetch news from RSS feeds
  Future<List<NewsArticleModel>> fetchNewsFromRSS({
    List<String>? customFeeds,
    int limit = 20,
  }) async {
    try {
      final feeds = customFeeds ?? _defaultRSSFeeds;
      final List<NewsArticleModel> allArticles = [];

      for (final feedUrl in feeds) {
        try {
          final articles = await _parseRSSFeed(feedUrl);
          allArticles.addAll(articles);
        } catch (e) {
          print('Failed to fetch from feed $feedUrl: $e');
        }
      }
      allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allArticles.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to fetch RSS feeds: $e');
    }
  }

  /// Search news articles using external API
  Future<List<NewsArticleModel>> searchNews({
    required String query,
    NewsFilterModel? filter,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'limit': limit,
        'language': 'pt',
        'category': 'agriculture',
      };

      if (filter != null) {
        params.addAll(filter.toQueryParams());
      }

      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/news/search',
        queryParameters: params,
      );

      final articlesData = response.data!['articles'];
      if (articlesData is! List) {
        throw const ServerException(
          'Invalid response format: articles should be a list',
        );
      }
      final List<dynamic> articlesJson = articlesData;
      return articlesJson.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const ServerException(
            'Invalid article format: expected Map<String, dynamic>',
          );
        }
        return NewsArticleModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to search news: $e');
    }
  }

  /// Get premium news articles
  Future<List<NewsArticleModel>> fetchPremiumNews({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/news/premium',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final articlesData = response.data!['articles'];
      if (articlesData is! List) {
        throw const ServerException(
          'Invalid response format: articles should be a list',
        );
      }
      final List<dynamic> articlesJson = articlesData;
      return articlesJson.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const ServerException(
            'Invalid article format: expected Map<String, dynamic>',
          );
        }
        return NewsArticleModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch premium news: $e');
    }
  }

  /// Fetch commodity prices from market API
  Future<List<CommodityPriceModel>> fetchCommodityPrices({
    List<CommodityTypeModel>? types,
  }) async {
    try {
      final params = <String, dynamic>{};

      if (types != null && types.isNotEmpty) {
        params['types'] = types.map((t) => t.name).join(',');
      }

      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/commodities/prices',
        queryParameters: params,
      );

      final commoditiesData = response.data!['commodities'];
      if (commoditiesData is! List) {
        throw const ServerException(
          'Invalid response format: commodities should be a list',
        );
      }
      final List<dynamic> pricesJson = commoditiesData;
      return pricesJson.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const ServerException(
            'Invalid commodity format: expected Map<String, dynamic>',
          );
        }
        return CommodityPriceModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch commodity prices: $e');
    }
  }

  /// Get commodity price history
  Future<List<HistoricalPriceModel>> fetchCommodityHistory({
    required String commodityId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/commodities/$commodityId/history',
        queryParameters: {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      );

      final historyData = response.data!['history'];
      if (historyData is! List) {
        throw const ServerException(
          'Invalid response format: history should be a list',
        );
      }
      final List<dynamic> historyJson = historyData;
      return historyJson.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const ServerException(
            'Invalid history format: expected Map<String, dynamic>',
          );
        }
        return HistoricalPriceModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch commodity history: $e');
    }
  }

  /// Get market summary
  Future<CommodityMarketSummaryModel> fetchMarketSummary() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/markets/summary',
      );
      if (response.data is! Map<String, dynamic>) {
        throw const ServerException(
          'Invalid response format: expected Map<String, dynamic>',
        );
      }
      return CommodityMarketSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException('Failed to fetch market summary: $e');
    }
  }

  /// Parse RSS feed from URL
  Future<List<NewsArticleModel>> _parseRSSFeed(String feedUrl) async {
    try {
      final response = await _client.get<String>(feedUrl);
      final xmlString = response.data as String;
      final document = XmlDocument.parse(xmlString);

      final items = document.findAllElements('item');
      final articles = <NewsArticleModel>[];

      for (final item in items) {
        final article = _parseRSSItem(item);
        if (article != null) {
          articles.add(article);
        }
      }

      return articles;
    } catch (e) {
      throw ServerException('Failed to parse RSS feed $feedUrl: $e');
    }
  }

  /// Parse individual RSS item
  NewsArticleModel? _parseRSSItem(XmlElement item) {
    try {
      final title = item.findElements('title').first.innerText;
      final description =
          item.findElements('description').firstOrNull?.innerText ?? '';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final pubDateStr =
          item.findElements('pubDate').firstOrNull?.innerText ?? '';
      final category =
          item.findElements('category').firstOrNull?.innerText ?? 'agriculture';
      String imageUrl = '';
      final enclosure = item.findElements('enclosure').firstOrNull;
      if (enclosure != null &&
          enclosure.getAttribute('type')?.startsWith('image/') == true) {
        imageUrl = enclosure.getAttribute('url') ?? '';
      }
      DateTime publishedAt;
      try {
        publishedAt = DateTime.parse(pubDateStr);
      } catch (e) {
        publishedAt = DateTime.now();
      }
      final id = '$link-${title.hashCode}'.replaceAll(RegExp(r'[^\w-]'), '');

      return NewsArticleModel(
        id: id,
        title: title,
        description: description,
        content: description, // RSS usually doesn't have full content
        author: 'RSS Feed',
        sourceUrl: link,
        imageUrl: imageUrl,
        publishedAt: publishedAt,
        category: NewsCategoryModel.fromString(category),
        tags: [category],
        isPremium: false,
        readTimeMinutes: _calculateReadTime(description),
      );
    } catch (e) {
      print('Error parsing RSS item: $e');
      return null;
    }
  }

  /// Calculate estimated read time
  int _calculateReadTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil().clamp(1, 15); // ~200 words per minute
  }

  /// Fetch article content by URL (for full content)
  Future<String> fetchArticleContent(String articleUrl) async {
    try {
      return 'Content available at: $articleUrl';
    } catch (e) {
      throw ServerException('Failed to fetch article content: $e');
    }
  }
}

/// RSS Feed Configuration
class RSSFeedConfig {
  final String name;
  final String url;
  final NewsCategoryModel defaultCategory;
  final bool isActive;

  const RSSFeedConfig({
    required this.name,
    required this.url,
    required this.defaultCategory,
    this.isActive = true,
  });
}
