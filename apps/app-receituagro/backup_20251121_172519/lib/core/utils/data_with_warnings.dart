/// Classe para encapsular dados com warnings de validação
class DataWithWarnings<T> {
  final T data;
  final List<String> warnings;

  const DataWithWarnings({required this.data, this.warnings = const []});

  bool get hasWarnings => warnings.isNotEmpty;

  DataWithWarnings<T> addWarning(String warning) {
    return DataWithWarnings(data: data, warnings: [...warnings, warning]);
  }

  DataWithWarnings<T> addWarnings(List<String> newWarnings) {
    return DataWithWarnings(
      data: data,
      warnings: [...warnings, ...newWarnings],
    );
  }
}
