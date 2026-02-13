import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/errors/exceptions.dart';


class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  ApiClient(this._dio, this._storage) {
    _init();
  }
  
  void _init() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    };
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
        onResponse: _onResponse,
      ),
    );
  }
  
  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: ApiConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {
      try {
        await _refreshToken();
        handler.resolve(await _retry(error.requestOptions));
      } catch (e) {
        handler.next(error);
      }
    } else {
      handler.next(error);
    }
  }
  
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
  
  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: ApiConstants.refreshTokenKey);
    if (refreshToken != null) {
      try {
        final response = await _dio.post(
          ApiConstants.refreshTokenEndpoint,
          data: {'refreshToken': refreshToken},
        );
        await _storage.write(
          key: ApiConstants.accessTokenKey,
          value: response.data['accessToken'],
        );
      } catch (e) {
        await _storage.deleteAll();
        throw UnauthorizedException();
      }
    } else {
      throw UnauthorizedException();
    }
  }
  
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  // HTTP Methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('اتصال الإنترنت ضعيف');
      case DioExceptionType.connectionError:
        return NetworkException('لا يوجد اتصال بالإنترنت');
      case DioExceptionType.badResponse:
        final message = error.response?.data['message'] ?? 'حدث خطأ في الخادم';
        final code = error.response?.statusCode;
        
        if (code == 401) return UnauthorizedException(message);
        if (code == 403) return KyanException('غير مصرح لك بهذا الإجراء');
        if (code == 404) return KyanException('المورد غير موجود');
        if (code == 422) {
          final errors = error.response?.data['errors'] as Map? ?? {};
          return ValidationException(errors.map((k, v) => MapEntry(k, v.toString())));
        }
        if (code == 500) return ServerException('خطأ داخلي في الخادم');
        
        return ServerException(message, code: code);
      default:
        return ServerException('حدث خطأ غير متوقع');
    }
  }
}