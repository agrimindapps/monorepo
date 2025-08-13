/// Configuração de espaços padrão
///
/// Este arquivo contém as configurações dos espaços que são criados
/// automaticamente quando o usuário não possui nenhum espaço cadastrado.
///
/// As strings são internacionalizadas usando o sistema de traduções do GetX.
/// Os valores podem ser customizados via SharedPreferences ou configuração remota.
class DefaultSpacesConfig {
  /// Lista de espaços padrão com suas chaves de tradução
  static const List<DefaultSpaceConfiguration> defaultSpaces = [
    DefaultSpaceConfiguration(
      nameKey: 'espacos.padrao.sala_estar.nome',
      descriptionKey: 'espacos.padrao.sala_estar.descricao',
      isActive: true,
      order: 1,
    ),
    DefaultSpaceConfiguration(
      nameKey: 'espacos.padrao.quarto.nome',
      descriptionKey: 'espacos.padrao.quarto.descricao',
      isActive: true,
      order: 2,
    ),
    DefaultSpaceConfiguration(
      nameKey: 'espacos.padrao.cozinha.nome',
      descriptionKey: 'espacos.padrao.cozinha.descricao',
      isActive: true,
      order: 3,
    ),
    DefaultSpaceConfiguration(
      nameKey: 'espacos.padrao.varanda.nome',
      descriptionKey: 'espacos.padrao.varanda.descricao',
      isActive: true,
      order: 4,
    ),
    DefaultSpaceConfiguration(
      nameKey: 'espacos.padrao.jardim.nome',
      descriptionKey: 'espacos.padrao.jardim.descricao',
      isActive: true,
      order: 5,
    ),
  ];

  /// Chaves para configuração de customização via SharedPreferences
  static const String enabledSpacesKey = 'default_spaces_enabled';
  static const String customSpacesKey = 'custom_default_spaces';
  static const String useRemoteConfigKey = 'use_remote_default_spaces';

  /// Valores padrão para configurações
  static const List<String> defaultEnabledSpaces = [
    'espacos.padrao.sala_estar.nome',
    'espacos.padrao.quarto.nome',
    'espacos.padrao.cozinha.nome',
    'espacos.padrao.varanda.nome',
    'espacos.padrao.jardim.nome',
  ];
}

/// Configuração de um espaço padrão
class DefaultSpaceConfiguration {
  /// Chave de tradução para o nome do espaço
  final String nameKey;

  /// Chave de tradução para a descrição do espaço
  final String descriptionKey;

  /// Se o espaço deve ser criado por padrão
  final bool isActive;

  /// Ordem de criação dos espaços
  final int order;

  const DefaultSpaceConfiguration({
    required this.nameKey,
    required this.descriptionKey,
    required this.isActive,
    required this.order,
  });

  /// Converte para Map para armazenamento
  Map<String, dynamic> toJson() {
    return {
      'nameKey': nameKey,
      'descriptionKey': descriptionKey,
      'isActive': isActive,
      'order': order,
    };
  }

  /// Cria instância a partir de Map
  factory DefaultSpaceConfiguration.fromJson(Map<String, dynamic> json) {
    return DefaultSpaceConfiguration(
      nameKey: json['nameKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefaultSpaceConfiguration &&
        other.nameKey == nameKey &&
        other.descriptionKey == descriptionKey &&
        other.isActive == isActive &&
        other.order == order;
  }

  @override
  int get hashCode {
    return nameKey.hashCode ^
        descriptionKey.hashCode ^
        isActive.hashCode ^
        order.hashCode;
  }

  @override
  String toString() {
    return 'DefaultSpaceConfiguration(nameKey: $nameKey, descriptionKey: $descriptionKey, isActive: $isActive, order: $order)';
  }
}
