import 'package:dio/dio.dart';
import 'package:core/core.dart';

/// Auth interceptor to add authorization headers
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Implement logic to add authorization headers
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Implement logic for 401 Unauthorized
    }
    super.onError(err, handler);
  }
}
