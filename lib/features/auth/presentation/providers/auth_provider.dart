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
          await StorageService.saveToken(token);
          _token = token;
        }
        
        // Store user data if available
        final userData = result['data'] as Map<String, dynamic>?;
        if (userData != null) {
          _userData = userData;
          // You can store user data as JSON string if needed
          // await StorageService.saveUserData(json.encode(userData));
        }
        
        _setState(AuthState.authenticated);
      } else {
        _setError(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      if (kDebugMode) {
        print('Login error: $e');
      }
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
        throw Exception('Email and password are required');
      }
      
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email');
      }
      
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
