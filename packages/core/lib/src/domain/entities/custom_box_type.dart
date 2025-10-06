/// Tipo de box customizada para inspeção
class CustomBoxType {
  const CustomBoxType({
    required this.key,
    required this.displayName,
    this.description,
    this.module,
    this.isCustom = true,
  });

  /// Chave única da box
  final String key;
  
  /// Nome para exibição na interface
  final String displayName;
  
  /// Descrição opcional da box
  final String? description;
  
  /// Módulo ao qual pertence
  final String? module;
  
  /// Se é uma box customizada (padrão: true)
  final bool isCustom;

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'displayName': displayName,
      'description': description,
      'module': module,
      'isCustom': isCustom,
    };
  }

  /// Cria CustomBoxType a partir de Map
  factory CustomBoxType.fromJson(Map<String, dynamic> json) {
    return CustomBoxType(
      key: json['key'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      module: json['module'] as String?,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  /// Cria uma cópia com modificações
  CustomBoxType copyWith({
    String? key,
    String? displayName,
    String? description,
    String? module,
    bool? isCustom,
  }) {
    return CustomBoxType(
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      module: module ?? this.module,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  String toString() {
    return 'CustomBoxType(key: $key, displayName: $displayName, module: $module)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomBoxType &&
        other.key == key &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(key, displayName);
}
