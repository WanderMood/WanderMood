import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/core/domain/models/user_preferences.dart';
import 'package:wandermood/features/settings/presentation/providers/user_preferences_provider.dart';

import '../../../../core/presentation/widgets/app_bar_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildThemeSection(context, ref, userPreferences),
          const Divider(),
          _buildNotificationsSection(context, ref, userPreferences),
          const Divider(),
          _buildAppearanceSection(context, ref, userPreferences),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, UserPreferences preferences) {
    return _buildSection(
      context,
      'Theme',
      [
        SwitchListTile(
          title: const Text('Use device theme'),
          subtitle: const Text('Follow system light/dark mode settings'),
          value: preferences.useSystemTheme,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateUseSystemTheme(value);
          },
        ),
        if (!preferences.useSystemTheme)
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Enable dark theme'),
            value: preferences.darkMode,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).updateDarkMode(value);
            },
          ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref, UserPreferences preferences) {
    return _buildSection(
      context,
      'Notifications',
      [
        SwitchListTile(
          title: const Text('Trip Reminders'),
          subtitle: const Text('Receive reminders about upcoming trips'),
          value: preferences.tripReminders ?? false,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateTripReminders(value);
          },
        ),
        SwitchListTile(
          title: const Text('Weather Updates'),
          subtitle: const Text('Get notifications about weather changes at your destinations'),
          value: preferences.weatherUpdates ?? false,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateWeatherUpdates(value);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref, UserPreferences preferences) {
    return _buildSection(
      context,
      'App Appearance',
      [
        SwitchListTile(
          title: const Text('Animations'),
          subtitle: const Text('Enable animations throughout the app'),
          value: preferences.useAnimations,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateUseAnimations(value);
          },
        ),
        SwitchListTile(
          title: const Text('Confetti'),
          subtitle: const Text('Show confetti for achievements'),
          value: preferences.showConfetti,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateShowConfetti(value);
          },
        ),
        SwitchListTile(
          title: const Text('Progress Indicators'),
          subtitle: const Text('Show progress bars and indicators'),
          value: preferences.showProgress,
          onChanged: (value) {
            ref.read(userPreferencesProvider.notifier).updateShowProgress(value);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      'About',
      [
        ListTile(
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
          trailing: const Icon(Icons.info_outline),
          onTap: () {
            // Show app version details
          },
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to terms of service
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
} 
 
 
 