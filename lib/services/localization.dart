import 'package:flutter/material.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';

class LocalizationService {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static String translate(BuildContext context, String key) {
    final loc = of(context);
    switch (key) {
      case 'appName':
        return loc.appName;
      case 'flightSearch':
        return loc.flightSearch;
      // Add all other keys as needed
      default:
        return key;
    }
  }
}
