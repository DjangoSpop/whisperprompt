import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'dart:convert';

class StorageService {
  static const String _userBox = 'user_box';
  static const String _cacheBox = 'cache_box';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Box _userDataBox;
  late Box _cacheBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _userDataBox = await Hive.openBox(_userBox);
    _cacheBox = await Hive.openBox(_cacheBox);
  }

  // ========== Tokens ==========

  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: ApiConfig.accessTokenKey,
      value: tokens.access,
    );
    await _secureStorage.write(
      key: ApiConfig.refreshTokenKey,
      value: tokens.refresh,
    );
  }

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: ApiConfig.accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: ApiConfig.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConfig.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: ApiConfig.accessTokenKey);
    await _secureStorage.delete(key: ApiConfig.refreshTokenKey);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // ========== User Data ==========

  Future<void> saveUser(User user) async {
    await _userDataBox.put(ApiConfig.userDataKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userData = _userDataBox.get(ApiConfig.userDataKey);
    if (userData == null) return null;
    return User.fromJson(jsonDecode(userData));
  }

  Future<void> clearUser() async {
    await _userDataBox.delete(ApiConfig.userDataKey);
  }

  // ========== Cache ==========

  Future<void> cacheData(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  dynamic getCachedData(String key) {
    return _cacheBox.get(key);
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // ========== Clear All ==========

  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
    await clearCache();
  }
}
