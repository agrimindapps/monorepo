import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:flutter/material.dart';

/// News Article Card Widget
/// 
/// Displays news article information in a card format
/// with support for premium content and favorite actions
class NewsArticleCard extends StatelessWidget {
  final NewsArticleEntity article;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isPremium;
  final bool isFavorite;

  const NewsArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.isPremium = false,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildDescription(context),
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (article.imageUrl.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.article,
          size: 48,
          color: Colors.grey,
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(article.imageUrl),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
              },
            ),
          ),
        ),
        if (article.isPremium)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            article.category.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(article.publishedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      article.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      article.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade700,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            article.author,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${article.readTimeMinutes} min',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onFavorite != null)
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey.shade600,
              size: 20,
            ),
            onPressed: onFavorite,
            tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            visualDensity: VisualDensity.compact,
          ),
        if (onShare != null)
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onPressed: onShare,
            tooltip: 'Compartilhar',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (article.category) {
      case NewsCategory.crops:
        return Colors.green;
      case NewsCategory.livestock:
        return Colors.brown;
      case NewsCategory.technology:
        return Colors.blue;
      case NewsCategory.market:
        return Colors.orange;
      case NewsCategory.weather:
        return Colors.lightBlue;
      case NewsCategory.sustainability:
        return Colors.teal;
      case NewsCategory.government:
        return Colors.purple;
      case NewsCategory.research:
        return Colors.indigo;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m atrás';
      } else {
        return '${difference.inHours}h atrás';
      }
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
