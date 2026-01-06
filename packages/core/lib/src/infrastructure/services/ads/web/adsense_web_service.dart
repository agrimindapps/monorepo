// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:dartz/dartz.dart';
import 'package:web/web.dart' as web;

import '../../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../../domain/repositories/i_web_ads_repository.dart';
import '../../../../shared/utils/failure.dart';

/// Implementação do AdSense Service para Flutter Web
/// Usa HtmlElementView para injetar scripts AdSense no Flutter
///
/// IMPORTANTE: Este arquivo só pode ser importado em builds web!
/// Use importação condicional para separar mobile de web.
class AdSenseWebService implements IWebAdsRepository {
  AdSenseConfigEntity? _config;
  bool _isInitialized = false;
  bool _isPremium = false;

  /// Mapa de slots registrados: slotName -> viewId
  final Map<String, String> _registeredSlots = {};

  /// Contador para gerar viewIds únicos
  int _viewIdCounter = 0;

  /// Tracking de impressões
  final Map<String, int> _impressionCounts = {};

  /// Tracking de cliques
  final Map<String, int> _clickCounts = {};

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPremium => _isPremium;

  @override
  Future<Either<Failure, void>> initialize({
    required AdSenseConfigEntity config,
  }) async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      _config = config;

      // Injeta o script global do AdSense no head do documento
      // Isso só precisa ser feito uma vez
      _injectAdSenseScript(config.clientId);

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Falha ao inicializar AdSense: ${e.toString()}',
          code: 'ADSENSE_INIT_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Injeta o script global do AdSense
  void _injectAdSenseScript(String clientId) {
    final head = web.document.head;
    if (head == null) return;

    // Verifica se o script já foi injetado
    final existingScripts = head.querySelectorAll('script[data-ad-client]');
    if (existingScripts.length > 0) {
      return; // Script já existe
    }

    // Cria e injeta o script do AdSense
    final script = web.document.createElement('script') as web.HTMLScriptElement
      ..async = true
      ..src =
          'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=$clientId'
      ..crossOrigin = 'anonymous';

    // Adiciona atributo data-ad-client
    script.setAttribute('data-ad-client', clientId);

    head.appendChild(script);
  }

  @override
  Future<Either<Failure, String>> registerAdSlot({
    required String slotName,
    required String adSlot,
    AdSenseFormat format = AdSenseFormat.auto,
    bool fullWidthResponsive = true,
    AdSenseSize? size,
  }) async {
    if (!_isInitialized || _config == null) {
      return const Left(
        CacheFailure(
          'AdSense não inicializado. Chame initialize() primeiro.',
          code: 'ADSENSE_NOT_INITIALIZED',
        ),
      );
    }

    try {
      // Gera um viewId único
      final viewId = 'adsense-${slotName.replaceAll(' ', '-')}-${_viewIdCounter++}';

      // Registra a factory do elemento HTML
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int viewIdNumber) {
          return _createAdElement(
            clientId: _config!.clientId,
            adSlot: adSlot,
            format: format,
            fullWidthResponsive: fullWidthResponsive,
            size: size,
          );
        },
      );

      _registeredSlots[slotName] = viewId;

      return Right(viewId);
    } catch (e) {
      return Left(
        CacheFailure(
          'Falha ao registrar ad slot: ${e.toString()}',
          code: 'ADSENSE_REGISTER_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Cria o elemento HTML do anúncio AdSense
  web.HTMLDivElement _createAdElement({
    required String clientId,
    required String adSlot,
    required AdSenseFormat format,
    required bool fullWidthResponsive,
    AdSenseSize? size,
  }) {
    final container = web.document.createElement('div') as web.HTMLDivElement;
    container.style.width = '100%';
    container.style.height = '100%';
    container.style.display = 'flex';
    container.style.justifyContent = 'center';
    container.style.alignItems = 'center';

    // Constrói os atributos do anúncio
    final sizeStyle = size != null && !size.isResponsive
        ? 'width:${size.width}px;height:${size.height}px'
        : 'display:block';

    final responsiveAttr =
        fullWidthResponsive ? 'data-full-width-responsive="true"' : '';

    // O innerHTML inclui a tag ins do AdSense e o script de push
    container.innerHTML = '''
      <ins class="adsbygoogle"
           style="$sizeStyle"
           data-ad-client="$clientId"
           data-ad-slot="$adSlot"
           data-ad-format="${format.value}"
           $responsiveAttr></ins>
      <script>
           (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    '''.toJS;

    return container;
  }

  @override
  Future<Either<Failure, void>> unregisterAdSlot({
    required String slotName,
  }) async {
    _registeredSlots.remove(slotName);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> refreshAd({required String slotName}) async {
    // AdSense não suporta refresh programático diretamente
    // A recomendação é recarregar a página ou recriar o elemento
    // Para SPAs, podemos tentar um push novamente
    try {
      // Tenta fazer um novo push do AdSense (pode não funcionar sempre)
      _pushAdSense();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Falha ao atualizar anúncio: ${e.toString()}',
          code: 'ADSENSE_REFRESH_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Executa o push do AdSense para carregar novos anúncios
  void _pushAdSense() {
    // Executa JavaScript para fazer push do AdSense
    // Nota: Em package:web, usamos js_interop para chamar JS
    const script = '(adsbygoogle = window.adsbygoogle || []).push({});';
    final scriptElement =
        web.document.createElement('script') as web.HTMLScriptElement;
    scriptElement.textContent = script;
    web.document.body?.appendChild(scriptElement);
    // Remove script após execução
    scriptElement.remove();
  }

  @override
  Future<Either<Failure, bool>> shouldShowAd({
    required String placement,
  }) async {
    // Não mostra ads para usuários premium
    if (_isPremium) {
      return const Right(false);
    }

    return const Right(true);
  }

  @override
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  @override
  Future<Either<Failure, void>> recordAdShown({
    required String placement,
  }) async {
    _impressionCounts[placement] = (_impressionCounts[placement] ?? 0) + 1;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> recordAdClicked({
    required String placement,
  }) async {
    _clickCounts[placement] = (_clickCounts[placement] ?? 0) + 1;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    _registeredSlots.clear();
    _impressionCounts.clear();
    _clickCounts.clear();
    _isInitialized = false;
    _config = null;
    return const Right(null);
  }

  /// Obtém estatísticas do serviço
  Map<String, dynamic> getStatistics() {
    return {
      'initialized': _isInitialized,
      'isPremium': _isPremium,
      'registeredSlots': Map<String, String>.from(_registeredSlots),
      'impressionCounts': Map<String, int>.from(_impressionCounts),
      'clickCounts': Map<String, int>.from(_clickCounts),
      'config': _config?.toString(),
    };
  }

  /// Obtém o viewId de um slot registrado
  String? getViewId(String slotName) => _registeredSlots[slotName];
}
