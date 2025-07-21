import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._api);

  /// Login user and save tokens + user info
  Future<User> login(String email, String password) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];
    final userData = response.data['user'];

    if (accessToken != null && userData != null) {
      await _storage.write(key: ApiEndpoints.jwtStorageKey, value: accessToken);
      await _storage.write(
        key: ApiEndpoints.userStorageKey,
        value: jsonEncode(userData),
      );
      await _storage.write(
        key: ApiEndpoints.refreshTokenStorageKey, // Add this constant
        value: refreshToken,
      );
    }

    return User.fromJson(userData);
  }

  /// Fetch current user from secure storage
  Future<User?> getCurrentUser() async {
    final userJson = await _storage.read(key: ApiEndpoints.userStorageKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  /// Log out user and clear tokens
  Future<void> logout() async {
    await _storage.delete(key: ApiEndpoints.jwtStorageKey);
    await _storage.delete(key: ApiEndpoints.refreshTokenStorageKey);
    await _storage.delete(key: ApiEndpoints.userStorageKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await const FlutterSecureStorage().containsKey(
      key: ApiEndpoints.jwtStorageKey,
    );
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      await _api.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          if (fullName != null) 'full_name': fullName,
        },
      );
      return true;
    } catch (e) {
      // Log error if needed
      return false;
    }
  }

  /// Refresh JWT token if needed (optional, depends on Flask API support)
  Future<void> refreshToken() async {
   final refreshToken = await _storage.read(
      key: ApiEndpoints.refreshTokenStorageKey,
    );
    if (refreshToken == null) return;

    final response = await _api.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final newToken = response.data['access_token'];
    if (newToken != null) {
      await _storage.write(key: ApiEndpoints.jwtStorageKey, value: newToken);
    }
  }
}
