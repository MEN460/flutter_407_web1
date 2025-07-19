
import 'package:flutter/material.dart';

class Validators {
  /// Email validation with comprehensive pattern matching
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email required';

    // More robust email validation pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    // Additional length check for security
    if (value.trim().length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  /// Enhanced password validation with security requirements
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password required';

    if (value.length < 8) return 'Password must be at least 8 characters';

    if (value.length > 128) return 'Password is too long (max 128 characters)';

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
    }

    return null;
  }

  /// Password confirmation validator
  static String? confirmPassword(String? value, String? originalPassword) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Enhanced flight number validation with more airline codes support
  static String? flightNumber(String? value) {
    if (value == null || value.isEmpty) return 'Flight number required';

    final trimmedValue = value.trim().toUpperCase();

    // Support various airline code formats:
    // - Standard IATA: AA123, AA1234
    // - Extended formats: AAA123, 9W123 (for some airlines)
    // - Kenya Airways specific: KQ123, KQ1234
    final flightNumberRegex = RegExp(r'^([A-Z]{2,3}|[0-9][A-Z])\d{3,4}$');

    if (!flightNumberRegex.hasMatch(trimmedValue)) {
      return 'Invalid flight number format (e.g., KQ123, AA1234)';
    }

    return null;
  }

  /// Full name validation
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name required';

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Full name must be at least 2 characters';
    }

    if (trimmedValue.length > 100) {
      return 'Full name is too long (max 100 characters)';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmedValue)) {
      return 'Full name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Must contain at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmedValue)) {
      return 'Full name must contain at least one letter';
    }

    return null;
  }

  /// Phone number validation (international format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';

    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // International format: +254712345678 or 0712345678
    final phoneRegex = RegExp(r'^(\+254|0)[17]\d{8}$');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Enter a valid Kenyan phone number';
    }

    return null;
  }

  /// Booking reference validation
  static String? bookingReference(String? value) {
    if (value == null || value.isEmpty) return 'Booking reference required';

    final trimmedValue = value.trim().toUpperCase();

    // Typical airline booking reference: 6 alphanumeric characters
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(trimmedValue)) {
      return 'Booking reference must be 6 characters (letters and numbers)';
    }

    return null;
  }

  /// Seat number validation
  static String? seatNumber(String? value) {
    if (value == null || value.isEmpty) return 'Seat number required';

    final trimmedValue = value.trim().toUpperCase();

    // Seat format: 1A, 12F, 45K, etc.
    if (!RegExp(r'^\d{1,2}[A-K]$').hasMatch(trimmedValue)) {
      return 'Invalid seat number format (e.g., 12A, 5F)';
    }

    return null;
  }

  /// Passport number validation (basic)
  static String? passportNumber(String? value) {
    if (value == null || value.isEmpty) return 'Passport number required';

    final trimmedValue = value.trim().toUpperCase();

    if (trimmedValue.length < 6 || trimmedValue.length > 12) {
      return 'Passport number must be 6-12 characters';
    }

    // Basic alphanumeric validation
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmedValue)) {
      return 'Passport number can only contain letters and numbers';
    }

    return null;
  }

  /// Generic required field validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Numeric validation with optional range
  static String? numeric(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) return 'Number required';

    final number = int.tryParse(value);
    if (number == null) return 'Enter a valid number';

    if (min != null && number < min) {
      return 'Number must be at least $min';
    }

    if (max != null && number > max) {
      return 'Number must be at most $max';
    }

    return null;
  }

  /// Real-time password strength indicator
  static PasswordStrength getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.empty;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Bonus for very long passwords
    if (password.length >= 16) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong;

  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.blue;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }
}
