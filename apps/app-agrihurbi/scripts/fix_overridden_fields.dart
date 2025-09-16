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

    // Remover @override antes de @HiveField
    content = content.replaceAll(r'@override\s*@HiveField', '@HiveField');

    // Adicionar @override em campos que sobrescrevem entidades base
    content = content.replaceAllMapped(
      RegExp(r'(final\s+\w+\s+\w+;)'),
      (match) => '@override\n${match.group(1)}',
    );

    file.writeAsStringSync(content);
    print('Processed: $filePath');
  }
}