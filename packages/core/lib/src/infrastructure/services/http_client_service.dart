import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// HTTP client service otimizado usando Dio
/// 
/// Fornece funcionalidades avançadas como:
/// - Interceptors para auth, logging, retry
/// - Cache automático de requests
/// - Timeout configurável
/// - Error handling padronizado
/// - Request/Response transformations
class HttpClientService {
  static const int _defaultConnectTimeout = 30000; // 30s
  static const int _defaultReceiveTimeout = 30000; // 30s
  static const int _defaultSendTimeout = 30000; // 30s

  late final Dio _dio;

  /// Construtor principal do HttpClientService
  HttpClientService({
    String? baseUrl,
    Map<String, dynamic>? headers,
    int connectTimeout = _defaultConnectTimeout,
    int receiveTimeout = _defaultReceiveTimeout,
    int sendTimeout = _defaultSendTimeout,
    bool enableCache = true,
    bool enableRetry = true,
    bool enableLogging = true,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        sendTimeout: Duration(milliseconds: sendTimeout),
        responseType: ResponseType.json,
      ),
    );

    _setupInterceptors(
      enableCache: enableCache,
      enableRetry: enableRetry,
      enableLogging: enableLogging,
    );
  }

  void _setupInterceptors({
    required bool enableCache,
    required bool enableRetry,
    required bool enableLogging,
  }) {
    _dio.interceptors.add(_AuthInterceptor());
    if (enableCache) {
      _dio.interceptors.add(_CacheInterceptor());
    }
    if (enableRetry) {
      _dio.interceptors.add(_RetryInterceptor());
    }
    if (enableLogging && kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
    _dio.interceptors.add(_ErrorHandlerInterceptor());
  }

  /// GET request
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final data = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(data);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// POST request
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// PUT request
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// DELETE request
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// PATCH request
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      final result = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// Download file
  Future<Result<String>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );

      return Result.success(savePath);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// Upload file
  Future<Result<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? transformer,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );

      final result = transformer != null 
          ? transformer(response.data)
          : response.data as T;

      return Result.success(result);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  /// Adicionar interceptor customizado
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Remover interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// Atualizar token de autenticação
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Limpar token de autenticação
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Obter instância Dio para casos especiais
  Dio get dio => _dio;

  AppError _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkError(
            message: 'Timeout - Verifique sua conexão',
            code: 'TIMEOUT',
            details: error.message,
            severity: ErrorSeverity.medium,
          );
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          final message = _getErrorMessage(statusCode, error.response?.data);
          return ExternalServiceError(
            message: message,
            code: 'HTTP_$statusCode',
            details: error.message,
            statusCode: statusCode,
            severity: _getSeverityFromStatusCode(statusCode),
          );
        
        case DioExceptionType.cancel:
          return NetworkError(
            message: 'Requisição cancelada',
            code: 'CANCELLED',
            details: error.message,
            severity: ErrorSeverity.low,
          );
        
        case DioExceptionType.connectionError:
          return NetworkError(
            message: 'Erro de conexão - Verifique sua internet',
            code: 'CONNECTION_ERROR',
            details: error.message,
            severity: ErrorSeverity.high,
          );
        
        case DioExceptionType.unknown:
          return NetworkError(
            message: 'Erro desconhecido: ${error.message}',
            code: 'UNKNOWN',
            details: error.message,
            severity: ErrorSeverity.medium,
          );
        
        default:
          return NetworkError(
            message: 'Erro na requisição: ${error.message}',
            code: 'REQUEST_ERROR',
            details: error.message,
            severity: ErrorSeverity.medium,
          );
      }
    }

    return UnknownError(
      message: 'Erro inesperado: ${error.toString()}',
      code: 'UNEXPECTED',
      originalError: error,
      severity: ErrorSeverity.high,
    );
  }

  ErrorSeverity _getSeverityFromStatusCode(int statusCode) {
    if (statusCode >= 500) return ErrorSeverity.high;
    if (statusCode >= 400) return ErrorSeverity.medium;
    return ErrorSeverity.low;
  }

  String _getErrorMessage(int statusCode, dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? 
                     data['error'] ?? 
                     data['detail'] ?? 
                     data['msg'];
      if (message != null) return message.toString();
    }
    switch (statusCode) {
      case 400: return 'Requisição inválida';
      case 401: return 'Não autorizado - Faça login novamente';
      case 403: return 'Acesso negado';
      case 404: return 'Recurso não encontrado';
      case 422: return 'Dados inválidos';
      case 500: return 'Erro interno do servidor';
      case 502: return 'Servidor indisponível';
      case 503: return 'Serviço temporariamente indisponível';
      default: return 'Erro HTTP: $statusCode';
    }
  }
}

/// Interceptor para adicionar token de auth automaticamente
class _AuthInterceptor extends Interceptor {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }
}

/// Interceptor para cache de responses
class _CacheInterceptor extends Interceptor {
  final Map<String, CacheItem> _cache = {};
  static const int _maxCacheAge = 300; // 5 minutos

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final key = _getCacheKey(options);
    final cached = _cache[key];

    if (cached != null && !cached.isExpired) {
      handler.resolve(Response<dynamic>(
        requestOptions: options,
        data: cached.data,
        statusCode: 200,
        headers: Headers.fromMap({'X-Cache': ['HIT']}),
      ));
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200 && 
        response.requestOptions.method.toUpperCase() == 'GET') {
      final key = _getCacheKey(response.requestOptions);
      _cache[key] = CacheItem(response.data);
      _cleanExpiredCache();
    }

    handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  void _cleanExpiredCache() {
    _cache.removeWhere((key, value) => value.isExpired);
  }
}

/// Interceptor para retry automático
class _RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const int _retryDelay = 1000; // 1 segundo

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if ((retryCount as int) < _maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      await Future<void>.delayed(Duration(milliseconds: _retryDelay * (retryCount + 1)));
      
      try {
        final response = await Dio().request<dynamic>(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: err.requestOptions.extra,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );
        
        handler.resolve(response);
        return;
      } catch (e) {
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            [500, 502, 503, 504].contains(err.response?.statusCode));
  }
}

/// Interceptor para tratamento de erros
class _ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('HTTP Error: ${err.message}');
    debugPrint('URL: ${err.requestOptions.uri}');
    debugPrint('Status: ${err.response?.statusCode}');
    debugPrint('Data: ${err.response?.data}');
    
    handler.next(err);
  }
}

/// Item de cache com timestamp para expiração
class CacheItem {
  /// Dados armazenados no cache
  final dynamic data;
  
  /// Timestamp de criação do item
  final DateTime timestamp;

  /// Construtor do item de cache
  CacheItem(this.data) : timestamp = DateTime.now();

  /// Verifica se o item de cache expirou
  bool get isExpired {
    return DateTime.now().difference(timestamp).inSeconds > _CacheInterceptor._maxCacheAge;
  }
}
