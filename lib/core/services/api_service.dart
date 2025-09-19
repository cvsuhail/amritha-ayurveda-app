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
  
  // Initialize interceptors
  static void init() {
    addInterceptors();
  }
  
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting login with username: $username');
        print('API URL: $baseUrl/Login');
      }
      
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
      
      if (kDebugMode) {
        print('API Response status: ${response.statusCode}');
        print('API Response data: ${response.data}');
      }
      
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
      if (kDebugMode) {
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
      }
      
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
  
  // Patient List API
  static Future<Map<String, dynamic>> getPatientList() async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Fetching patient list...');
        print('API URL: $baseUrl/PatientList');
        print('Retrieved token from storage: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      }
      
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('No token found in storage, authentication required');
        }
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
          'requiresAuth': true,
        };
      }

      // Make GET request with Authorization header
      final response = await _dio.get(
        '/PatientList',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print('Patient List API Response status: ${response.statusCode}');
        print('Patient List API Response data: ${response.data}');
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == true || responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['patient'] ?? responseData['patient_list'] ?? responseData['data'] ?? [],
          'message': responseData['message'] ?? 'Patient list fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch patient list',
          'data': [],
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Patient List DioException type: ${e.type}');
        print('Patient List DioException message: ${e.message}');
        print('Patient List DioException response: ${e.response?.data}');
        print('Patient List DioException status code: ${e.response?.statusCode}');
      }

      String errorMessage = 'Network error. Please check your internet connection.';

      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Failed to fetch patient list. Please try again.';
        }
        
        // Handle unauthorized access
        if (e.response!.statusCode == 401) {
          return {
            'success': false,
            'message': 'Session expired. Please login again.',
            'requiresAuth': true,
          };
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
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
        'data': [],
      };
    }
  }

  // Branch List API
  static Future<Map<String, dynamic>> getBranchList() async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Fetching branch list...');
        print('API URL: $baseUrl/BranchList');
        print('Retrieved token from storage: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      }
      
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('No token found in storage, authentication required');
        }
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
          'requiresAuth': true,
        };
      }

      // Make GET request with Authorization header
      final response = await _dio.get(
        '/BranchList',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print('Branch List API Response status: ${response.statusCode}');
        print('Branch List API Response data: ${response.data}');
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == true || responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['branches'] ?? responseData['branch_list'] ?? responseData['data'] ?? [],
          'message': responseData['message'] ?? 'Branch list fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch branch list',
          'data': [],
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException in getBranchList: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
      }
      
      String errorMessage = 'Network error. Please check your internet connection.';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Failed to fetch branch list';
        }
        
        // Handle 401 Unauthorized
        if (e.response!.statusCode == 401) {
          return {
            'success': false,
            'message': 'Session expired. Please login again.',
            'requiresAuth': true,
            'data': [],
          };
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
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
        'data': [],
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
