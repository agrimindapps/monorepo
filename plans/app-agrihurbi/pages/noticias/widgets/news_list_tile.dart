// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../services/rss_service.dart';

class NewsListTile extends StatelessWidget {
  final ItemRSS item;

  const NewsListTile({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(
        isDesktop ? 16 : (isTablet ? 12 : 4),
        isDesktop ? 12 : 8,
        isDesktop ? 16 : (isTablet ? 12 : 4),
        isDesktop ? 12 : 8,
      ),
      title: Text(
        item.title,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
          height: 1.2,
        ),
        maxLines: isDesktop ? 2 : (isTablet ? 2 : 2),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            item.description,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: isDesktop ? 15 : (isTablet ? 14 : 14),
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: isDesktop ? 4 : (isTablet ? 3 : 3),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.channelName,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : (isTablet ? 12 : 12),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.pubDate,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : (isTablet ? 11 : 12),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.open_in_new,
        size: isDesktop ? 24 : (isTablet ? 22 : 20),
        color: Colors.grey,
      ),
      onTap: () => RSSService().abrirLinkExterno(item.link),
    );
  }
}
