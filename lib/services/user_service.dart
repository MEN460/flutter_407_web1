import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/services/api_service.dart';
import 'package:k_airways_flutter/utils/logger.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  /// Fetch all users (admin-only in Flask)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _api.get(ApiEndpoints.adminUsers);
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      Logger.logError('Failed to fetch users: $e');
      rethrow;
    }
  }

  /// Fetch user by ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await _api.get('${ApiEndpoints.adminUsers}/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      Logger.logError('Failed to fetch user $userId: $e');
      rethrow;
    }
  }

  /// Create a new user (admin-only)
  Future<User> createUser({
    required String email,
    required String password,
    required String role, // 'passenger', 'employee', 'admin'
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.adminUsers,
        data: {'email': email, 'password': password, 'role': role},
      );
      return User.fromJson(response.data);
    } catch (e) {
      Logger.logError('Failed to create user: $e');
      rethrow;
    }
  }

  /// Update user details (admin-only)
  Future<User> updateUser(User user) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.adminUsers}/${user.id}',
        data: user.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      Logger.logError('Failed to update user ${user.id}: $e');
      rethrow;
    }
  }

  /// Delete user (admin-only)
  Future<void> deleteUser(String userId) async {
    try {
      await _api.delete('${ApiEndpoints.adminUsers}/$userId');
    } catch (e) {
      Logger.logError('Failed to delete user $userId: $e');
      rethrow;
    }
  }

  /// Search users by email or name
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _api.get(
        ApiEndpoints.adminUsers,
        params: {'q': query},
      );
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      Logger.logError('User search failed for "$query": $e');
      rethrow;
    }
  }

  /// Search users by role
  Future<List<User>> searchUsersByRole(String role) async {
    try {
      final response = await _api.get(
        ApiEndpoints.adminUsers,
        params: {'role': role},
      );
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      Logger.logError('User search failed for role "$role": $e');
      rethrow;
    }
  }
}
