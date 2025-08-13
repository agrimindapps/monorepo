class SobreModel {
  final String appName;
  final String appVersion;
  final String appEmailContato;
  final String logoPath;
  final String copyright;
  final String rightsReserved;

  const SobreModel({
    this.appName = '',
    this.appVersion = '',
    this.appEmailContato = '',
    this.logoPath = 'lib/core/assets/logo_menu.png',
    this.copyright = 'Copyright @ Agrimind',
    this.rightsReserved = 'Todos os Direitos Reservados',
  });

  SobreModel copyWith({
    String? appName,
    String? appVersion,
    String? appEmailContato,
    String? logoPath,
    String? copyright,
    String? rightsReserved,
  }) {
    return SobreModel(
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      appEmailContato: appEmailContato ?? this.appEmailContato,
      logoPath: logoPath ?? this.logoPath,
      copyright: copyright ?? this.copyright,
      rightsReserved: rightsReserved ?? this.rightsReserved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SobreModel &&
        other.appName == appName &&
        other.appVersion == appVersion &&
        other.appEmailContato == appEmailContato &&
        other.logoPath == logoPath &&
        other.copyright == copyright &&
        other.rightsReserved == rightsReserved;
  }

  @override
  int get hashCode {
    return appName.hashCode ^
        appVersion.hashCode ^
        appEmailContato.hashCode ^
        logoPath.hashCode ^
        copyright.hashCode ^
        rightsReserved.hashCode;
  }
}

class ContatoModel {
  final String titulo;
  final String url;
  final String path;
  final String iconType;

  const ContatoModel({
    required this.titulo,
    required this.url,
    required this.path,
    required this.iconType,
  });

  ContatoModel copyWith({
    String? titulo,
    String? url,
    String? path,
    String? iconType,
  }) {
    return ContatoModel(
      titulo: titulo ?? this.titulo,
      url: url ?? this.url,
      path: path ?? this.path,
      iconType: iconType ?? this.iconType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContatoModel &&
        other.titulo == titulo &&
        other.url == url &&
        other.path == path &&
        other.iconType == iconType;
  }

  @override
  int get hashCode {
    return titulo.hashCode ^ url.hashCode ^ path.hashCode ^ iconType.hashCode;
  }
}