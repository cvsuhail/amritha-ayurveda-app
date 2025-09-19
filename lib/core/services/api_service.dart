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
        print('Branch List DioException type: ${e.type}');
        print('Branch List DioException message: ${e.message}');
        print('Branch List DioException response: ${e.response?.data}');
        print('Branch List DioException status code: ${e.response?.statusCode}');
      }

      String errorMessage = 'Network error. Please check your internet connection.';

      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Failed to fetch branch list. Please try again.';
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

  // Treatment List API
  static Future<Map<String, dynamic>> getTreatmentList() async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Fetching treatment list...');
        print('API URL: $baseUrl/TreatmentList');
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
        '/TreatmentList',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print('Treatment List API Response status: ${response.statusCode}');
        print('Treatment List API Response data: ${response.data}');
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == true || responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['treatments'] ?? responseData['treatment_list'] ?? responseData['data'] ?? [],
          'message': responseData['message'] ?? 'Treatment list fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch treatment list',
          'data': [],
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException in getTreatmentList: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
      }
      
      String errorMessage = 'Network error. Please check your internet connection.';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Failed to fetch treatment list';
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

  // Test endpoint method
  static Future<Map<String, dynamic>> testEndpoint(String endpoint, {String method = 'GET'}) async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Testing endpoint: $endpoint with method: $method');
      }
      
      Response response;
      if (method.toUpperCase() == 'POST') {
        // Test with minimal form data
        final testData = FormData.fromMap({'test': 'test'});
        response = await _dio.post(
          endpoint,
          data: testData,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${token ?? ""}',
              'Content-Type': 'multipart/form-data',
            },
            validateStatus: (status) => status! < 500, // Accept 4xx errors for testing
          ),
        );
      } else {
        response = await _dio.get(
          endpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${token ?? ""}',
            },
            validateStatus: (status) => status! < 500, // Accept 4xx errors for testing
          ),
        );
      }
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': 'Endpoint $endpoint responded with ${response.statusCode}',
        'contentType': response.headers['content-type']?.first ?? 'unknown',
        'isJson': response.data is Map,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Endpoint $endpoint failed: $e',
        'error': e.toString(),
      };
    }
  }

  // Test connectivity method
  static Future<Map<String, dynamic>> testConnectivity() async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Testing connectivity...');
        print('Base URL: $baseUrl');
        print('Token available: ${token != null}');
      }
      
      // Simple GET request to test connectivity
      final response = await _dio.get(
        '/PatientList', // Use existing endpoint for testing
        options: Options(
          headers: {
            'Authorization': 'Bearer ${token ?? ""}',
          },
        ),
      );
      
      if (kDebugMode) {
        print('Connectivity test successful: ${response.statusCode}');
      }
      
      return {
        'success': true,
        'message': 'Connectivity test successful',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Connectivity test failed: ${e.type} - ${e.message}');
      }
      return {
        'success': false,
        'message': 'Connectivity test failed: ${e.message}',
        'error': e.toString(),
      };
    }
  }

  // Patient Update API (Register Patient)
  static Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String executive,
    required String payment,
    required String phone,
    required String address,
    required double totalAmount,
    required double discountAmount,
    required double advanceAmount,
    required double balanceAmount,
    required String dateNdTime,
    required String branch,
    required String treatments,
    String? male,
    String? female,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (kDebugMode) {
        print('Registering patient...');
        print('API URL: $baseUrl/PatientUpdate');
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

      // Helper function to create form data (to avoid reuse issues)
      FormData createFormData() {
        // Convert amounts to integers as the Django server expects integer fields
        final totalAmountInt = totalAmount.toInt();
        final discountAmountInt = discountAmount.toInt();
        final advanceAmountInt = advanceAmount.toInt();
        final balanceAmountInt = balanceAmount.toInt();
        
        final formDataMap = <String, dynamic>{
          'name': name,
          'excecutive': executive,
          'payment': payment,
          'phone': phone,
          'address': address,
          'total_amount': totalAmountInt.toString(), // Convert to string for form data
          'discount_amount': discountAmountInt.toString(),
          'advance_amount': advanceAmountInt.toString(),
          'balance_amount': balanceAmountInt.toString(),
          'date_nd_time': dateNdTime,
          'id': '', // Pass empty string for new patient
          'branch': branch.toString(), // Ensure branch is string for form data
          'treatments': treatments.toString(), // Ensure treatments is string
        };
        
        // Add gender fields only if they have values
        if (male != null && male.isNotEmpty) {
          formDataMap['male'] = male;
        }
        if (female != null && female.isNotEmpty) {
          formDataMap['female'] = female;
        }
        
        if (kDebugMode) {
          print('Form data map: $formDataMap');
        }
        
        return FormData.fromMap(formDataMap);
      }

      if (kDebugMode) {
        print('Patient registration data:');
        print('- Name: $name');
        print('- Executive: $executive');
        print('- Payment: $payment');
        print('- Phone: $phone');
        print('- Address: $address');
        print('- Branch ID: $branch'); // This should be a number now
        print('- Date Time: $dateNdTime');
        print('- Treatments: $treatments');
        print('- Male: ${male ?? "none"}');
        print('- Female: ${female ?? "none"}');
        print('Request headers: Authorization: Bearer $token, Content-Type: multipart/form-data');
        print('Full API URL: $baseUrl/PatientUpdate');
      }

      // The endpoint /PatientUpdate exists according to Django URL patterns
      // Let's test if it accepts POST requests and what the issue might be
      if (kDebugMode) {
        print('Testing /PatientUpdate endpoint first...');
      }
      
      // Use POST method as server only allows POST and OPTIONS
      Response? response;
      
      try {
        if (kDebugMode) {
          print('Making POST request to PatientUpdate endpoint...');
        }
        
        // Based on the Django error, the server expects multipart/form-data
        // and integer values for amount fields (not float strings)
        
        response = await _dio.post(
          '/PatientUpdate',
          data: createFormData(),
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );
      } on DioException catch (e) {
        if (kDebugMode) {
          print('POST request failed with status: ${e.response?.statusCode}');
          print('POST error message: ${e.message}');
          print('Response data: ${e.response?.data}');
          print('Response headers: ${e.response?.headers}');
        }
        
        // Re-throw the error for proper handling
        throw e;
      }

      if (kDebugMode) {
        print('Patient Registration API Response status: ${response.statusCode}');
        print('Patient Registration API Response data: ${response.data}');
        print('Successful endpoint used: /PatientUpdate');
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == true || responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'] ?? responseData,
          'message': responseData['message'] ?? 'Patient registered successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to register patient',
          'data': responseData,
        };
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('=== PATIENT REGISTRATION ERROR DEBUG ===');
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
        print('DioException request path: ${e.requestOptions.path}');
        print('DioException request headers: ${e.requestOptions.headers}');
        print('DioException request data type: ${e.requestOptions.data.runtimeType}');
        print('========================================');
      }

      String errorMessage = 'Network error. Please check your internet connection.';

      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 'Failed to register patient. Please try again.';
        }
        
        // Handle specific status codes
        if (e.response!.statusCode == 401) {
          return {
            'success': false,
            'message': 'Session expired. Please login again.',
            'requiresAuth': true,
          };
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'API endpoint not found. Please check the endpoint URL.';
        } else if (e.response!.statusCode == 422) {
          errorMessage = 'Invalid data format. Please check your input.';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Bad response from server. Status: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.cancel) {
        errorMessage = 'Request was cancelled.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Unknown network error: ${e.message}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
        'data': e.response?.data,
      };
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
