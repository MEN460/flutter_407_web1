import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0C2340); // Kenya Airways blue
  static const accent = Color(0xFFE31937); // Kenya Airways red
  static const executiveClass = Color(0xFFFFD700);
  static const middleClass = Color(0xFF00B2A9);
  static const economyClass = Color(0xFF6A994E);
  static const background = Color(0xFFF5F7FA);
  static const error = Color(0xFFB00020);
}
class AppGradients {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0C2340), Color(0xFFE31937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 