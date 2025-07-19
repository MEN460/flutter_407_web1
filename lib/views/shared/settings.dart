import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/utils/theme_provider.dart';

// Language model
class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

// Currency model
class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

// Available languages
const List<Language> availableLanguages = [
  Language(code: 'en', name: 'English', nativeName: 'English'),
  Language(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili'),
  Language(code: 'fr', name: 'French', nativeName: 'Français'),
];

// Available currencies
const List<Currency> availableCurrencies = [
  Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
  Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  Currency(code: 'EUR', name: 'Euro', symbol: '€'),
  Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
];

// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, Language>((
  ref,
) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Language> {
  LanguageNotifier() : super(availableLanguages.first);

  void setLanguage(Language language) {
    state = language;
    // Here you would typically save to SharedPreferences or secure storage
  }
}

// Currency provider
final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((
  ref,
) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(availableCurrencies.first);

  void setCurrency(Currency currency) {
    state = currency;
    // Here you would typically save to SharedPreferences or secure storage
  }
}

// Notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, Map<String, bool>>((ref) {
      return NotificationsNotifier();
    });

class NotificationsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationsNotifier()
    : super({
        'push_notifications': true,
        'email_notifications': true,
        'flight_updates': true,
        'promotional_offers': false,
      });

  void toggleNotification(String key, bool value) {
    state = {...state, key: value};
    // Here you would typically save to SharedPreferences or secure storage
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeListTile(context, ref, theme),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Preferences'),
          _buildLanguageListTile(context, ref, selectedLanguage),
          _buildCurrencyListTile(context, ref, selectedCurrency),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationsListTile(context),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Legal & Support'),
          _buildPrivacyPolicyListTile(context),
          _buildTermsOfServiceListTile(context),
          _buildSupportListTile(context),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildAboutListTile(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeListTile(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) {
    return ListTile(
      leading: Icon(
        theme.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Dark Mode'),
      subtitle: Text(
        theme.themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
      ),
      trailing: Switch(
        value: theme.themeMode == ThemeMode.dark,
        onChanged: (value) {
          ref
              .read(themeProvider.notifier)
              .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildLanguageListTile(
    BuildContext context,
    WidgetRef ref,
    Language selectedLanguage,
  ) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Language'),
      subtitle: Text(selectedLanguage.nativeName),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(context, ref, selectedLanguage),
    );
  }

  Widget _buildCurrencyListTile(
    BuildContext context,
    WidgetRef ref,
    Currency selectedCurrency,
  ) {
    return ListTile(
      leading: Icon(
        Icons.attach_money,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Currency'),
      subtitle: Text('${selectedCurrency.code} - ${selectedCurrency.name}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showCurrencyDialog(context, ref, selectedCurrency),
    );
  }

  Widget _buildNotificationsListTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.notifications,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Notifications'),
      subtitle: const Text('Manage notification preferences'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showNotificationsDialog(context),
    );
  }

  Widget _buildPrivacyPolicyListTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.privacy_tip,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Privacy Policy'),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _openPrivacyPolicy(context),
    );
  }

  Widget _buildTermsOfServiceListTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.description,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Terms of Service'),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () => _openTermsOfService(context),
    );
  }

  Widget _buildSupportListTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.help_center,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Help & Support'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _openSupport(context),
    );
  }

  Widget _buildAboutListTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.info,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('About'),
      subtitle: const Text('Version 1.0.0'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Language currentLanguage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableLanguages.length,
            itemBuilder: (context, index) {
              final language = availableLanguages[index];
              final isSelected = language == currentLanguage;

              return RadioListTile<Language>(
                title: Text(language.nativeName),
                subtitle: Text(language.name),
                value: language,
                groupValue: currentLanguage,
                onChanged: (Language? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    WidgetRef ref,
    Currency currentCurrency,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableCurrencies.length,
            itemBuilder: (context, index) {
              final currency = availableCurrencies[index];

              return RadioListTile<Currency>(
                title: Text('${currency.code} - ${currency.name}'),
                subtitle: Text('Symbol: ${currency.symbol}'),
                value: currency,
                groupValue: currentCurrency,
                onChanged: (Currency? value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).setCurrency(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final notifications = ref.watch(notificationsProvider);

          return AlertDialog(
            title: const Text('Notification Settings'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    value: notifications['push_notifications'] ?? false,
                    onChanged: (value) {
                      ref
                          .read(notificationsProvider.notifier)
                          .toggleNotification('push_notifications', value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    value: notifications['email_notifications'] ?? false,
                    onChanged: (value) {
                      ref
                          .read(notificationsProvider.notifier)
                          .toggleNotification('email_notifications', value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Flight Updates'),
                    value: notifications['flight_updates'] ?? false,
                    onChanged: (value) {
                      ref
                          .read(notificationsProvider.notifier)
                          .toggleNotification('flight_updates', value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Promotional Offers'),
                    value: notifications['promotional_offers'] ?? false,
                    onChanged: (value) {
                      ref
                          .read(notificationsProvider.notifier)
                          .toggleNotification('promotional_offers', value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    // Navigate to privacy policy page or open web URL
    context.push('/privacy-policy');
  }

  void _openTermsOfService(BuildContext context) {
    // Navigate to terms of service page or open web URL
    context.push('/terms-of-service');
  }

  void _openSupport(BuildContext context) {
    // Navigate to support page
    context.push('/support');
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'K Airways',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text('A modern airline booking application built with Flutter.'),
        const SizedBox(height: 16),
        const Text('© 2024 K Airways. All rights reserved.'),
      ],
    );
  }
}
