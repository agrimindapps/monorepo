import 'package:share_plus/share_plus.dart';
import 'package:core/core.dart';

/// Service for sharing lists and items
/// Uses share_plus package from core
class ShareService {
  /// Share list details as formatted text
  ///
  /// [listName] - Name of the list
  /// [description] - Optional list description
  /// [totalItems] - Total number of items in the list
  /// [completedItems] - Number of completed items
  /// [itemNames] - Optional list of item names to include
  Future<void> shareList({
    required String listName,
    required String description,
    required int totalItems,
    required int completedItems,
    List<String>? itemNames,
  }) async {
    final text = _buildListShareText(
      listName: listName,
      description: description,
      totalItems: totalItems,
      completedItems: completedItems,
      itemNames: itemNames,
    );

    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Share a single item details
  ///
  /// [itemName] - Name of the item
  /// [description] - Optional item description
  /// [category] - Item category
  /// [estimatedPrice] - Optional estimated price
  /// [preferredBrand] - Optional preferred brand
  Future<void> shareItem({
    required String itemName,
    String? description,
    String? category,
    double? estimatedPrice,
    String? preferredBrand,
  }) async {
    final text = _buildItemShareText(
      itemName: itemName,
      description: description,
      category: category,
      estimatedPrice: estimatedPrice,
      preferredBrand: preferredBrand,
    );

    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Share multiple lists summary
  Future<void> shareListsSummary({
    required int totalLists,
    required int favoriteCount,
    required int totalItems,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('📊 *Resumo NebulaList*\n');
    buffer.writeln('📋 $totalLists listas');
    buffer.writeln('⭐ $favoriteCount favoritas');
    buffer.writeln('📦 $totalItems itens no total\n');
    buffer.writeln('---');
    buffer.writeln('Compartilhado via NebulaList');

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  /// Build formatted text for list sharing
  String _buildListShareText({
    required String listName,
    required String description,
    required int totalItems,
    required int completedItems,
    List<String>? itemNames,
  }) {
    final buffer = StringBuffer();

    // Title
    buffer.writeln('📋 *$listName*\n');

    // Description
    if (description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }

    // Progress
    buffer.writeln('✅ Progresso: $completedItems/$totalItems itens');
    final percentage = totalItems > 0
        ? ((completedItems / totalItems) * 100).toStringAsFixed(0)
        : '0';
    buffer.writeln('📊 $percentage% concluído\n');

    // Items list
    if (itemNames != null && itemNames.isNotEmpty) {
      buffer.writeln('📝 Itens:');
      for (var i = 0; i < itemNames.length; i++) {
        final item = itemNames[i];
        // Mark first N items as completed based on completedItems count
        final checkbox = i < completedItems ? '✅' : '⬜';
        buffer.writeln('  $checkbox $item');
      }
      buffer.writeln();
    }

    // Footer
    buffer.writeln('---');
    buffer.writeln('Compartilhado via NebulaList');

    return buffer.toString();
  }

  /// Build formatted text for item sharing
  String _buildItemShareText({
    required String itemName,
    String? description,
    String? category,
    double? estimatedPrice,
    String? preferredBrand,
  }) {
    final buffer = StringBuffer();

    // Title
    buffer.writeln('📦 *$itemName*\n');

    // Description
    if (description != null && description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }

    // Category
    if (category != null && category.isNotEmpty) {
      buffer.writeln('🏷️ Categoria: $category');
    }

    // Price
    if (estimatedPrice != null && estimatedPrice > 0) {
      buffer.writeln(
        '💰 Preço estimado: R\$ ${estimatedPrice.toStringAsFixed(2)}',
      );
    }

    // Brand
    if (preferredBrand != null && preferredBrand.isNotEmpty) {
      buffer.writeln('⭐ Marca preferida: $preferredBrand');
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Compartilhado via NebulaList');

    return buffer.toString();
  }
}
