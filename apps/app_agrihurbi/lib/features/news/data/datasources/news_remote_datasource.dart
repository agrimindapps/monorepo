import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/network/dio_client.dart';
import 'package:app_agrihurbi/features/news/data/models/news_article_model.dart';
import 'package:app_agrihurbi/features/news/data/models/commodity_price_model.dart';

/// News Remote Data Source
/// 
/// Handles RSS feed parsing and external API calls
/// for agriculture news and commodity prices
@injectable
class NewsRemoteDataSource {
  final DioClient _client;

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
          // Continue with other feeds if one fails
          print('Failed to fetch from feed $feedUrl: $e');
        }
      }

      // Sort by publication date (newest first) and apply limit
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

      final response = await _client.get(
        '/api/v1/news/search',
        queryParameters: params,
      );

      final List<dynamic> articlesJson = response.data['articles'] ?? [];
      return articlesJson
          .map((json) => NewsArticleModel.fromJson(json))
          .toList();
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
      final response = await _client.get(
        '/api/v1/news/premium',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final List<dynamic> articlesJson = response.data['articles'] ?? [];
      return articlesJson
          .map((json) => NewsArticleModel.fromJson(json))
          .toList();
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

      final response = await _client.get(
        '/api/v1/commodities/prices',
        queryParameters: params,
      );

      final List<dynamic> pricesJson = response.data['commodities'] ?? [];
      return pricesJson
          .map((json) => CommodityPriceModel.fromJson(json))
          .toList();
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
      final response = await _client.get(
        '/api/v1/commodities/$commodityId/history',
        queryParameters: {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      );

      final List<dynamic> historyJson = response.data['history'] ?? [];
      return historyJson
          .map((json) => HistoricalPriceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch commodity history: $e');
    }
  }

  /// Get market summary
  Future<MarketSummaryModel> fetchMarketSummary() async {
    try {
      final response = await _client.get('/api/v1/markets/summary');
      return MarketSummaryModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to fetch market summary: $e');
    }
  }

  /// Parse RSS feed from URL
  Future<List<NewsArticleModel>> _parseRSSFeed(String feedUrl) async {
    try {
      final response = await _client.dio.get(feedUrl);
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
      final description = item.findElements('description').firstOrNull?.innerText ?? '';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final pubDateStr = item.findElements('pubDate').firstOrNull?.innerText ?? '';
      final category = item.findElements('category').firstOrNull?.innerText ?? 'agriculture';

      // Extract image from content or enclosure
      String imageUrl = '';
      final enclosure = item.findElements('enclosure').firstOrNull;
      if (enclosure != null && enclosure.getAttribute('type')?.startsWith('image/') == true) {
        imageUrl = enclosure.getAttribute('url') ?? '';
      }

      // Parse publication date
      DateTime publishedAt;
      try {
        publishedAt = DateTime.parse(pubDateStr);
      } catch (e) {
        publishedAt = DateTime.now();
      }

      // Generate unique ID from URL and title
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
      // This would typically use a web scraping service or API
      // For now, return the URL as content indication
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