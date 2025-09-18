import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }
  
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }
  
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }
  
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to delete refresh token: $e');
    }
  }
  
  static Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }
  
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }
  
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
  
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }
}
