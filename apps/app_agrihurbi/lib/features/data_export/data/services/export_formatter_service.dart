import 'dart:convert';
import '../../domain/entities/export_data.dart';
import '../../domain/entities/export_request.dart';

abstract class ExportFormatterService {
  String formatExportData(ExportData data, ExportFormat format);
}

class ExportFormatterServiceImpl implements ExportFormatterService {
  @override
  String formatExportData(ExportData data, ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return _formatAsJson(data);
      case ExportFormat.csv:
        return _formatAsCsv(data);
    }
  }

  String _formatAsJson(ExportData data) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data.toJson());
  }

  String _formatAsCsv(ExportData data) {
    final buffer = StringBuffer();

    // Cabeçalho de metadados
    buffer.writeln('# LGPD Data Export');
    buffer.writeln('# Export Date: ${data.metadata.exportDate.toIso8601String()}');
    buffer.writeln('# App Version: ${data.metadata.appVersion}');
    buffer.writeln('# Total Records: ${data.metadata.totalRecords}');
    buffer.writeln('');

    // Dados do perfil do usuário
    if (data.userProfile != null) {
      buffer.writeln('## User Profile');
      buffer.writeln('Field,Value');
      buffer.writeln('Name,"${_escapeCsv(data.userProfile!.name ?? '')}"');
      buffer.writeln('Email,"${_escapeCsv(data.userProfile!.email ?? '')}"');
      buffer.writeln('Created At,${data.userProfile!.createdAt?.toIso8601String() ?? ''}');
      buffer.writeln('Last Login At,${data.userProfile!.lastLoginAt?.toIso8601String() ?? ''}');
      buffer.writeln('');
    }

    // Favoritos
    if (data.favorites.isNotEmpty) {
      buffer.writeln('## Favorites');
      buffer.writeln('Product ID,Product Name,Category,Created At');
      for (final favorite in data.favorites) {
        buffer.writeln(
          '${favorite.productId},'
          '"${_escapeCsv(favorite.productName)}",'
          '"${_escapeCsv(favorite.category ?? '')}",'
          '${favorite.createdAt.toIso8601String()}',
        );
      }
      buffer.writeln('');
    }

    // Comentários
    if (data.comments.isNotEmpty) {
      buffer.writeln('## Comments');
      buffer.writeln('Comment ID,Product ID,Content,Rating,Created At,Updated At');
      for (final comment in data.comments) {
        buffer.writeln(
          '${comment.id},'
          '${comment.productId},'
          '"${_escapeCsv(comment.content)}",'
          '${comment.rating ?? ''},'
          '${comment.createdAt.toIso8601String()},'
          '${comment.updatedAt?.toIso8601String() ?? ''}',
        );
      }
      buffer.writeln('');
    }

    // Preferências
    if (data.preferences != null) {
      buffer.writeln('## Preferences');
      buffer.writeln('Setting,Value');
      buffer.writeln('Language,"${_escapeCsv(data.preferences!.language ?? '')}"');
      buffer.writeln('Theme,"${_escapeCsv(data.preferences!.theme ?? '')}"');
      buffer.writeln('Notifications Enabled,${data.preferences!.notificationsEnabled}');

      // Configurações personalizadas
      for (final entry in data.preferences!.settings.entries) {
        buffer.writeln('${entry.key},"${_escapeCsv(entry.value.toString())}"');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains('"')) {
      return value.replaceAll('"', '""');
    }
    return value;
  }
}