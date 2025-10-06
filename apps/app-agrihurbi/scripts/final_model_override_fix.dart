import 'dart:io';

void main() {
  final fixes = {
    'lib/features/news/data/models/commodity_price_model.dart': [
      (String line) => line.replaceAll('final List<HistoricalPriceModel> history;', '// Removed duplicated field'),
      (String line) => line.replaceAll('final List<CommodityPriceModel> topGainers;', '// Removed duplicated field'),
      (String line) => line.replaceAll('final List<CommodityPriceModel> topLosers;', '// Removed duplicated field')
    ],
    'lib/features/news/data/models/news_article_model.dart': [
      (String line) => line.replaceAll('final List<String> tags;', '// Removed duplicated field')
    ],
    'lib/features/settings/data/models/settings_model.dart': [
      (String line) => line.replaceAll('final String? lastBackupDate;', '// Removed duplicated field')
    ]
  };

  for (var entry in fixes.entries) {
    final filePath = entry.key;
    final transformations = entry.value;

    final file = File(filePath);
    var lines = file.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      for (var transform in transformations) {
        lines[i] = transform(lines[i]);
      }
    }

    file.writeAsStringSync(lines.join('\n'));
    print('Processed: $filePath');
  }
}
