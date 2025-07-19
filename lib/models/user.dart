class User {
  final String id;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  /// Create a User from JSON (matches Flask's to_dict)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      // Normalize role to lowercase for consistency
      role: (json['role'] ?? 'passenger').toString().toLowerCase(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  /// Convert User back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Helpers for role-based checks (now safe with normalized roles)
  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
  bool get isPassenger => role == 'passenger';
  bool get isStaff => ['admin', 'employee'].contains(role);

  /// Get display name for role
  String get roleDisplayName {
    return role[0].toUpperCase() + role.substring(1);
  }
}
