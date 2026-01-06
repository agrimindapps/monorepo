import 'package:equatable/equatable.dart';

/// Configuração do AdSense para Flutter Web
/// Contém todas as configurações necessárias para AdSense
class AdSenseConfigEntity extends Equatable {
  /// Client ID do AdSense (ca-pub-XXXXXXXXXXXXXXXX)
  final String clientId;

  /// Map de ad slots por posição/nome
  /// Exemplo: {'banner_top': '1234567890', 'banner_bottom': '0987654321'}
  final Map<String, String> adSlots;

  /// Modo de teste (exibe ads de teste)
  final bool testMode;

  /// Formato de anúncio preferido
  final AdSenseFormat defaultFormat;

  /// Se deve ser responsivo por padrão
  final bool fullWidthResponsive;

  /// Ambiente (development, staging, production)
  final String? environment;

  const AdSenseConfigEntity({
    required this.clientId,
    required this.adSlots,
    this.testMode = false,
    this.defaultFormat = AdSenseFormat.auto,
    this.fullWidthResponsive = true,
    this.environment,
  });

  /// Cria configuração de desenvolvimento (com ads de teste)
  factory AdSenseConfigEntity.development({
    required String clientId,
    Map<String, String>? testSlots,
  }) {
    return AdSenseConfigEntity(
      clientId: clientId,
      adSlots: testSlots ?? const {},
      testMode: true,
      defaultFormat: AdSenseFormat.auto,
      fullWidthResponsive: true,
      environment: 'development',
    );
  }

  /// Cria configuração de produção
  factory AdSenseConfigEntity.production({
    required String clientId,
    required Map<String, String> adSlots,
  }) {
    return AdSenseConfigEntity(
      clientId: clientId,
      adSlots: adSlots,
      testMode: false,
      defaultFormat: AdSenseFormat.auto,
      fullWidthResponsive: true,
      environment: 'production',
    );
  }

  /// Obtém um ad slot por nome/posição
  String? getAdSlot(String name) => adSlots[name];

  /// Verifica se um ad slot existe
  bool hasAdSlot(String name) =>
      adSlots.containsKey(name) && adSlots[name]!.isNotEmpty;

  AdSenseConfigEntity copyWith({
    String? clientId,
    Map<String, String>? adSlots,
    bool? testMode,
    AdSenseFormat? defaultFormat,
    bool? fullWidthResponsive,
    String? environment,
  }) {
    return AdSenseConfigEntity(
      clientId: clientId ?? this.clientId,
      adSlots: adSlots ?? this.adSlots,
      testMode: testMode ?? this.testMode,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      fullWidthResponsive: fullWidthResponsive ?? this.fullWidthResponsive,
      environment: environment ?? this.environment,
    );
  }

  @override
  List<Object?> get props => [
        clientId,
        adSlots,
        testMode,
        defaultFormat,
        fullWidthResponsive,
        environment,
      ];

  @override
  String toString() => 'AdSenseConfigEntity('
      'clientId: $clientId, '
      'testMode: $testMode, '
      'environment: $environment, '
      'slots: ${adSlots.length})';
}

/// Formatos de anúncio AdSense suportados
enum AdSenseFormat {
  /// Auto-detecção do melhor formato
  auto('auto'),

  /// Banner horizontal
  horizontal('horizontal'),

  /// Banner vertical
  vertical('vertical'),

  /// Retângulo
  rectangle('rectangle'),

  /// In-article (para conteúdo entre parágrafos)
  inArticle('fluid'),

  /// In-feed (para listagens)
  inFeed('fluid');

  final String value;
  const AdSenseFormat(this.value);
}

/// Tamanhos pré-definidos para AdSense banners
class AdSenseSize {
  final int width;
  final int height;
  final String name;

  const AdSenseSize._({
    required this.width,
    required this.height,
    required this.name,
  });

  /// Banner padrão 320x50
  static const banner = AdSenseSize._(width: 320, height: 50, name: 'banner');

  /// Large banner 320x100
  static const largeBanner =
      AdSenseSize._(width: 320, height: 100, name: 'largeBanner');

  /// Medium rectangle 300x250
  static const mediumRectangle =
      AdSenseSize._(width: 300, height: 250, name: 'mediumRectangle');

  /// Full banner 468x60
  static const fullBanner =
      AdSenseSize._(width: 468, height: 60, name: 'fullBanner');

  /// Leaderboard 728x90
  static const leaderboard =
      AdSenseSize._(width: 728, height: 90, name: 'leaderboard');

  /// Wide skyscraper 160x600
  static const wideSkyscraper =
      AdSenseSize._(width: 160, height: 600, name: 'wideSkyscraper');

  /// Responsivo (adapta ao container)
  static const responsive =
      AdSenseSize._(width: 0, height: 0, name: 'responsive');

  /// Cria tamanho customizado
  factory AdSenseSize.custom({
    required int width,
    required int height,
  }) {
    return AdSenseSize._(width: width, height: height, name: 'custom');
  }

  bool get isResponsive => width == 0 && height == 0;

  @override
  String toString() => 'AdSenseSize($name: ${width}x$height)';
}
