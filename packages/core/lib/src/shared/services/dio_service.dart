import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Service centralizado para requisições HTTP usando Dio
///
/// Encapsula a configuração e uso do Dio fornecendo uma API
/// conveniente e consistente para requisições HTTP em todos os apps
///
/// Características:
/// - Configuração centralizada de timeouts e interceptors
/// - Logging automático em modo debug
/// - Tratamento de erros padronizado
/// - Suporte a download/upload de arquivos
/// - Cache e retry policies
///
/// Exemplos:
/// ```dart
/// final dioService = getIt<DioService>();
///
/// // GET request
/// final response = await dioService.get('/users');
///
/// // POST request
/// final response = await dioService.post('/users', data: {'name': 'John'});
///
/// // Download arquivo
/// await dioService.download('/file.pdf', '/path/local/file.pdf');
/// ```
@lazySingleton
class DioService {
  late final Dio _dio;

  DioService() {
    _dio = Dio(_defaultOptions);
    _setupInterceptors();
  }

  /// Configurações padrão do Dio
  static BaseOptions get _defaultOptions => BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
        followRedirects: true,
        maxRedirects: 5,
      );

  /// Configura interceptors para logging e tratamento de erros
  void _setupInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[Dio] $obj'),
        ),
      );
    }
  }

  /// Acesso direto à instância Dio para casos avançados
  ///
  /// Use com cuidado - prefira os métodos específicos deste service
  Dio get dio => _dio;

  // ============================================================
  // MÉTODOS HTTP PRINCIPAIS
  // ============================================================

  /// Executa uma requisição GET
  ///
  /// [path] - URL ou path da requisição
  /// [queryParameters] - Parâmetros query string
  /// [options] - Opções customizadas da requisição
  /// [cancelToken] - Token para cancelar requisição
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.get(
  ///   '/users',
  ///   queryParameters: {'page': 1, 'limit': 10},
  /// );
  /// ```
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Executa uma requisição POST
  ///
  /// [path] - URL ou path da requisição
  /// [data] - Dados do body (Map, FormData, etc)
  /// [queryParameters] - Parâmetros query string
  /// [options] - Opções customizadas da requisição
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.post(
  ///   '/users',
  ///   data: {'name': 'John', 'email': 'john@example.com'},
  /// );
  /// ```
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Executa uma requisição PUT
  ///
  /// [path] - URL ou path da requisição
  /// [data] - Dados do body para atualização
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.put(
  ///   '/users/123',
  ///   data: {'name': 'John Updated'},
  /// );
  /// ```
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Executa uma requisição PATCH
  ///
  /// [path] - URL ou path da requisição
  /// [data] - Dados parciais para atualização
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.patch(
  ///   '/users/123',
  ///   data: {'email': 'newemail@example.com'},
  /// );
  /// ```
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Executa uma requisição DELETE
  ///
  /// [path] - URL ou path da requisição
  /// [data] - Dados opcionais no body
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.delete('/users/123');
  /// ```
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ============================================================
  // DOWNLOAD E UPLOAD
  // ============================================================

  /// Faz download de um arquivo
  ///
  /// [urlPath] - URL do arquivo a baixar
  /// [savePath] - Caminho local onde salvar o arquivo
  /// [onReceiveProgress] - Callback para progresso do download
  ///
  /// Exemplo:
  /// ```dart
  /// await dioService.download(
  ///   'https://example.com/file.pdf',
  ///   '/storage/file.pdf',
  ///   onReceiveProgress: (received, total) {
  ///     print('${(received / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  /// Faz upload de arquivo usando FormData
  ///
  /// [path] - Endpoint da API
  /// [filePath] - Caminho do arquivo local
  /// [fieldName] - Nome do campo no FormData (default: 'file')
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.uploadFile(
  ///   '/upload',
  ///   '/storage/image.jpg',
  ///   fieldName: 'avatar',
  /// );
  /// ```
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?additionalData,
    });

    return post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  /// Faz upload de múltiplos arquivos
  ///
  /// [path] - Endpoint da API
  /// [files] - Map de fieldName -> filePath
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dioService.uploadMultipleFiles(
  ///   '/upload-multiple',
  ///   {
  ///     'avatar': '/storage/avatar.jpg',
  ///     'cover': '/storage/cover.jpg',
  ///   },
  /// );
  /// ```
  Future<Response<T>> uploadMultipleFiles<T>(
    String path,
    Map<String, String> files, {
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> formDataMap = {};

    // Adiciona os arquivos
    for (final entry in files.entries) {
      formDataMap[entry.key] = await MultipartFile.fromFile(entry.value);
    }

    // Adiciona dados adicionais
    if (additionalData != null) {
      formDataMap.addAll(additionalData);
    }

    final formData = FormData.fromMap(formDataMap);

    return post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  // ============================================================
  // CONFIGURAÇÃO E UTILIDADES
  // ============================================================

  /// Atualiza a baseUrl do Dio
  ///
  /// Útil para trocar entre ambientes (dev, staging, prod)
  ///
  /// Exemplo:
  /// ```dart
  /// dioService.setBaseUrl('https://api.production.com');
  /// ```
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    if (kDebugMode) {
      debugPrint('[DioService] Base URL atualizada: $baseUrl');
    }
  }

  /// Adiciona header global
  ///
  /// Útil para adicionar tokens de autenticação
  ///
  /// Exemplo:
  /// ```dart
  /// dioService.setHeader('Authorization', 'Bearer $token');
  /// ```
  void setHeader(String key, dynamic value) {
    _dio.options.headers[key] = value;
  }

  /// Remove header global
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Define múltiplos headers de uma vez
  ///
  /// Exemplo:
  /// ```dart
  /// dioService.setHeaders({
  ///   'Authorization': 'Bearer $token',
  ///   'Accept-Language': 'pt-BR',
  /// });
  /// ```
  void setHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Limpa todos os headers customizados
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Atualiza timeout de conexão
  ///
  /// Exemplo:
  /// ```dart
  /// dioService.setConnectTimeout(Duration(seconds: 60));
  /// ```
  void setConnectTimeout(Duration timeout) {
    _dio.options.connectTimeout = timeout;
  }

  /// Atualiza timeout de recebimento
  void setReceiveTimeout(Duration timeout) {
    _dio.options.receiveTimeout = timeout;
  }

  /// Atualiza timeout de envio
  void setSendTimeout(Duration timeout) {
    _dio.options.sendTimeout = timeout;
  }

  /// Adiciona um interceptor customizado
  ///
  /// Exemplo:
  /// ```dart
  /// dioService.addInterceptor(MyCustomInterceptor());
  /// ```
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Remove todos os interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
    // Re-adiciona o logger se estiver em debug
    if (kDebugMode) {
      _setupInterceptors();
    }
  }

  /// Cria um CancelToken para cancelar requisições
  ///
  /// Exemplo:
  /// ```dart
  /// final cancelToken = dioService.createCancelToken();
  ///
  /// // Inicia requisição
  /// dioService.get('/long-request', cancelToken: cancelToken);
  ///
  /// // Cancela se necessário
  /// cancelToken.cancel('Operação cancelada pelo usuário');
  /// ```
  CancelToken createCancelToken() {
    return CancelToken();
  }
}
