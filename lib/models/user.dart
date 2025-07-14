class User {
  final String id;
  final String email;
  final String role; // 'admin', 'employee', 'passenger'
  final bool isActive; // matches Flask's is_active
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
      email: json['email'],
      role: json['role'],
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
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Helpers for role-based checks
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isEmployee => role.toLowerCase() == 'employee';
  bool get isPassenger => role.toLowerCase() == 'passenger';
  bool get isStaff => ['admin', 'employee'].contains(role.toLowerCase());
}
