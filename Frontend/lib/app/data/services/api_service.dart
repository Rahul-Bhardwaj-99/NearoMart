import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/values/api_constants.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  Future<ApiService> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String? token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle Unauthorized - Clear storage and redirect to Auth
            _storageService.clearAll();
            Get.offAllNamed('/auth');
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    return this;
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }
}
