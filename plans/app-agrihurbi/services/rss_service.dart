// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../conts/rss_constant.dart';

class RSSService extends GetxController {
  static RSSService? _instance;

  static RSSService get instance {
    _instance ??= Get.put(RSSService._internal());
    return _instance!;
  }

  factory RSSService() => instance;

  RSSService._internal();

  late final http.Client client;
  RssFeed channel = const RssFeed();

  final RxList<ItemRSS> itemsAgricultura = <ItemRSS>[].obs;
  final RxList<ItemRSS> itemsPecuaria = <ItemRSS>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Controle de concorrência para limitar requisições simultâneas
  static const int _maxConcurrentRequests = 3;
  int _currentRequests = 0;

  // Cache para evitar requisições duplicadas
  final Map<String, List<ItemRSS>> _feedCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Debounce para evitar refresh spam
  DateTime? _lastRefreshTime;
  static const Duration _refreshCooldown = Duration(seconds: 5);

  @override
  void onInit() {
    super.onInit();
    client = http.Client();
  }

  @override
  void onClose() {
    client.close();
    super.onClose();
  }

  Future<void> carregaAgroRSS({bool forceRefresh = false}) async {
    // Debounce para evitar refresh spam
    if (!forceRefresh && _lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _refreshCooldown) {
        debugPrint(
            'Refresh agricultura bloqueado por cooldown (${timeSinceLastRefresh.inSeconds}s/${_refreshCooldown.inSeconds}s)');
        return;
      }
    }

    try {
      isLoading.value = true;
      error.value = '';
      _lastRefreshTime = DateTime.now();

      // Limpar cache expirado
      _cleanExpiredCache();

      // Carregar feeds com fallback gracioso - se alguns falharem, outros podem suceder
      final futures = linksRSSAgroConstant
          .map((feed) => _carregaRSSComRetry(
                extractHTML: feed.extractHtml,
                link: feed.url,
                channelName: feed.label,
              ))
          .toList();

      final results = await Future.wait(futures, eagerError: false);

      // Filtrar apenas resultados que não são null (sucessos)
      final validResults =
          results.where((result) => result != null).cast<List<ItemRSS>>();

      if (validResults.isEmpty) {
        throw Exception('Nenhum feed de agricultura pôde ser carregado');
      }

      List<ItemRSS> data = validResults.expand((element) => element).toList();
      data.sort((a, b) => b.getTime.compareTo(a.getTime));
      itemsAgricultura.value = data;

      // Se alguns feeds falharam, mostrar aviso
      if (validResults.length < linksRSSAgroConstant.length) {
        final failedCount = linksRSSAgroConstant.length - validResults.length;
        debugPrint('Aviso: $failedCount feed(s) de agricultura falharam');
      }
    } catch (e) {
      error.value = _getErrorMessage(e.toString(), 'agricultura');
      debugPrint('Erro ao carregar RSS agricultura: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> carregaPecuariaRSS({bool forceRefresh = false}) async {
    // Debounce para evitar refresh spam
    if (!forceRefresh && _lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _refreshCooldown) {
        debugPrint(
            'Refresh pecuária bloqueado por cooldown (${timeSinceLastRefresh.inSeconds}s/${_refreshCooldown.inSeconds}s)');
        return;
      }
    }

    try {
      isLoading.value = true;
      error.value = '';
      _lastRefreshTime = DateTime.now();

      // Limpar cache expirado
      _cleanExpiredCache();

      // Carregar feeds com fallback gracioso - se alguns falharem, outros podem suceder
      final futures = linksRSSPecuariaConstant
          .map((feed) => _carregaRSSComRetry(
                extractHTML: feed.extractHtml,
                link: feed.url,
                channelName: feed.label,
              ))
          .toList();

      final results = await Future.wait(futures, eagerError: false);

      // Filtrar apenas resultados que não são null (sucessos)
      final validResults =
          results.where((result) => result != null).cast<List<ItemRSS>>();

      if (validResults.isEmpty) {
        throw Exception('Nenhum feed de pecuária pôde ser carregado');
      }

      List<ItemRSS> data = validResults.expand((element) => element).toList();
      data.sort((a, b) => b.getTime.compareTo(a.getTime));
      itemsPecuaria.value = data;

      // Se alguns feeds falharam, mostrar aviso
      if (validResults.length < linksRSSPecuariaConstant.length) {
        final failedCount =
            linksRSSPecuariaConstant.length - validResults.length;
        debugPrint('Aviso: $failedCount feed(s) de pecuária falharam');
      }
    } catch (e) {
      error.value = _getErrorMessage(e.toString(), 'pecuária');
      debugPrint('Erro ao carregar RSS pecuária: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Método auxiliar para carregar RSS com retry automático e controle de concorrência
  Future<List<ItemRSS>?> _carregaRSSComRetry({
    required bool extractHTML,
    required String link,
    required String channelName,
    int maxRetries = 3,
  }) async {
    // Verificar cache primeiro
    if (_isCacheValid(link)) {
      debugPrint('Cache hit para $channelName');
      return _feedCache[link]!;
    }

    // Controle de concorrência - aguardar se muitas requisições simultâneas
    while (_currentRequests >= _maxConcurrentRequests) {
      debugPrint(
          'Aguardando slot disponível para $channelName ($_currentRequests/$_maxConcurrentRequests)');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _currentRequests++;
    debugPrint(
        'Iniciando carregamento de $channelName ($_currentRequests/$_maxConcurrentRequests)');

    try {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          final result = await carregaRSS(
            extractHTML: extractHTML,
            link: link,
            channelName: channelName,
          );

          // Cache do resultado
          _feedCache[link] = result;
          _cacheTimestamps[link] = DateTime.now();

          return result;
        } catch (e) {
          debugPrint(
              'Tentativa $attempt/$maxRetries falhou para $channelName: ${e.toString()}');

          if (attempt < maxRetries) {
            // Backoff exponencial: 2^attempt segundos
            final delaySeconds = (2 << (attempt - 1));
            await Future.delayed(Duration(seconds: delaySeconds));
          } else {
            // Última tentativa falhou, retornar null para fallback gracioso
            debugPrint(
                'Falha definitiva para $channelName após $maxRetries tentativas');
            return null;
          }
        }
      }
    } finally {
      _currentRequests--;
      debugPrint(
          'Finalizando carregamento de $channelName ($_currentRequests/$_maxConcurrentRequests)');
    }

    return null;
  }

  /// Verifica se o cache é válido para uma URL
  bool _isCacheValid(String url) {
    if (!_feedCache.containsKey(url) || !_cacheTimestamps.containsKey(url)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[url]!;
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheExpiration;
  }

  /// Limpa cache expirado
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _feedCache.remove(key);
      _cacheTimestamps.remove(key);
      debugPrint('Cache expirado removido para: $key');
    }
  }

  /// Método auxiliar para gerar mensagens de erro específicas
  String _getErrorMessage(String error, String tipo) {
    if (error.contains('Timeout') || error.contains('timeout')) {
      return 'Conexão lenta: Alguns feeds de $tipo demoraram para responder';
    } else if (error.contains('404') || error.contains('not found')) {
      return 'Feeds de $tipo temporariamente indisponíveis (404)';
    } else if (error.contains('403') || error.contains('denied')) {
      return 'Acesso negado aos feeds de $tipo (403)';
    } else if (error.contains('500') || error.contains('internal server')) {
      return 'Erro interno nos servidores de $tipo (500)';
    } else if (error.contains('format') || error.contains('parse')) {
      return 'Formato inválido em alguns feeds de $tipo';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Problema de conexão: Verifique sua internet e tente novamente';
    } else if (error.contains('Nenhum feed')) {
      return 'Todos os feeds de $tipo estão temporariamente indisponíveis';
    } else {
      return 'Erro ao carregar notícias de $tipo: Tente novamente em alguns minutos';
    }
  }

  Future<List<ItemRSS>> carregaRSS({
    required bool extractHTML,
    required String link,
    required String channelName,
  }) async {
    try {
      final response = await client.get(
        Uri.parse(link),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; AgrihurbiApp/1.0)',
          'Accept': 'application/rss+xml, application/xml, text/xml',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception(
            'Timeout: Feed $channelName demorou mais de 30s para responder'),
      );

      if (response.statusCode == 404) {
        throw Exception('Feed não encontrado: $channelName (404)');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado ao feed: $channelName (403)');
      } else if (response.statusCode == 500) {
        throw Exception('Erro interno do servidor: $channelName (500)');
      } else if (response.statusCode != 200) {
        throw Exception('Erro HTTP ${response.statusCode}: $channelName');
      }

      if (response.body.isEmpty) {
        throw Exception('Feed vazio: $channelName');
      }

      final channel = RssFeed.parse(response.body);

      if (channel.items.isEmpty) {
        debugPrint('Aviso: Feed $channelName não contém itens');
        return [];
      }

      return channel.items
          .map((item) => ItemRSS(
                channelName: channelName,
                title: item.title ?? 'Título não disponível',
                description: extractHTML
                    ? extrairDescHTML(item.description ?? '')
                    : (item.description ?? 'Descrição não disponível'),
                link: item.link ?? '',
                media: '',
                pubDate: item.pubDate == null ? '' : formatarData(item.pubDate),
                getTime: returnMiliseconds(item.pubDate ?? '1970-01-01'),
              ))
          .where((item) => item.title.isNotEmpty && item.link.isNotEmpty)
          .toList();
    } on FormatException catch (e) {
      debugPrint('Erro de formato XML no feed $channelName: ${e.toString()}');
      throw Exception('Feed $channelName tem formato inválido');
    } catch (e) {
      final errorMsg = 'Erro ao carregar feed $channelName: ${e.toString()}';
      debugPrint(errorMsg);
      throw Exception(errorMsg);
    }
  }

