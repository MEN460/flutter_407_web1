import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityUtils {
  static void setSemanticNames(BuildContext context) {
    SemanticsService.announce('Kenya Airways Application', TextDirection.ltr);
  }

  static void announceChanges(String message, BuildContext context) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

 static double getTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.5);
  }

  static bool isScreenReaderActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  static Widget semanticLabel(String label, Widget child) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: child),
    );
  }
}
