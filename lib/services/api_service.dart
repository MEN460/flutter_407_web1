import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/utils/logger.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 3000),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: ApiEndpoints.jwtStorageKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  void _onError(DioException err, ErrorInterceptorHandler handler) {
    _handleError(err);
    return handler.next(err);
  }

  void _handleError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    final path = e.requestOptions.path;

    String errorMessage = 'API Error: ${e.message}';
    if (statusCode != null) {
      errorMessage += ' | Status: $statusCode';
    }
    if (data is Map<String, dynamic>) {
      errorMessage += ' | Message: ${data['message'] ?? data['error']}';
    }

    Logger.logError(errorMessage);

    // Handle specific status codes
    switch (statusCode) {
      case 401:
        // Token expired or invalid - trigger logout
        _storage.delete(key: 'jwt');
        break;
      case 403:
        // Forbidden - insufficient permissions
        Logger.logWarning('Access denied to $path');
        break;
      case 429:
        // Rate limited
        Logger.logWarning('Rate limit exceeded');
        break;
      case 500:
        Logger.logError('Server error: $data');
        break;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(String path, {Object? data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> patch(String path, {Object? data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(String path, {Object? data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  // Add file upload support
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(path, data: formData);
    } on DioException {
      rethrow;
    }
  }
}
