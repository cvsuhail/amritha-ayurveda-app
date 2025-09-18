import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://flutter-amr.noviindus.in/api';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));
  
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });
      
      final response = await _dio.post(
        '/Login',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      final Map<String, dynamic> responseData = response.data;
      
      if (responseData['status'] == true || responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData,
          'token': responseData['token'] ?? responseData['access_token'] ?? '',
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'data': responseData,
        };
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      String errorMessage = 'Network error. Please check your internet connection.';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Login failed. Please try again.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    }
  }
  
  // Generic API call method for future use with authentication
  static Future<Map<String, dynamic>> makeAuthenticatedRequest({
    required String endpoint,
    required String method,
    required String token,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final options = Options(
        method: method.toUpperCase(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          ...?headers,
        },
      );
      
      final response = await _dio.request(
        endpoint,
        data: body,
        options: options,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      String errorMessage = 'Network error. Please check your internet connection.';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Request failed';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'data': e.response?.data,
        'statusCode': e.response?.statusCode,
        'error': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> makeRequestWithStoredToken({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
          'requiresAuth': true,
        };
      }
      
      return await makeAuthenticatedRequest(
        endpoint: endpoint,
        method: method,
        token: token,
        body: body,
        headers: headers,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    }
  }
  
  static void addInterceptors() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        if (kDebugMode && object.toString().isNotEmpty) {
          debugPrint(object.toString());
        }
      },
    ));
  }
}
