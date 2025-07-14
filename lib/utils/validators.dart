class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  static String? flightNumber(String? value) {
    if (value == null || value.isEmpty) return 'Flight number required';
    if (!RegExp(r'^[A-Z]{2}\d{3,4}$').hasMatch(value)) {
      return 'Format: AA1234';
    }
    return null;
  }
}
