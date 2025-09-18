import 'package:flutter/foundation.dart';

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

  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoginMode => _isLoginMode;
  bool get isLoading => _state == AuthState.loading;

  // Toggle between login and register mode
  void toggleAuthMode() {
    _isLoginMode = !_isLoginMode;
    _clearError();
    notifyListeners();
  }

  // Login method
  Future<void> login(String email, String password) async {
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
      
      // Simulate successful login
      _setState(AuthState.authenticated);
      
    } catch (e) {
      _setError(e.toString());
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

  // Logout method
  void logout() {
    _setState(AuthState.unauthenticated);
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
