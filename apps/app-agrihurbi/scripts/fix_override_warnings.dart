import 'dart:io';

void main() {
  final modelFiles = [
    'lib/features/news/data/models/commodity_price_model.dart',
    'lib/features/news/data/models/news_article_model.dart',
    'lib/features/settings/data/models/settings_model.dart'
  ];

  for (var filePath in modelFiles) {
    final file = File(filePath);
    var content = file.readAsStringSync();
    content = content.replaceAllMapped(
      RegExp(r'(@override\s+)?(@HiveField\(\d+\)\s+)?final\s+(\w+)\s+(\w+);'),
      (match) {
        final type = match.group(3);
        final name = match.group(4);
        return '// REMOVED DUPLICATE FIELD: $type $name;';
      },
    );

    file.writeAsStringSync(content);
    print('Processed: $filePath');
  }
}
