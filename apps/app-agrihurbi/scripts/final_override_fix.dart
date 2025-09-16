import 'dart:io';

void main() {
  final files = [
    'lib/features/settings/data/models/settings_model.dart',
    'lib/features/news/data/models/commodity_price_model.dart',
    'lib/features/news/data/models/news_article_model.dart'
  ];

  for (var filePath in files) {
    final file = File(filePath);
    var content = file.readAsStringSync();

    // Remover @override em campos que já têm @HiveField
    content = content.replaceAllMapped(
      RegExp(r'(@override\s+)(@HiveField\(\d+\))'),
      (match) => match.group(2)!,
    );

    // Remover campos comentados com "REMOVED DUPLICATE FIELD"
    content = content.replaceAll(
      RegExp(r'^.*REMOVED DUPLICATE FIELD:.*$\n', multiLine: true),
      '',
    );

    file.writeAsStringSync(content);
    print('Processed: $filePath');
  }
}