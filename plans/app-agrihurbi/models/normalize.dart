dynamic normalize(Map<String, dynamic> data, String key) {
  switch (data[key].runtimeType) {
    case String:
      return data[key] ?? '';
    case bool:
      return data[key] ?? false;
    case int:
      return data[key] ?? 0;
    case double:
      return data[key] ?? 0.0;
    default:
      return data[key] ?? '';
  }
}
