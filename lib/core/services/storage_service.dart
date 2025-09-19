import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  static Future<void> saveToken(String token) async {
    try {
      await _initPrefs();
      await _prefs!.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }
  
  static Future<String?> getToken() async {
    try {
      await _initPrefs();
      return _prefs!.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteToken() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }
  
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _initPrefs();
      await _prefs!.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }
  
  static Future<String?> getRefreshToken() async {
    try {
      await _initPrefs();
      return _prefs!.getString(_refreshTokenKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteRefreshToken() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to delete refresh token: $e');
    }
  }
  
  static Future<void> saveUserData(String userData) async {
    try {
      await _initPrefs();
      await _prefs!.setString(_userDataKey, userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }
  
  static Future<String?> getUserData() async {
    try {
      await _initPrefs();
      return _prefs!.getString(_userDataKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> deleteUserData() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_userDataKey);
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
      await _initPrefs();
      await _prefs!.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
  
  static Future<bool> containsKey(String key) async {
    try {
      await _initPrefs();
      return _prefs!.containsKey(key);
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, String>> getAllData() async {
    try {
      await _initPrefs();
      final keys = _prefs!.getKeys();
      final Map<String, String> data = {};
      for (String key in keys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          data[key] = value;
        }
      }
      return data;
    } catch (e) {
      return {};
    }
  }
}