  String extrairLinkImgHTML(String htmlString) {
    try {
      final document = parse(htmlString);
      final links = document.getElementsByTagName('img');
      return links[0].attributes['src'] ?? '';
    } catch (e) {
      return '';
    }
  }

  String extrairDescHTML(String htmlString) {
    try {
      final document = parse(htmlString);
      final text = document.getElementsByTagName('p');
      return text[0].text.length > 30 ? text[0].text : text[1].text;
    } catch (e) {
      return '';
    }
  }

  String formatarData(String? data) {
    if (data == null) return '';
    try {
      final DateTime parsedDate = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  int returnMiliseconds(String? data) {
    if (data == null) return 0;
    try {
      final DateTime parsedDate = DateTime.parse(data);
      return parsedDate.millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }

  String returnMesDesc(String mes) {
    final index = Month.values.indexOf(Month.values.firstWhere(
      (m) => m.name == mes,
      orElse: () => Month.jan,
    ));
    return (index + 1).toString().padLeft(2, '0');
  }

  Future<void> abrirLinkExterno(String url) async {
    if (url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Não foi possível abrir o link: $url';
      }
    } catch (e) {
      debugPrint('Erro ao abrir link: $e');
    }
  }
}

enum Month { jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec }

class ItemRSS {
  String channelName;
  String title;
  String description;
  String link;
  String media;
  String pubDate;
  int getTime;

  ItemRSS({
    required this.channelName,
    required this.title,
    required this.description,
    required this.link,
    required this.media,
    required this.pubDate,
    required this.getTime,
  });
}
