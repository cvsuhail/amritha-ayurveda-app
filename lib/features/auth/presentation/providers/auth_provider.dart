import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  bool _isLoginMode = true;
  String? _token;
  Map<String, dynamic>? _userData;

  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoginMode => _isLoginMode;
  bool get isLoading => _state == AuthState.loading;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  // Initialize auth state on app start
  Future<void> initializeAuth() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        _token = await StorageService.getToken();
        final userDataString = await StorageService.getUserData();
        if (userDataString != null) {
          // Parse user data if needed
          _userData = {}; // You can parse JSON here if user data is stored as JSON
        }
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setState(AuthState.unauthenticated);
    }
  }

  // Toggle between login and register mode
  void toggleAuthMode() {
    _isLoginMode = !_isLoginMode;
    _clearError();
    notifyListeners();
  }

  // Login method with API integration
  Future<void> login(String email, String password) async {
    _setState(AuthState.loading);
    
    try {
      // Use the fixed credentials as specified in requirements
      final result = await ApiService.login(
        username: 'test_user',
        password: '12345678',
      );
      
      if (result['success'] == true) {
        // Store token securely
        final token = result['token'] as String;
        if (token.isNotEmpty) {
          if (kDebugMode) {
            print('AuthProvider: Saving token: ${token.substring(0, 20)}...');
          }
          await StorageService.saveToken(token);
          _token = token;
        }
        
        // Store user data if available
        final userData = result['data'] as Map<String, dynamic>?;
        if (userData != null) {
          _userData = userData;
          // Store user data as JSON string
          await StorageService.saveUserData(userData.toString());
          if (kDebugMode) {
            print('AuthProvider: Saved user data: ${userData['user_details']?['name'] ?? 'unknown'}');
          }
        }
        
        _setState(AuthState.authenticated);
        
        // Verify token was stored
        final storedToken = await StorageService.getToken();
        if (kDebugMode) {
          print('AuthProvider: Verified stored token: ${storedToken?.substring(0, 20) ?? 'null'}...');
        }
      } else {
        _setError(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
        print('Error type: ${e.runtimeType}');
      }
      
      // Provide more specific error messages based on error type
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid server response. Please try again.';
      }
      
      _setError(errorMessage);
    }
  }

  // Register method
  Future<void> register(String email, String password) async {
    _setState(AuthState.loading);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }
      
      // Removed email validation to allow usernames like 'test_user'
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      // Simulate successful registration
      _setState(AuthState.authenticated);
      
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Logout method with storage cleanup
  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _token = null;
      _userData = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      // Even if storage cleanup fails, we should still log out the user
      _token = null;
      _userData = null;
      _setState(AuthState.unauthenticated);
      if (kDebugMode) {
        print('Logout storage cleanup error: $e');
      }
    }
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_state == AuthState.error) {
      _state = AuthState.initial;
      _errorMessage = '';
    }
  }

}
