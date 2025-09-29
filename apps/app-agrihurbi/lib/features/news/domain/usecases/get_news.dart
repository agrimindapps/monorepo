import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:app_agrihurbi/features/news/domain/repositories/news_repository.dart';
import 'package:injectable/injectable.dart';

/// Get News Use Case
/// 
/// Handles fetching news articles with filtering and pagination
@injectable
class GetNews {
  final NewsRepository _repository;

  const GetNews(_repository);

  /// Execute news fetching with optional filters
  ResultFuture<List<NewsArticleEntity>> call({
    NewsFilter? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _repository.getNews(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }
}

/// Get Article by ID Use Case
@injectable
class GetArticleById {
  final NewsRepository _repository;

  const GetArticleById(_repository);

  ResultFuture<NewsArticleEntity> call(String articleId) async {
    return await _repository.getArticleById(articleId);
  }
}

/// Search Articles Use Case
@injectable
class SearchArticles {
  final NewsRepository _repository;

  const SearchArticles(_repository);

  ResultFuture<List<NewsArticleEntity>> call({
    required String query,
    NewsFilter? filter,
    int limit = 20,
  }) async {
    return await _repository.searchArticles(
      query: query,
      filter: filter,
      limit: limit,
    );
  }
}

/// Get Premium Articles Use Case
@injectable
class GetPremiumArticles {
  final NewsRepository _repository;

  const GetPremiumArticles(_repository);

  ResultFuture<List<NewsArticleEntity>> call({
    int limit = 10,
    int offset = 0,
  }) async {
    return await _repository.getPremiumArticles(
      limit: limit,
      offset: offset,
    );
  }
}

/// Manage Favorites Use Case
@injectable
class ManageFavorites {
  final NewsRepository _repository;

  const ManageFavorites(_repository);

  /// Add article to favorites
  ResultVoid addToFavorites(String articleId) async {
    return await _repository.addToFavorites(articleId);
  }

  /// Remove article from favorites
  ResultVoid removeFromFavorites(String articleId) async {
    return await _repository.removeFromFavorites(articleId);
  }

  /// Get favorite articles
  ResultFuture<List<NewsArticleEntity>> getFavorites() async {
    return await _repository.getFavoriteArticles();
  }

  /// Check if article is favorite
  ResultFuture<bool> isFavorite(String articleId) async {
    return await _repository.isArticleFavorite(articleId);
  }
}

/// Refresh RSS Feeds Use Case
@injectable
class RefreshRSSFeeds {
  final NewsRepository _repository;

  const RefreshRSSFeeds(_repository);

  ResultVoid call() async {
    return await _repository.refreshRSSFeeds();
  }
}